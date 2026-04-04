
import 'package:intl/intl.dart';

abstract class BoardingStatusState {}

class BoardingStatusInitial extends BoardingStatusState {}

class BoardingStatusLoading extends BoardingStatusState {}

class BoardingStatusLoaded extends BoardingStatusState {
  // ── Job No lookup ─────────────────────────────────────────────────────────
  final String billType;
  final String jobNoText;
  final int    saleOrderId;
  final List<dynamic> jobNoSuggestions;

  // ── Status ────────────────────────────────────────────────────────────────
  final int    statusId;
  final String statusName;

  // ── DateTime fields ───────────────────────────────────────────────────────
  final String startTime;
  final bool   startTimeEnabled;
  final String endTime;
  final bool   endTimeEnabled;

  // ── Image ─────────────────────────────────────────────────────────────────
  final bool         imageUploadEnabled;
  final List<String> images;

   BoardingStatusLoaded({
    required this.billType,
    required this.jobNoText,
    required this.saleOrderId,
    required this.jobNoSuggestions,
    required this.statusId,
    required this.statusName,
    required this.startTime,
    required this.startTimeEnabled,
    required this.endTime,
    required this.endTimeEnabled,
    required this.imageUploadEnabled,
    required this.images,
  });

  BoardingStatusLoaded copyWith({
    String? billType,
    String? jobNoText,
    int?    saleOrderId,
    List<dynamic>? jobNoSuggestions,
    int?    statusId,
    String? statusName,
    String? startTime,
    bool?   startTimeEnabled,
    String? endTime,
    bool?   endTimeEnabled,
    bool?   imageUploadEnabled,
    List<String>? images,
  }) {
    return BoardingStatusLoaded(
      billType:           billType           ?? this.billType,
      jobNoText:          jobNoText          ?? this.jobNoText,
      saleOrderId:        saleOrderId        ?? this.saleOrderId,
      jobNoSuggestions:   jobNoSuggestions   ?? this.jobNoSuggestions,
      statusId:           statusId           ?? this.statusId,
      statusName:         statusName         ?? this.statusName,
      startTime:          startTime          ?? this.startTime,
      startTimeEnabled:   startTimeEnabled   ?? this.startTimeEnabled,
      endTime:            endTime            ?? this.endTime,
      endTimeEnabled:     endTimeEnabled     ?? this.endTimeEnabled,
      imageUploadEnabled: imageUploadEnabled ?? this.imageUploadEnabled,
      images:             images             ?? this.images,
    );
  }

  static String _now() =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  factory BoardingStatusLoaded.empty() => BoardingStatusLoaded(
    billType:           '0',
    jobNoText:          '',
    saleOrderId:        0,
    jobNoSuggestions:   [],
    statusId:           0,
    statusName:         '',
    startTime:          _now(),
    startTimeEnabled:   false,
    endTime:            _now(),
    endTimeEnabled:     false,
    imageUploadEnabled: false,
    images:             [],
  );
}

class BoardingStatusError extends BoardingStatusState {
  final String message;
  BoardingStatusError(this.message);
}

class BoardingStatusSaveSuccess extends BoardingStatusState {}

// Navigate to SaleOrderDetails after VIEW button
class BoardingStatusNavigateToDetails extends BoardingStatusState {}