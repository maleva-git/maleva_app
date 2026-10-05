import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/lookups/location_api.dart';
import 'package:maleva/core/models/shared/location_model.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// The Location picker off .NET LocationApp/SelectLocation (location-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late LocationApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = LocationApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  test('the company locations read from the shared endpoint', () async {
    adapter.replies.add((200, jsonEncode({'success': true, 'statusCode': 200, 'message': 'ok', 'data': [
      {'id': 3, 'companyRefId': 6, 'location': 'PASIR GUDANG', 'active': 1},
    ]})));

    final rows = await api.locations();

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/location-master/company/6/active');
    final location = LocationModel.fromJava(rows.single);
    expect([location.Id, location.CompanyRefId, location.Location, location.Active], [3, 6, 'PASIR GUDANG', 1]);
  });

  test('a refusal is the server message', () async {
    adapter.replies.add((400, jsonEncode({'success': false, 'statusCode': 400,
      'message': 'Company ID must be a positive integer'})));

    expect(() => api.locations(),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Company ID must be a positive integer')));
  });
}
