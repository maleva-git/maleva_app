import 'package:dio/dio.dart';
import 'package:maleva/core/utils/session_manager.dart';

class DioClient {
  late final Dio _dio;
  final SessionManager _sessionManager;

  DioClient(this._sessionManager) {
    _dio = Dio(
      BaseOptions(
        // We will define the base URL or rely on passing full URLs for now, 
        // depending on how the app is structured.
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
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
}
