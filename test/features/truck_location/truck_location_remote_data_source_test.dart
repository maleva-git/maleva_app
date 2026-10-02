import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/truck_location/data/datasources/truck_location_remote_data_source.dart';
import 'package:maleva/features/truck_location/data/models/truck_location_json.dart';
import 'package:maleva/features/truck_location/domain/entities/truck_location_week.dart';

import '../../core/network/java_api_client_test.dart' show QueueAdapter;

void main() {
  late QueueAdapter adapter;
  late TruckLocationRemoteDataSource remote;

  setUp(() {
    adapter = QueueAdapter();
    remote = TruckLocationRemoteDataSource(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  final weekJson = {
    'weekStart': '2026-09-20',
    'days': ['2026-09-20', '2026-09-21', '2026-09-22', '2026-09-23', '2026-09-24', '2026-09-25', '2026-09-26'],
    'rows': [
      {
        'truckRefId': 5,
        'truckName': 'WLN 1234',
        'truckNumber': 'T5',
        'truckType': 'PRIME',
        'truckStatus': 'ACTIVE',
        'locations': ['PORT KLANG', '', '', '', '', '', ''],
        'lastKnownLocation': 'PORT KLANG',
        'done': true,
        'doneDays': [false, false, false, false, false, false, false],
      }
    ],
  };

  test('the week is a GET with the company and date, read from camelCase', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'Data1': weekJson})));

    final week = TruckLocationJson.week(
        await remote.week(TruckLocationJson.weekQuery(companyId: 6, date: '2026-09-23')));

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.uri.toString(),
        'https://java.test/api/truck-locations/week?companyRefId=6&date=2026-09-23');
    expect(week.weekStart, '2026-09-20');
    expect(week.days, hasLength(7));
    expect(week.rows.single.truckName, 'WLN 1234');
    expect(week.rows.single.locations.first, 'PORT KLANG');
    expect(week.rows.single.done, isTrue);
  });

  test('save all posts the changed cells and ticks; the order is its own call', () async {
    adapter.replies
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': weekJson})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': null})));

    await remote.saveWeek(TruckLocationJson.saveRequest(
      companyId: 6,
      weekStart: '2026-09-20',
      cells: const [TruckLocationCellChange(truckRefId: 5, planDate: '2026-09-21', location: 'JOHOR')],
      doneTicks: const [TruckLocationDoneTick(truckRefId: 5, done: true)],
    ));
    await remote.saveOrder(TruckLocationJson.orderRequest(companyId: 6, truckRefIds: [5, 3]));

    expect(adapter.requests.map((r) => '${r.method} ${r.uri.path}'),
        ['POST /api/truck-locations/week', 'POST /api/truck-locations/order']);
    expect(adapter.requests[0].data, {
      'companyRefId': 6,
      'weekStart': '2026-09-20',
      'cells': [{'truckRefId': 5, 'planDate': '2026-09-21', 'location': 'JOHOR'}],
      'doneTicks': [{'truckRefId': 5, 'done': true}],
      'dayDoneTicks': [],
    });
    expect(adapter.requests[1].data, {'companyRefId': 6, 'truckRefIds': [5, 3]});
  });

  test('a validation failure shows the server message and its details', () async {
    adapter.replies.add((400, jsonEncode({
      'status': 400,
      'message': 'Request validation failed',
      'details': ['weekStart: must not be null'],
    })));

    await expectLater(remote.saveWeek({}), throwsA(isA<ApiFailure>().having(
        (e) => e.message, 'message', 'Request validation failed\nweekStart: must not be null')));
  });
}
