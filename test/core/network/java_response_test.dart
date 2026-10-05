import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';

void main() {
  test('Data1 of a successful ApiResponse', () {
    expect(JavaResponse.data({'IsSuccess': true, 'Message': 'ok', 'Data1': [1]}), [1]);
  });

  test('IsSuccess false or not an ApiResponse throws with the message', () {
    expect(() => JavaResponse.data({'IsSuccess': false, 'StatusCode': 200, 'Message': 'No such job'}),
        throwsA(isA<ApiFailure>().having((e) => e.message, 'message', 'No such job')));
    expect(() => JavaResponse.data('oops'), throwsA(isA<ApiFailure>()));
  });

  test('a timeout and a connection error read like the legacy messages', () {
    final options = RequestOptions(path: '/x');
    expect(JavaResponse.fromDio(DioException(requestOptions: options, type: DioExceptionType.receiveTimeout)).message,
        'Request timed out. Please try again.');
    expect(JavaResponse.fromDio(DioException(requestOptions: options, type: DioExceptionType.connectionError)).message,
        'No internet connection. Check your network.');
  });
}
