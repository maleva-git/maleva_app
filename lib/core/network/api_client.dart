import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:get_it/get_it.dart';
import '../utils/app_preferences.dart';
import 'java_api_client.dart';
import 'java_route.dart';
import 'api_failure.dart';
import 'legacy_call_adapter.dart';

class ApiClient {
  ApiClient._();

  // â”€â”€â”€ Timeout config â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const Duration _kTimeout = Duration(seconds: 30);

  // â”€â”€â”€ Auth headers build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Map<String, String> _buildHeaders({Map<String, String>? extra}) {
    final token = AppPreferences.getTokenKey();
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      headers['Userid']        = AppPreferences.getUserId();
      headers['Profile']       = AppPreferences.getProfile();
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  static Future<dynamic> postRequest(
      String url,
      dynamic bodyData, {
        Map<String, String>? headers,
        bool skipAuth = false,
      }) async {
    // an old lookup or fuel call answered by the shared Java APIs
    if (LegacyCallAdapter.handles(url)) {
      try {
        return await LegacyCallAdapter.answer(url, body: bodyData, headers: headers);
      } on ApiFailure catch (e) {
        throw Exception(e.message);
      }
    }
    try {
      url = JavaRoute.resolve(url);
      // the legacy auth headers are for .NET only; Java gets the session token
      final finalHeaders = skipAuth || JavaRoute.isJava(url)
          ? (headers ?? {'Content-Type': 'application/json; charset=UTF-8'})
          : _buildHeaders(extra: headers);

      final body = bodyData != null ? json.encode(bodyData) : null;

      if (kDebugMode) {
        print("--- API REQUEST ---");
        print("URI: $url");
        print("Headers: $finalHeaders");
        print("Payload: $body-------------------");
      }

      final response = JavaRoute.isJava(url)
          ? await _javaPost(url, bodyData, headers)
          : await http
              .post(
                Uri.parse(url),
                headers: finalHeaders,
                body: body,
              )
              .timeout(_kTimeout);

      if (kDebugMode) {
        debugPrint("âœ… API RESPONSE");
        debugPrint("â¬…ï¸ Status Code: ${response.statusCode}");
        print("Payload: $body-------------------");
      }

      return _handleResponse(response);

    } on SocketException {
      if (kDebugMode) debugPrint("âŒ No Internet Connection");
      throw Exception('No internet connection. Check your network.');
    } on TimeoutException {
      if (kDebugMode) debugPrint("âŒ Request timed out: $url");
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      if (kDebugMode) debugPrint("âŒ API ERROR: $e");
      rethrow;
    }
  }

  // â”€â”€â”€ GET â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static Future<String> getString(String url) async {
    if (LegacyCallAdapter.handles(url)) {
      try {
        return (await LegacyCallAdapter.answer(url)).toString();
      } on ApiFailure catch (e) {
        throw Exception(e.message);
      }
    }
    try {
      url = JavaRoute.resolve(url);
      final response = JavaRoute.isJava(url)
          ? await _javaPost(url, null, null)
          : await http.post(Uri.parse(url)).timeout(_kTimeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body).toString();
      }
      throw Exception('Failed to get string from $url');
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out.');
    }
  }

  // â”€â”€â”€ File / Image Upload â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  /// A request to the Java backend, through [JavaApiClient] (session token,
  /// refresh on 401), answered as an [http.Response] so the callers' status
  /// handling stays the same. Only the caller's own headers (such as `Comid`)
  /// are passed on; the legacy auth headers never reach Java.
  static Future<http.Response> _javaPost(String url, dynamic body, Map<String, String>? headers) async {
    final client = GetIt.instance<JavaApiClient>().dio;
    final passOn = <String, dynamic>{...?headers}
      ..removeWhere((k, _) => const {'authorization', 'content-type', 'userid', 'profile'}.contains(k.toLowerCase()));
    try {
      final r = await client.post<String>(url,
          data: body, options: dio.Options(headers: passOn, responseType: dio.ResponseType.plain));
      return http.Response.bytes(utf8.encode(r.data ?? ''), r.statusCode ?? 200);
    } on dio.DioException catch (e) {
      final r = e.response;
      if (r != null) {
        return http.Response.bytes(utf8.encode(r.data?.toString() ?? ''), r.statusCode ?? 500);
      }
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        throw TimeoutException('Request timed out', _kTimeout);
      }
      throw const SocketException('No internet connection');
    }
  }

  // â”€â”€â”€ Response Handler â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        if (response.body.isEmpty) return [];
        return jsonDecode(response.body);
      case 401:
        throw Exception('Authentication failed. Please re-login.');
      case 406:
        throw Exception('Already logged in on another device. Re-login or change password.');
      case 404:
      case 500:
        String errorMsg = 'Server error occurred. (${response.statusCode})';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body.containsKey('Message') && body['Message'] != null) {
            errorMsg = body['Message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      default:
        throw Exception('${response.statusCode} Unknown error occurred.');
    }
  }
}
