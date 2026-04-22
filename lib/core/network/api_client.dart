import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/Material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import '../utils/app_preferences.dart';

class ApiClient {
  ApiClient._();

  // ─── Timeout config ───────────────────────────────────────────────────────
  static const Duration _kTimeout = Duration(seconds: 30);
  static const Duration _kUploadTimeout = Duration(seconds: 60);

  // ─── Auth headers build ───────────────────────────────────────────────────
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

  // ─── POST ─────────────────────────────────────────────────────────────────
  // Returns: List<dynamic> | Map<String,dynamic> | String | int
  static Future<dynamic> postRequest(
      String url,
      dynamic bodyData, {
        Map<String, String>? headers,
        bool skipAuth = false,
      }) async {
    try {
      final finalHeaders = skipAuth
          ? (headers ?? {'Content-Type': 'application/json; charset=UTF-8'})
          : _buildHeaders(extra: headers);

      final body = bodyData != null ? json.encode(bodyData) : null;

      if (kDebugMode) {
        debugPrint("🚀 API REQUEST");
        debugPrint("➡️ URL: $url");
        debugPrint("➡️ Headers: $finalHeaders");
        debugPrint("➡️ Body: $body");
      }

      final response = await http
          .post(
        Uri.parse(url),
        headers: finalHeaders,
        body: body,
      )
          .timeout(_kTimeout);

      if (kDebugMode) {
        debugPrint("✅ API RESPONSE");
        debugPrint("⬅️ Status Code: ${response.statusCode}");
        debugPrint("⬅️ Body: ${response.body}");
      }

      return _handleResponse(response);

    } on SocketException {
      if (kDebugMode) debugPrint("❌ No Internet Connection");
      throw Exception('No internet connection. Check your network.');
    } on TimeoutException {
      if (kDebugMode) debugPrint("❌ Request timed out: $url");
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      if (kDebugMode) debugPrint("❌ API ERROR: $e");
      rethrow;
    }
  }

  // ─── GET ──────────────────────────────────────────────────────────────────
  static Future<String> getString(String url) async {
    try {
      final response = await http.post(Uri.parse(url)).timeout(_kTimeout);
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

  // ─── File / Image Upload ──────────────────────────────────────────────────
  static Future<String> uploadImage(
      File imageFile,
      String uploadUrl, {
        required int comId,
        required int id,
        required String folderName,
        required String subFolderName,
      }) async {
    try {
      final stream      = http.ByteStream(imageFile.openRead());
      final length      = await imageFile.length();
      final fileName    = basename(imageFile.path);
      final request     = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      final multipart   = http.MultipartFile(
        'MyImages0', stream, length,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipart);
      request.headers.addAll({
        'Comid':         comId.toString(),
        'Id':            id.toString(),
        'FolderName':    folderName,
        'FileName':      fileName,
        'SubFolderName': subFolderName,
      });
      final response = await http.Response.fromStream(
        await request.send().timeout(_kUploadTimeout),
      );
      if (response.statusCode == 200) {
        String name = response.body;
        if (name.startsWith('"')) name = name.substring(1);
        if (name.endsWith('"'))   name = name.substring(0, name.length - 1);
        return name;
      }
      return '';
    } on TimeoutException {
      throw Exception('Image upload timed out.');
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  static Future<String> uploadPdfOrFile(
      File file,
      String uploadUrl, {
        required int comId,
        required int id,
        required String folderName,
        required String subFolderName,
      }) async {
    try {
      final stream    = http.ByteStream(file.openRead());
      final length    = await file.length();
      final fileName  = basename(file.path);
      final request   = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      final multipart = http.MultipartFile(
        'MyFiles0', stream, length,
        filename: fileName,
        contentType: MediaType('application', 'octet-stream'),
      );
      request.files.add(multipart);
      request.headers.addAll({
        'Comid':         comId.toString(),
        'Id':            id.toString(),
        'FolderName':    folderName,
        'FileName':      fileName,
        'SubFolderName': subFolderName,
      });
      final response = await http.Response.fromStream(
        await request.send().timeout(_kUploadTimeout),
      );
      if (response.statusCode == 200) {
        String name = response.body;
        if (name.startsWith('"')) name = name.substring(1);
        if (name.endsWith('"'))   name = name.substring(0, name.length - 1);
        return name;
      }
      return '';
    } on TimeoutException {
      throw Exception('File upload timed out.');
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  // ─── Response Handler ─────────────────────────────────────────────────────
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
        final body = jsonDecode(response.body);
        throw Exception(body['Message'] ?? 'Server error occurred.');
      default:
        throw Exception('${response.statusCode} Unknown error occurred.');
    }
  }
}