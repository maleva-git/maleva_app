import 'package:intl/intl.dart';

class VesselDashboardState {
  final bool isLoading;
  final String fromDate;
  final String toDate;
  final int statusId;
  final String statusName;
  final String remarks;
  final List<dynamic> vesselList;
  final String errorMessage;

  VesselDashboardState({
    required this.isLoading,
    required this.fromDate,
    required this.toDate,
    required this.statusId,
    required this.statusName,
    required this.remarks,
    required this.vesselList,
    required this.errorMessage,
  });

  static String _defaultFromDate() => "2024-10-01"; // உங்களது பழைய லாஜிக்படி
  static String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  factory VesselDashboardState.initial() => VesselDashboardState(
    isLoading: true,
    fromDate: _defaultFromDate(),
    toDate: _today(),
    statusId: 0,
    statusName: '',
    remarks: '',
    vesselList: [],
    errorMessage: '',
  );

  VesselDashboardState copyWith({
    bool? isLoading,
    String? fromDate,
    String? toDate,
    int? statusId,
    String? statusName,
    String? remarks,
    List<dynamic>? vesselList,
    String? errorMessage,
  }) {
    return VesselDashboardState(
      isLoading: isLoading ?? this.isLoading,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      statusId: statusId ?? this.statusId,
      statusName: statusName ?? this.statusName,
      remarks: remarks ?? this.remarks,
      vesselList: vesselList ?? this.vesselList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}