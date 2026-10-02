import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Reading the Java backend's answers: `ApiResponse`
/// `{IsSuccess, StatusCode, Message, Data1}` on success, and either that or
/// `ApiError` `{status, error, message, details}` on failure.
class JavaResponse {
  JavaResponse._();

  /// `Data1` of a successful `ApiResponse`. Throws [ApiFailure] when the body
  /// is not one or says IsSuccess = false.
  static dynamic data(dynamic body) {
    if (body is! Map) {
      throw const ApiFailure('Unexpected response from server');
    }
    if (!JsonRead.boolean(body['IsSuccess'])) {
      throw ApiFailure(_messageOf(body) ?? 'Request failed', statusCode: JsonRead.intOrNull(body['StatusCode']));
    }
    return body['Data1'];
  }

  /// A Dio failure as an [ApiFailure], keeping the server's message (and the
  /// validation details of an `ApiError`) when it sent one.
  static ApiFailure fromDio(DioException error) {
    final code = error.response?.statusCode;
    final body = error.response?.data;
    final serverMessage = body is Map ? _messageOf(body) : null;
    if (serverMessage != null) {
      return ApiFailure(serverMessage, statusCode: code);
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiFailure('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const ApiFailure('No internet connection. Check your network.');
      default:
        return ApiFailure(code == null ? 'Server error occurred.' : 'Server error occurred. ($code)',
            statusCode: code);
    }
  }

  static String? _messageOf(Map<dynamic, dynamic> body) {
    final message = JsonRead.stringOrNull(body['Message']) ?? JsonRead.stringOrNull(body['message']);
    final details = body['details'];
    if (details is List && details.isNotEmpty) {
      final text = details.map((d) => d.toString()).join('\n');
      return message == null ? text : '$message\n$text';
    }
    return message;
  }
}
