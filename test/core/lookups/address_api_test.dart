import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/lookups/address_api.dart';
import 'package:maleva/core/models/shared/address_details_model.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Address pickers read the shared Java APIs directly (address-lookups-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late AddressApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = AddressApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  test('address names are distinct and sorted without case', () async {
    adapter.replies.add((200, jsonEncode({'ok': true, 'count': 3, 'data': [
      {'name': 'port klang'}, {'name': 'Johor'}, {'name': 'port klang'}, {'name': null},
    ]})));

    expect(await api.names(), ['Johor', 'port klang']);
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/addresses/company/6/active');
  });

  test('a search reads the Java rows; the keyword is trimmed', () async {
    adapter.replies.add((200, jsonEncode({'ok': true, 'count': 1, 'data': [
      {'id': 1, 'name': 'Johor', 'address': 'Pasir Gudang', 'phone': '07', 'active': 1},
    ]})));

    final address = AddressDetailsModel.fromJava((await api.search(' joh ')).single);

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/addresses/company/6/search?keyword=joh');
    expect([address.Id, address.Name, address.Address, address.Phone, address.Active], [1, 'Johor', 'Pasir Gudang', '07', 1]);
  });

  test('a refusal is the server message', () async {
    adapter.replies.add((400, jsonEncode({'ok': false, 'message': 'Company is required'})));

    expect(() => api.search(), throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Company is required')));
  });
}
