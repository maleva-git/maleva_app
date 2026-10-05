import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee/google_review_api.dart';
import 'package:maleva/core/models/shared/review.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// Staff Google reviews on the shared Java API (google-review-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late GoogleReviewApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = GoogleReviewApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;

  test('list, save and delete', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([
        {'id': 31, 'refDate': '2026-10-05', 'employeeRefId': 15, 'employeeName': 'ANNA', 'googleReview': 3,
         'googleMsg': 'GOOD', 'shopName': 'ACME', 'mobileNo': '6012'}
      ]))))
      ..add((200, jsonEncode(ok(31))))
      ..add((200, jsonEncode(ok(31))));

    final rows = await api.list(fromDate: '2026-10-01', toDate: '2026-10-05', employeeId: 15);
    expect(last().uri.toString(), 'https://java.test/api/google-reviews?companyId=6&fromDate=2026-10-01&toDate=2026-10-05&employeeId=15');
    final r = Review.fromJava(rows.single);
    expect([r.id, r.shopName, r.googleReview, r.empReffid, r.employeeName], [31, 'ACME', '3', 15, 'ANNA']);
    expect(r.supportDate, DateTime(2026, 10, 5));

    expect(await api.save(refDate: '2026-10-05', employeeId: 15, googleReview: 3, googleMsg: 'GOOD', shopName: 'ACME', mobileNo: '6012'), 31);
    expect(last().uri.toString(), 'https://java.test/api/google-reviews?companyId=6');
    expect(last().data, {'id': 0, 'refDate': '2026-10-05', 'employeeRefId': 15, 'googleReview': 3, 'googleMsg': 'GOOD',
      'shopName': 'ACME', 'mobileNo': '6012'});

    await api.delete(31);
    expect(last().method, 'DELETE');
    expect(last().uri.toString(), 'https://java.test/api/google-reviews/31?companyId=6');
  });

  test('a refusal is the server message', () async {
    adapter.replies.add((400, jsonEncode({'status': 400, 'message': 'Select the staff'})));
    expect(() => api.save(refDate: '2026-10-05', employeeId: 0, googleReview: 1, googleMsg: '', shopName: '', mobileNo: ''),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Select the staff')));
  });
}
