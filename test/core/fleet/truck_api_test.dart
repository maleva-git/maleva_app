import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Trucks read and saved on the shared Java truck master directly (truck-lookups-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late TruckApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = TruckApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  final truck = {
    'id': 3, 'companyRefId': 6, 'cnumberDisplay': 'T003', 'cnumber': 3, 'truckName': 'VBC 5521', 'truckNumber': 'VBC5521',
    'truckType': 'PRIME', 'active': 1, 'accountRefid': 40, 'rotexMyExp': '2026-12-31', 'insuranceExp': null,
    'rotexSGExp': '2026-06-30',
  };

  test('the picker list is the combo rows', () async {
    adapter.replies.add((200, jsonEncode({'isSuccess': true, 'statusCode': 200, 'data1': [{'Id': 3, 'AccountName': 'VBC 5521'}]})));

    final rows = await api.combo(type: 'PRIME');

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/truck-combo?companyId=6&type=PRIME');
    final t = GetTruckModel.fromJava(rows.single);
    expect([t.Id, t.AccountName, t.Password], [3, 'VBC 5521', '']);
  });

  test('one truck by id, as the Java master stores it', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'Data1': {'items': [truck], 'totalCount': 1}})));

    final t = await api.byId(3);

    expect(adapter.requests.single.uri.queryParameters,
        {'companyId': '6', 'startIndex': '0', 'pageCount': '0', 'keyword': '3', 'column': 'Id'});
    expect([t!['truckName'], t['rotexMyExp']], ['VBC 5521', '2026-12-31']);
  });

  test('a save posts the whole truck with the changes, in its own spelling', () async {
    adapter.replies
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'items': [truck], 'totalCount': 1}})))
      ..add((201, jsonEncode(truck)));

    await api.update(3, {'truckName': 'VBC 5521 NEW', 'insuranceExp': '2027-01-15', 'rotexMyExp': null, 'rotexSgExp': '2026-07-01'});

    final posted = adapter.requests.last;
    expect(posted.uri.toString(), 'https://java.test/api/truck-masters/process?companyId=6');
    final body = posted.data as Map;
    expect([body['truckName'], body['insuranceExp'], body['rotexMyExp'], body['rotexSGExp']],
        ['VBC 5521 NEW', '2027-01-15', null, '2026-07-01']);
    expect(body.containsKey('rotexSgExp'), isFalse, reason: 'written under the key the truck has');
    expect(body['accountRefid'], 40, reason: 'the rest of the truck is kept');
  });

  test("a refused save is the server's text; an unknown truck is refused before posting", () async {
    adapter.replies
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'items': [truck], 'totalCount': 1}})))
      ..add((400, jsonEncode('Error: Truck number already exists')))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'items': [], 'totalCount': 0}})));

    await expectLater(api.update(3, {'truckNumber': 'X'}),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Truck number already exists')));
    await expectLater(api.update(9, {'truckNumber': 'X'}),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Truck 9 was not found')));
    expect(adapter.requests.where((r) => r.method == 'POST'), hasLength(1));
  });
}
