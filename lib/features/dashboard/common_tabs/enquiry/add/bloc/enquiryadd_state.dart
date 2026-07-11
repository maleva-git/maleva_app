

import 'package:intl/intl.dart';

enum AddEnquiryStatus { initial, loading, success, error }

class AddEnquiryState {
  final AddEnquiryStatus status;

  // Form fields
  final int editId;
  final int custId;
  final String customerName;
  final int jobTypeId;
  final String jobTypeName;
  final String lVessel;
  final String oVessel;
  final String lPort;
  final String oPort;

  // Dates
  final String notifyDate;
  final String collectionDate;
  final String lETADate;
  final String oETADate;

  // Checkboxes
  final bool checkCollection;
  final bool checkLETA;
  final bool checkOETA;

  // Error / success message
  final String? errorMessage;
  final String? successMessage;

  const AddEnquiryState({
    this.status = AddEnquiryStatus.initial,
    this.editId = 0,
    this.custId = 0,
    this.customerName = '',
    this.jobTypeId = 0,
    this.jobTypeName = '',
    this.lVessel = '',
    this.oVessel = '',
    this.lPort = '',
    this.oPort = '',
    this.notifyDate = '',
    this.collectionDate = '',
    this.lETADate = '',
    this.oETADate = '',
    this.checkCollection = false,
    this.checkLETA = false,
    this.checkOETA = false,
    this.errorMessage,
    this.successMessage,
  });

  AddEnquiryState copyWith({
    AddEnquiryStatus? status,
    int? editId,
    int? custId,
    String? customerName,
    int? jobTypeId,
    String? jobTypeName,
    String? lVessel,
    String? oVessel,
    String? lPort,
    String? oPort,
    String? notifyDate,
    String? collectionDate,
    String? lETADate,
    String? oETADate,
    bool? checkCollection,
    bool? checkLETA,
    bool? checkOETA,
    String? errorMessage,
    String? successMessage,
  }) {
    return AddEnquiryState(
      status: status ?? this.status,
      editId: editId ?? this.editId,
      custId: custId ?? this.custId,
      customerName: customerName ?? this.customerName,
      jobTypeId: jobTypeId ?? this.jobTypeId,
      jobTypeName: jobTypeName ?? this.jobTypeName,
      lVessel: lVessel ?? this.lVessel,
      oVessel: oVessel ?? this.oVessel,
      lPort: lPort ?? this.lPort,
      oPort: oPort ?? this.oPort,
      notifyDate: notifyDate ?? this.notifyDate,
      collectionDate: collectionDate ?? this.collectionDate,
      lETADate: lETADate ?? this.lETADate,
      oETADate: oETADate ?? this.oETADate,
      checkCollection: checkCollection ?? this.checkCollection,
      checkLETA: checkLETA ?? this.checkLETA,
      checkOETA: checkOETA ?? this.checkOETA,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  // Helper — DateTime format
  static String now() =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  static AddEnquiryState initial() => AddEnquiryState(
    notifyDate: now(),
    collectionDate: now(),
    lETADate: now(),
    oETADate: now(),
  );
}