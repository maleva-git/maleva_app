import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/session/session_token_store.dart';

/// Refreshes the session; true when a new token is stored.
typedef SessionRefresher = Future<bool> Function();

/// The HTTP client for the Java (Spring) backend.
///
/// Separate from [ApiClient] and [DioClient] on purpose: only this client
/// knows the Java session token, so the token never reaches the .NET host,
/// and the legacy clients' headers stay exactly as before.
///
/// - Adds `Authorization: Bearer <token>` to every request except those
///   marked [publicRequest] (sign-in).
/// - On a 401 it asks [onRefresh] once - shared by every request that fails at
///   the same time - and retries the request once with the new token. When
///   the refresh fails it calls [onSessionEnded] and passes the 401 on.
class JavaApiClient {
  JavaApiClient(this._tokens, {Dio? dio, String? baseUrl})
      : dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = baseUrl ?? AppConfig.javaBaseUrl
      ..connectTimeout = const Duration(seconds: 20)
      ..receiveTimeout = const Duration(seconds: 30)
      ..contentType = Headers.jsonContentType
      ..responseType = ResponseType.json;
    this.dio.interceptors.add(InterceptorsWrapper(onRequest: _addToken, onError: _refreshOn401));
    if (kDebugMode) {
      // the request line and status only: no headers (token), no bodies (password)
      this.dio.interceptors.add(LogInterceptor(requestHeader: false, requestBody: false, responseHeader: false));
    }
  }

  /// `Options.extra` key: true sends the request without the session token
  /// and never refreshes on its 401 (sign-in, refresh).
  static const publicRequest = 'javaPublicRequest';

  /// `Options.extra` key set on the single retry after a refresh.
  static const _retried = 'javaRetried';

  final Dio dio;
  final SessionTokenStore _tokens;

  /// Set by the session service; null means 401s are passed on as they are.
  SessionRefresher? onRefresh;

  /// Called when a refresh after a 401 failed: the session is over.
  VoidCallback? onSessionEnded;

  Future<bool>? _refreshing;

  Future<void> _addToken(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[publicRequest] != true) {
      final token = await _tokens.token();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _refreshOn401(DioException error, ErrorInterceptorHandler handler) async {
    final options = error.requestOptions;
    final refresh = onRefresh;
    if (error.response?.statusCode != 401 ||
        options.extra[publicRequest] == true ||
        options.extra[_retried] == true ||
        refresh == null) {
      return handler.next(error);
    }
    final refreshed = await (_refreshing ??= refresh().whenComplete(() => _refreshing = null));
    if (!refreshed) {
      onSessionEnded?.call();
      return handler.next(error);
    }
    try {
      options.extra[_retried] = true;
      options.headers.remove('Authorization');
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
