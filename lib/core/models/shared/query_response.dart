import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class QueryResponse {
  final bool result;
  final String message;
  QueryResponse(this.result, this.message);
}