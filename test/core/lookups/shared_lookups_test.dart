import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/lookups/shared_lookups.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Each shared web API's answer turned into the row shape the app's models read.
void main() {
  late QueueAdapter adapter;
  late SharedLookups lookups;

  setUp(() {
    adapter = QueueAdapter();
    lookups = SharedLookups(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  String uri() => adapter.requests.last.uri.toString();

  test('trucks and drivers are the combo rows', () async {
    adapter.replies
      ..add((200, jsonEncode({'isSuccess': true, 'data1': [{'Id': 3, 'AccountName': 'VBC 5521'}]})))
      ..add((200, jsonEncode({'isSuccess': true, 'data1': [{'Id': 7, 'AccountName': 'RAVI-0123'}]})));

    expect(await lookups.trucks(6, type: 'PRIME'), [{'Id': 3, 'AccountName': 'VBC 5521'}]);
    expect(adapter.requests.first.uri.toString(), 'https://java.test/api/truck-combo?companyId=6&type=PRIME');
    expect(await lookups.drivers(6), [{'Id': 7, 'AccountName': 'RAVI-0123'}]);
    expect(uri(), 'https://java.test/api/driver-combo?companyId=6');
  });

  test('customers read the option label as AccountName', () async {
    adapter.replies.add((200, jsonEncode({'success': true, 'data': [
      {'id': 4, 'customerName': 'ACME', 'companyCode': 'C01', 'label': 'ACME-C01'}
    ]})));

    expect(await lookups.customers(6), [{'Id': 4, 'AccountName': 'ACME-C01'}]);
    expect(uri(), 'https://java.test/api/customers/options?companyId=6');
  });

  test('address names are distinct and sorted; a search gives the address rows', () async {
    adapter.replies
      ..add((200, jsonEncode({'ok': true, 'data': [{'name': 'port klang'}, {'name': 'Johor'}, {'name': 'port klang'}]})))
      ..add((200, jsonEncode({'ok': true, 'data': [{'id': 1, 'name': 'Johor', 'address': 'Pasir Gudang', 'phone': '07', 'active': 1}]})));

    expect(await lookups.addressNames(6), ['Johor', 'port klang']);
    expect(await lookups.addresses(6, keyword: ' joh '),
        [{'Id': 1, 'Name': 'Johor', 'Address': 'Pasir Gudang', 'Phone': '07', 'Active': 1}]);
    expect(uri(), 'https://java.test/api/addresses/company/6/search?keyword=joh');
  });

  test('job types and statuses; an empty list (404 on these APIs) is empty, not an error', () async {
    adapter.replies
      ..add((200, jsonEncode({'success': true, 'data': [{'id': 2, 'name': 'TRANSPORT', 'dFlag': 1, 'active': 1}]})))
      ..add((404, jsonEncode({'success': false, 'message': 'No job status found'})));

    expect(await lookups.jobTypes(6), [{'Id': 2, 'Name': 'TRANSPORT', 'DFlag': 1, 'Active': 1}]);
    expect(await lookups.jobStatuses(6), isEmpty);
    expect(uri(), 'https://java.test/api/job-status-master/select/6/');
  });

  test('job steps come back in the one-element .NET shape', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'Data1': [
      {
        'jobTypeDetails': [{'id': 1, 'jobMasterRefId': 2, 'description': 'Gate in', 'status': 3, 'mandatory': 1}],
        'jobStatusDetails': [{'id': 9, 'jobMasterRefId': 2, 'status': 3, 'statusName': 'ARRIVED', 'sort': 1}],
      }
    ]})));

    final steps = await lookups.jobSteps(6, 2);

    expect(adapter.requests.last.method, 'POST');
    expect(uri(), 'https://java.test/api/job-type-master/select-all-data?companyId=6&jobId=2');
    expect(steps.single['JobTypeDetails'].single['ID'], 1);
    expect(steps.single['JobTypeDetails'].single['Description'], 'Gate in');
    expect(steps.single['JobStatusDetails'].single['StatusName'], 'ARRIVED');
  });

  test('agents, agent companies (204 = none) and products', () async {
    adapter.replies
      ..add((200, jsonEncode({'ok': true, 'data': [{'id': 5, 'Name': 'SEA AGENT', 'agentCompanyRefId': 2}]})))
      ..add((204, ''))
      ..add((200, jsonEncode([{'id': 8, 'productName': 'Diesel', 'saleRate': 2.15, 'purRate': 2, 'mrp': 3, 'productCode': 'D1'}])));

    final agents = await lookups.agents(6, agentCompanyId: 2);
    expect(agents.single['AgentName'], 'SEA AGENT');
    expect(agents.single.containsKey('Password'), isFalse);
    expect(adapter.requests.first.uri.toString(), 'https://java.test/api/agents/select-all?companyRefId=6&jobId=2');
    expect(await lookups.agentCompanies(6), isEmpty);
    final product = (await lookups.products(6)).single;
    expect(product['ProductName'], 'Diesel');
    expect([product['SaleRate'], product['PurRate'], product['MRP'], product['WholeSaleRate'], product['GST']],
        [2.15, 2.0, 3.0, 0.0, 0.0]);
  });

  test('truck details give the license screen its .NET date text; a save posts the whole truck', () async {
    final truck = {
      'id': 3, 'companyRefId': 6, 'cNumberDisplay': 'T003', 'cNumber': 3, 'truckName': 'VBC 5521', 'truckNumber': 'VBC5521',
      'truckType': 'PRIME', 'active': 1, 'accountRefid': 40, 'rotexMyExp': '2026-12-31', 'insuranceExp': null,
    };
    adapter.replies
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'items': [truck], 'totalCount': 1}})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'items': [truck], 'totalCount': 1}})))
      ..add((201, jsonEncode(truck)));

    final details = (await lookups.truckDetails(6, 3)).single;
    expect(details['TruckName'], 'VBC 5521');
    expect(details['CNumberDisplay'], 'T003');
    expect(details['RotexMyExp'], '12/31/2026 00:00:00');
    expect(details['InsuratnceExp'], isNull);
    expect(adapter.requests.first.uri.queryParameters, {'companyId': '6', 'startIndex': '0', 'pageCount': '0', 'keyword': '3', 'column': 'Id'});

    final saved = await lookups.saveTruck(6, {'Id': 3, 'TruckName': 'VBC 5521 NEW', 'InsuratnceExp': '2027-01-15T00:00:00.000', 'Active': 1});

    expect(saved['IsSuccess'], isTrue);
    final posted = adapter.requests.last;
    expect(posted.uri.toString(), 'https://java.test/api/truck-masters/process?companyId=6');
    expect(posted.data['truckName'], 'VBC 5521 NEW');
    expect(posted.data['insuranceExp'], '2027-01-15');
    expect(posted.data['rotexMyExp'], isNull, reason: 'an unticked date is cleared, as the screen sends it');
    expect(posted.data['accountRefid'], 40, reason: 'the rest of the truck is kept');
  });

  test('fuel: the .NET filter, rows in the old shape, save and delete', () async {
    adapter.replies
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'items': [
        {'id': 11, 'cNumberDisplay': 'FE000000011', 'saleDate': '2026-10-02', 'truckRefId': 3, 'truckName': 'VBC 5521',
         'driverRefId': 7, 'driverName': 'RAVI', 'aliter': 50.0, 'aAmount': 100.0, 'pliter': 55.0, 'pAmount': 110.0,
         'pRate': 2.0, 'gliter': 52.0, 'gAmount': 104.0, 'diffLiter': 3.0, 'diffAmount': 6.0, 'fStatus': 1}
      ]}})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'id': 71}})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': null})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': 'FE000000072'})));

    final rows = await lookups.fuelEntries(
        {'Comid': 6, 'Fromdate': '2026-10-01', 'Todate': '2026-10-02', 'Employeeid': 0, 'DId': 3, 'TId': 7, 'Search': ''});
    expect(adapter.requests.first.uri.toString(),
        'https://java.test/api/fuel-entries?companyRefId=6&fromDate=2026-10-01&toDate=2026-10-02&truckRefId=3&driverRefId=7');
    final row = rows.single;
    expect([row['Id'], row['SSaleDate'], row['TruckRefid'], row['DPliter'], row['DPAmount'], row['DGliter']],
        [11, '02/10/2026', 3, 5.0, 10.0, 3.0]);

    final saved = await lookups.saveFuelEntries([
      {'SaleDate': '2026-10-02T00:00:00.000', 'Id': 0, 'CompanyRefId': 6, 'TruckRefid': 3, 'DriverRefId': 7,
       'Aliter': 50.5, 'AAmount': 100, 'FStatus': 1}
    ], 6);
    expect(saved['Data2'], 71);
    expect(adapter.requests[1].data, {
      'id': 0, 'companyRefId': 6, 'truckRefId': 3, 'driverRefId': 7, 'employeeRefId': null, 'saleDate': '2026-10-02',
      'aliter': 50.5, 'aAmount': 100.0, 'pliter': 0.0, 'gliter': 0.0, 'pRate': 0.0, 'remarks': null, 'filePath': null,
      'fStatus': 1,
    });

    await lookups.deleteFuelEntry(11, 6, mobile: true);
    expect(adapter.requests[2].method, 'DELETE');
    expect(adapter.requests[2].uri.toString(), 'https://java.test/api/fuel-entries/11?companyRefId=6&mobile=true');
    expect(await lookups.nextFuelNumber(6), 'FE000000072');
  });

  test('a refused call carries the server message', () async {
    adapter.replies.add((400, jsonEncode({'status': 400, 'message': 'No Truck Assigned! Please ask the office to assign a truck first.'})));

    await expectLater(lookups.saveFuelEntries([{'Id': 0}], 6), throwsA(isA<ApiFailure>()
        .having((e) => e.message, 'message', startsWith('No Truck Assigned'))));
  });
}
