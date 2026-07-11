

import 'package:equatable/equatable.dart';

enum JobStatusUpdateStatus { initial, loading, success, failure }

/// Distinct UI actions the BLoC emits once so the View can react
/// (show overlay, navigate, etc.) without storing UI logic in state.
enum JobStatusUpdateAction {
  none,
  showAutocomplete,
  hideAutocomplete,
  navigateToDetails,
  navigateToStatusSearch,
  resetAndReload,
}

class JobStatusUpdateState extends Equatable {
  const JobStatusUpdateState({
    this.status = JobStatusUpdateStatus.initial,
    this.action = JobStatusUpdateAction.none,
    this.errorMessage = '',

    // ─── Form fields ─────────────────────────────────────────────────────────
    this.billType = '0',
    this.jobNo = '',
    this.saleOrderId = 0,
    this.statusName = '',
    this.statusId = 0,
    this.userName = '',

    // ─── Checkboxes ──────────────────────────────────────────────────────────
    this.checkBoxStartTime = false,
    this.checkBoxEndTime = false,
    this.checkBoxImageUpload = false,

    // ─── Date/time ───────────────────────────────────────────────────────────
    this.dtpStartTime = '',
    this.dtpEndTime = '',

    // ─── Images ──────────────────────────────────────────────────────────────
    this.imageNetworkNames = const [],

    // ─── Autocomplete ────────────────────────────────────────────────────────
    this.autocompleteSuggestions = const [],
    this.showAutocompleteOverlay = false,
  });

  final JobStatusUpdateStatus status;
  final JobStatusUpdateAction action;
  final String errorMessage;

  // Form
  final String billType;
  final String jobNo;
  final int saleOrderId;
  final String statusName;
  final int statusId;
  final String userName;

  // Checkboxes
  final bool checkBoxStartTime;
  final bool checkBoxEndTime;
  final bool checkBoxImageUpload;

  // DateTime
  final String dtpStartTime;
  final String dtpEndTime;

  // Images
  final List<String> imageNetworkNames;

  // Autocomplete
  final List<Map<String, dynamic>> autocompleteSuggestions;
  final bool showAutocompleteOverlay;

  // ─── Computed ────────────────────────────────────────────────────────────

  bool get isFormReady =>
      jobNo.isNotEmpty &&
          saleOrderId != 0 &&
          (statusName.isNotEmpty || checkBoxStartTime || checkBoxEndTime || checkBoxImageUpload);

  List<Map<String, dynamic>> filteredSuggestions(String query) {
    if (query.isEmpty) return autocompleteSuggestions;
    final q = query.replaceAll(' ', '+').toUpperCase();
    return autocompleteSuggestions
        .where((e) => e['CNumber'].toString().toUpperCase().contains(q))
        .toList();
  }

  JobStatusUpdateState copyWith({
    JobStatusUpdateStatus? status,
    JobStatusUpdateAction? action,
    String? errorMessage,
    String? billType,
    String? jobNo,
    int? saleOrderId,
    String? statusName,
    int? statusId,
    String? userName,
    bool? checkBoxStartTime,
    bool? checkBoxEndTime,
    bool? checkBoxImageUpload,
    String? dtpStartTime,
    String? dtpEndTime,
    List<String>? imageNetworkNames,
    List<Map<String, dynamic>>? autocompleteSuggestions,
    bool? showAutocompleteOverlay,
  }) {
    return JobStatusUpdateState(
      status: status ?? this.status,
      action: action ?? this.action,
      errorMessage: errorMessage ?? this.errorMessage,
      billType: billType ?? this.billType,
      jobNo: jobNo ?? this.jobNo,
      saleOrderId: saleOrderId ?? this.saleOrderId,
      statusName: statusName ?? this.statusName,
      statusId: statusId ?? this.statusId,
      userName: userName ?? this.userName,
      checkBoxStartTime: checkBoxStartTime ?? this.checkBoxStartTime,
      checkBoxEndTime: checkBoxEndTime ?? this.checkBoxEndTime,
      checkBoxImageUpload: checkBoxImageUpload ?? this.checkBoxImageUpload,
      dtpStartTime: dtpStartTime ?? this.dtpStartTime,
      dtpEndTime: dtpEndTime ?? this.dtpEndTime,
      imageNetworkNames: imageNetworkNames ?? this.imageNetworkNames,
      autocompleteSuggestions:
      autocompleteSuggestions ?? this.autocompleteSuggestions,
      showAutocompleteOverlay:
      showAutocompleteOverlay ?? this.showAutocompleteOverlay,
    );
  }

  @override
  List<Object?> get props => [
    status,
    action,
    errorMessage,
    billType,
    jobNo,
    saleOrderId,
    statusName,
    statusId,
    userName,
    checkBoxStartTime,
    checkBoxEndTime,
    checkBoxImageUpload,
    dtpStartTime,
    dtpEndTime,
    imageNetworkNames,
    autocompleteSuggestions,
    showAutocompleteOverlay,
  ];
}