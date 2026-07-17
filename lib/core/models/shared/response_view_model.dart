import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ResponseViewModel {
  bool IsSuccess;
  int StatusCode;
  String Message;
  dynamic data1;
  dynamic data2;
  dynamic data3;
  dynamic data4;
  dynamic data5;
  dynamic data6;
  dynamic data7;
  dynamic data8;
  dynamic data9;
  dynamic data10;
  dynamic data11;

  ResponseViewModel(
      this.IsSuccess,
      this.StatusCode,
      this.Message,
      this.data1,
      this.data2,
      this.data3,
      this.data4,
      this.data5,
      this.data6,
      this.data7,
      this.data8,
      this.data9,
      this.data10,
      this.data11,
      );

  ResponseViewModel.fromJson(Map<String, dynamic> json)
  // FIX: json['IsSuccess'] may come as bool OR int (0/1) from some servers
      : IsSuccess = _parseBool(json['IsSuccess']),
  // FIX: int.parse("null") → FormatException on first launch (null FCM token)
  //      int.tryParse returns null for invalid input; fallback to 0
        StatusCode = int.tryParse(json['StatusCode']?.toString() ?? '') ?? 0,
  // FIX: avoid calling .toString() on null → use null-aware operator
        Message = json['Message']?.toString() ?? '',
        data1  = _parseData(json['Data1']),
        data2  = _parseData(json['Data2']),
        data3  = _parseData(json['Data3']),
        data4  = _parseData(json['Data4']),
        data5  = _parseData(json['Data5']),
        data6  = _parseData(json['Data6']),
        data7  = _parseData(json['Data7']),
        data8  = _parseData(json['Data8']),
        data9  = _parseData(json['Data9']),
        data10 = _parseData(json['Data10']),
        data11 = _parseData(json['Data11']);

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Handles bool, int (1/0), and String ("true"/"false"/"1"/"0").
  /// Falls back to false so IsSuccess is never null.
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final s = value.toString().toLowerCase();
    if (s == 'true' || s == '1') return true;
    return false;
  }

  /// Returns an empty List when data is null so callers can safely do
  /// data1[0] without a null-check, matching your existing usage.
  static dynamic _parseData(dynamic data) {
    if (data == null) return [];
    if (data is List) return List<dynamic>.from(data);
    return data;
  }
}