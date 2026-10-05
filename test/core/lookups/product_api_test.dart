import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/lookups/product_api.dart';
import 'package:maleva/core/models/shared/product_model.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// The product picker reads the shared Java API directly (product-lookups-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late ProductApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = ProductApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  test('products read the Java fields, every price a number', () async {
    adapter.replies.add((200, jsonEncode([
      {'id': 8, 'productName': 'Diesel', 'productCode': 'D1', 'saleRate': 2.15, 'purRate': 2, 'mrp': 3},
    ])));

    final product = ProductModel.fromJava((await api.products()).single);

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/item-masters/company/6/products');
    expect([product.Id, product.ProductName, product.Productcode], [8, 'Diesel', 'D1']);
    expect([product.SaleRate, product.PurRate, product.MRP, product.WholeSaleRate, product.GST], [2.15, 2.0, 3.0, 0.0, 0.0]);
    expect([product.PrintName, product.Imagepath, product.CategoryId], ['', '', 0]);
  });

  test('a failure is the server message', () async {
    adapter.replies.add((500, jsonEncode({'message': 'Database unavailable'})));

    expect(() => api.products(), throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Database unavailable')));
  });
}
