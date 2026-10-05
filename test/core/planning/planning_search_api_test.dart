import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/access/screen_access_api.dart';
import 'package:maleva/core/planning/planning_api.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// The plan screen's calls, sent as the web's live page sends them (change planning-rti-phone-tablet).
void main() {
  late QueueAdapter adapter;
  late PlanningApi api;
  late Dio dio;

  setUp(() {
    adapter = QueueAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter;
    api = PlanningApi(dio, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;

  test('search sends helpers.ts buildSearchPayload and unwraps like normalizePlanningSearchResponse', () async {
    adapter.replies
      ..add((200, jsonEncode([{'Id': 40, 'JobNo': 'TR1'}])))
      ..add((200, jsonEncode({'data1': [{'Id': 41}]})))
      ..add((200, jsonEncode({'data': {'rows': [{'Id': 42}]}})))
      ..add((200, jsonEncode({'other': 1})));
    expect((await api.searchPlanning(search: ' PKG,WPK ', employeeId: 12, fromDate: '2026-10-05', toDate: '')).single['Id'], 40);
    expect(last().uri.toString(), 'https://java.test/api/planing/search');
    expect(last().data, {'comid': 6, 'search': 'PKG,WPK', 'employeeid': 12, 'fromdate': '2026-10-05', 'todate': ''});
    expect((await api.searchPlanning()).single['Id'], 41);
    expect((await api.searchPlanning()).single['Id'], 42);
    expect(await api.searchPlanning(), isEmpty);
  });

  test('edit by plan number, RTI status and the RTI batch', () async {
    adapter.replies
      ..add((200, jsonEncode({'Id': 782})))
      ..add((200, jsonEncode([{'saleOrderMasterRefId': 40, 'rtiMasterRefId': 9, 'rtiNo': 'RTI000000009'}])))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'planningId': 782, 'groups': []}})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'jobsCreated': 2}})));
    expect((await api.editByNumber(782))['Id'], 782);
    expect(last().uri.toString(), 'https://java.test/api/planing/edit?companyId=6&planningNo=782');
    expect((await api.rtiStatus([40, 0, 40, -1])).single['rtiNo'], 'RTI000000009');
    expect(last().data, [40]);
    expect(await api.rtiStatus([0]), isEmpty);
    expect((await api.rtiBatchPreview(782, includeExisting: true))['planningId'], 782);
    expect(last().uri.toString(), 'https://java.test/api/planing/782/rti-batch/preview?companyId=6&includeExisting=true');
    expect((await api.rtiBatchCreate(782, {'companyRefId': 6}))['jobsCreated'], 2);
    expect(last().method, 'POST');
  });

  test('screen access reads the actions', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'Data1': {'screen': 'planning', 'roleId': 200, 'actions': ['VIEW', 'EDIT']}})));
    final access = await ScreenAccessApi(dio, companyId: () => 6).mine('planning');
    expect(last().uri.toString(), 'https://java.test/api/screen-access/planning/me?companyRefId=6');
    expect(access.has('EDIT'), isTrue);
    expect(access.has('DELETE'), isFalse);
    expect(access.roleId, 200);
  });
}
