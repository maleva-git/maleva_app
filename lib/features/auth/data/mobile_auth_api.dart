import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/features/auth/data/mobile_session.dart';

/// Why a sign-in or refresh did not give a session.
sealed class MobileAuthFailure implements Exception {
  const MobileAuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Sign-in answered 401: wrong user name or password, or an inactive account.
class InvalidCredentials extends MobileAuthFailure {
  const InvalidCredentials() : super('Invalid Username & Password');
}

/// Refresh answered 401: the session expired, was revoked, or the account was disabled.
class SessionEnded extends MobileAuthFailure {
  const SessionEnded() : super('Your session has ended. Please log in again.');
}

/// The server could not be reached or did not answer in time.
class ConnectionFailure extends MobileAuthFailure {
  const ConnectionFailure() : super('Unable to connect to the server. Please check your connection and try again.');
}

/// Any other error status or an unreadable answer.
class ServerFailure extends MobileAuthFailure {
  const ServerFailure(super.message);
}

/// The Java mobile-auth endpoints (backend change `add-mobile-auth-api`).
class MobileAuthApi {
  MobileAuthApi(this._client);

  static const loginPath = '/api/mobile/auth/login';
  static const refreshPath = '/api/mobile/auth/refresh';
  static const logoutPath = '/api/mobile/auth/logout';
  static const deviceTokenPath = '/api/mobile/auth/device-token';

  final JavaApiClient _client;

  /// Credentials go in the JSON body only - never in the URL.
  Future<MobileSession> signIn({
    required String userName,
    required String password,
    required bool driver,
    String? deviceToken,
  }) {
    final body = <String, dynamic>{
      'userName': userName,
      'password': password,
      'driver': driver,
      if (deviceToken != null && deviceToken.isNotEmpty) 'deviceToken': deviceToken,
    };
    return _session(
      () => _client.dio.post<dynamic>(loginPath, data: body, options: _public()),
      on401: const InvalidCredentials(),
    );
  }

  /// Exchanges [token] for a new session. Sent explicitly, not by the client's
  /// interceptor, so a refresh never triggers another refresh.
  Future<MobileSession> refresh(String token) => _session(
        () => _client.dio.post<dynamic>(refreshPath,
            options: _public(headers: {'Authorization': 'Bearer $token'})),
        on401: const SessionEnded(),
      );

  /// Revokes [token] on the server. With this phone's [deviceToken] the server
  /// clears the push token only while it is still this phone's, so signing out
  /// here never silences the same user's other phone. Throws on failure;
  /// callers treat sign-out as best effort.
  Future<void> logout(String token, {String? deviceToken}) async {
    try {
      await _client.dio.post<dynamic>(logoutPath,
          data: {if (deviceToken != null && deviceToken.isNotEmpty) 'deviceToken': deviceToken},
          options: _public(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      throw _failure(e, on401: const SessionEnded());
    }
  }

  /// Records this phone's current push token for the session's user, so
  /// notifications reach the phone after Firebase replaces its token.
  Future<void> updateDeviceToken(String token, String deviceToken) async {
    try {
      await _client.dio.post<dynamic>(deviceTokenPath,
          data: {'deviceToken': deviceToken},
          options: _public(headers: {'Authorization': 'Bearer $token'}));
    } on DioException catch (e) {
      throw _failure(e, on401: const SessionEnded());
    }
  }

  Options _public({Map<String, dynamic>? headers}) =>
      Options(headers: headers, extra: {JavaApiClient.publicRequest: true});

  Future<MobileSession> _session(Future<Response<dynamic>> Function() call,
      {required MobileAuthFailure on401}) async {
    final Response<dynamic> response;
    try {
      response = await call();
    } on DioException catch (e) {
      throw _failure(e, on401: on401);
    }
    final body = response.data;
    if (body is! Map || (body['IsSuccess'] != true && body['IsSuccess']?.toString() != 'true')) {
      throw ServerFailure(body is Map ? body['Message']?.toString() ?? 'Login failed' : 'Login failed');
    }
    final data = body['Data1'];
    if (data is! Map) {
      throw const ServerFailure('The server sent no session');
    }
    try {
      return MobileSession.fromJson(Map<String, dynamic>.from(data));
    } on FormatException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  static MobileAuthFailure _failure(DioException e, {required MobileAuthFailure on401}) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ConnectionFailure();
      default:
        break;
    }
    final status = e.response?.statusCode;
    if (status == 401) return on401;
    final data = e.response?.data;
    final message = data is Map ? data['Message']?.toString() : null;
    return ServerFailure(message ?? 'Server error${status == null ? '' : ' ($status)'}');
  }
}
