import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/network/java_route.dart';
import 'package:maleva/core/network/legacy_call_adapter.dart';
import 'package:maleva/core/utils/session_manager.dart';

class DioClient {
  late final Dio _dio;
  final SessionManager _sessionManager;
  final JavaApiClient? _javaClient;

  DioClient(this._sessionManager, {JavaApiClient? java}) : _javaClient = java {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    _dio.interceptors.add(

      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // A call to a controller that has moved to Java goes there instead,
          // through the Java client (session token, refresh on 401).
          // an old lookup or fuel call answered by the shared Java APIs
          final url = options.uri.toString();
          if (LegacyCallAdapter.handles(url)) {
            try {
              final answer = await LegacyCallAdapter.asResponse(url, body: options.data, headers: options.headers);
              return handler.resolve(Response<dynamic>(requestOptions: options, statusCode: 200, data: answer.data), true);
            } on DioException catch (e) {
              return handler.reject(
                  DioException(
                      requestOptions: options,
                      type: e.type,
                      message: e.message,
                      response: Response<dynamic>(
                          requestOptions: options, statusCode: e.response?.statusCode, data: e.response?.data)),
                  true);
            }
          }
          final target = JavaRoute.resolve(url);
          if (JavaRoute.isJava(target)) {
            return _sendToJava(target, options, handler);
          }
          // Automatically inject the token if it exists
          final token = _sessionManager.mobileToken;
          if (token.isNotEmpty) {
            options.headers['Token'] = token;
          }
          return handler.next(options); // Continue
        },
        onResponse: (response, handler) {
          // You can log responses here if needed
          return handler.next(response); // Continue
        },
        onError: (DioException e, handler) {
          // You can handle global errors here (e.g., token expired -> logout)
          return handler.next(e); // Continue
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Dio get dio => _dio;

  /// Sends [options] to [target] on the Java client and completes the
  /// original request with its answer. The legacy `Token` header stays
  /// behind; the caller's own headers (such as `Comid`) go along.
  Future<void> _sendToJava(String target, RequestOptions options, RequestInterceptorHandler handler) async {
    final java = (_javaClient ?? GetIt.instance<JavaApiClient>()).dio;
    final headers = Map<String, dynamic>.from(options.headers)
      ..removeWhere((k, _) => const {'token', 'authorization'}.contains(k.toLowerCase()));
    try {
      final response = await java.request<dynamic>(target,
          data: options.data,
          options: Options(
              method: options.method,
              headers: headers,
              responseType: options.responseType,
              contentType: options.contentType));
      handler.resolve(
          Response<dynamic>(
              requestOptions: options,
              data: response.data,
              statusCode: response.statusCode,
              statusMessage: response.statusMessage,
              headers: response.headers),
          true);
    } on DioException catch (e) {
      final answer = e.response;
      handler.reject(
          DioException(
              requestOptions: options,
              type: e.type,
              error: e.error,
              message: e.message,
              response: answer == null
                  ? null
                  : Response<dynamic>(
                      requestOptions: options,
                      data: answer.data,
                      statusCode: answer.statusCode,
                      statusMessage: answer.statusMessage,
                      headers: answer.headers)),
          true);
    }
  }
}
