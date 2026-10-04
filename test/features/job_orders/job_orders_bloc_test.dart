import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/job_order/job_order_api.dart';
import 'package:maleva/features/dashboard/common_tabs/job_orders/bloc/job_orders_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/job_orders/bloc/job_orders_event.dart';
import 'package:maleva/features/dashboard/common_tabs/job_orders/bloc/job_orders_state.dart';

import '../../core/network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The Job Orders tab reads the shared Java job orders (change job-orders-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late JobOrdersBloc bloc;

  final javaJob = {
    'id': 10,
    'companyRefId': 6,
    'cnumberDisplay': 'JO000010',
    'statusRefId': 1,
    'statusName': 'OPEN',
    'truckMasterRefId': 42,
    'truckName': 'WXY 1234',
    'driverName': 'ALI',
    'jobTypeName': 'SERVICE',
    'jobDate': '2026-10-04',
    'expectedCompletionDate': '2026-10-06',
    'remarks': 'brake noise',
    'estimatedCost': 120.5,
    'details': [
      {'id': 1, 'jobOrderMasterRefId': 10, 'problemName': 'BRAKE', 'productRefId': 5, 'cost': 80, 'active': 1},
      {'id': 2, 'jobOrderMasterRefId': 10, 'problemName': 'OLD LINE', 'productRefId': null, 'cost': 0, 'active': 0},
    ],
  };

  void queueLoad() {
    adapter.replies
      ..add((200, jsonEncode(ok([{'id': 1, 'name': 'OPEN'}, {'id': 3, 'name': 'COMPLETED'}]))))
      ..add((200, jsonEncode([{'id': 5, 'pname': 'BRAKE PAD'}])))
      ..add((200, jsonEncode(ok([javaJob]))));
  }

  setUp(() {
    adapter = QueueAdapter();
    final api = JobOrderApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter,
        companyId: () => 6);
    bloc = JobOrdersBloc(api: api, loadTrucks: () async => []);
  });

  tearDown(() => bloc.close());

  test('lists the Java job orders with their active lines and product names', () async {
    queueLoad();
    bloc.add(const FetchJobOrders());

    final state = await bloc.stream.firstWhere((s) => s is JobOrdersLoaded) as JobOrdersLoaded;

    final job = state.jobOrders.single;
    expect(job.cNumberDisplay, 'JO000010');
    expect(job.truckName, 'WXY 1234');
    expect(job.sJobDate, '04/10/2026');
    expect(job.targetDate, '06/10/2026');
    expect(job.estimatedCost, 120.5);
    expect(state.jobTypes.map((t) => t.name), ['OPEN', 'COMPLETED']);
    expect(state.jobDetails.single.productName, 'BRAKE PAD');
    expect(adapter.requests.last.data, {'companyRefId': 6, 'statusRefId': 1, 'truckMasterRefId': 0});
  });

  test('a status change calls the status endpoint and lists again with the same filter', () async {
    queueLoad();
    bloc.add(const FetchJobOrders(jId: 1, tId: 42));
    await bloc.stream.firstWhere((s) => s is JobOrdersLoaded);

    adapter.replies
      ..add((200, jsonEncode(ok({'id': 10, 'statusRefId': 3}))))
      ..add((200, jsonEncode(ok([]))));
    bloc.add(const UpdateJobOrderStatus(10, 3));
    final state = await bloc.stream.firstWhere((s) => s is JobOrdersLoaded) as JobOrdersLoaded;

    final put = adapter.requests[adapter.requests.length - 2];
    expect(put.uri.toString(), 'https://java.test/api/job-orders/10/status?companyRefId=6&statusRefId=3');
    expect(adapter.requests.last.data, {'companyRefId': 6, 'statusRefId': 1, 'truckMasterRefId': 42});
    expect(state.jobOrders, isEmpty);
  });

  test('a failed list is an error state with the server message', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([]))))
      ..add((200, jsonEncode([])))
      ..add((500, jsonEncode({'IsSuccess': false, 'StatusCode': 500, 'Message': 'Database unavailable'})));
    bloc.add(const FetchJobOrders());

    final state = await bloc.stream.firstWhere((s) => s is JobOrdersError) as JobOrdersError;
    expect(state.message, 'Database unavailable');
  });
}
