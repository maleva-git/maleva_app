import 'package:dio/dio.dart';
import 'package:maleva/core/utils/json_read.dart';

/// A failed call to the legacy .NET API. [message] is what the server put in
/// ResponseViewModel.Message when it sent one, so a screen can show the real
/// reason ("Status 9 was not found for this company") instead of a status code.
class LegacyApiException implements Exception {
  const LegacyApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Helpers for the .NET ResponseViewModel envelope
/// `{IsSuccess, StatusCode, Message, Data1 ... Data11}`.
class LegacyResponse {
  LegacyResponse._();

  /// The envelope of a successful call. Throws [LegacyApiException] when the
  /// body is not an envelope or says IsSuccess = false.
  static Map<String, dynamic> envelope(dynamic body) {
    if (body is! Map) {
      throw const LegacyApiException('Unexpected response from server');
    }
    final map = Map<String, dynamic>.from(body);
    if (!JsonRead.boolean(map['IsSuccess'])) {
      throw LegacyApiException(
        _messageOf(map) ?? 'Request failed',
        statusCode: JsonRead.intOrNull(map['StatusCode']),
      );
    }
    return map;
  }

  /// A Dio failure as a [LegacyApiException], keeping the server's own message
  /// when the error response carried one (the IR endpoints answer 400/404 with
  /// the envelope in the body).
  static LegacyApiException fromDio(DioException error) {
    final code = error.response?.statusCode;
    final data = error.response?.data;
    final serverMessage = data is Map ? _messageOf(Map<String, dynamic>.from(data)) : null;
    if (serverMessage != null) {
      return LegacyApiException(serverMessage, statusCode: code);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const LegacyApiException('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const LegacyApiException('No internet connection. Check your network.');
      default:
        return LegacyApiException(
          code == null ? 'Server error occurred.' : 'Server error occurred. ($code)',
          statusCode: code,
        );
    }
  }

  static String? _messageOf(Map<String, dynamic> map) =>
      JsonRead.stringOrNull(map['Message']);
}
