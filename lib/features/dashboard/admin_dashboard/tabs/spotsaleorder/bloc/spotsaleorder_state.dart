import 'dart:io';

abstract class SpotSaleState {
  const SpotSaleState();
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY STATES
// ─────────────────────────────────────────────────────────────────────────────

class SpotSaleEntryState extends SpotSaleState {
  final String? selectedJobType;
  final String? selectedJobStatus;
  final String? selectedPort;
  final String cargoQty;
  final String vehicleName;
  final String awbNo;
  final String cargoWeight;
  final File? pickedImage;
  final File? pickedPDF;
  final String? networkImageUrl;
  final bool isSubmitting;
  final bool listsLoaded;

  const SpotSaleEntryState({
    this.selectedJobType,
    this.selectedJobStatus,
    this.selectedPort,
    this.cargoQty = '',
    this.vehicleName = '',
    this.awbNo = '',
    this.cargoWeight = '',
    this.pickedImage,
    this.pickedPDF,
    this.networkImageUrl,
    this.isSubmitting = false,
    this.listsLoaded = false,
  });

  SpotSaleEntryState copyWith({
    String? selectedJobType,
    String? selectedJobStatus,
    String? selectedPort,
    String? cargoQty,
    String? vehicleName,
    String? awbNo,
    String? cargoWeight,
    File? pickedImage,
    File? pickedPDF,
    String? networkImageUrl,
    bool? isSubmitting,
    bool? listsLoaded,
    bool clearJobType = false,
    bool clearJobStatus = false,
    bool clearPort = false,
    bool clearImage = false,
    bool clearPDF = false,
    bool clearNetworkImage = false,
  }) {
    return SpotSaleEntryState(
      selectedJobType:   clearJobType   ? null : (selectedJobType   ?? this.selectedJobType),
      selectedJobStatus: clearJobStatus ? null : (selectedJobStatus ?? this.selectedJobStatus),
      selectedPort:      clearPort      ? null : (selectedPort      ?? this.selectedPort),
      cargoQty:          cargoQty       ?? this.cargoQty,
      vehicleName:       vehicleName    ?? this.vehicleName,
      awbNo:             awbNo          ?? this.awbNo,
      cargoWeight:       cargoWeight    ?? this.cargoWeight,
      pickedImage:       clearImage     ? null : (pickedImage  ?? this.pickedImage),
      pickedPDF:         clearPDF       ? null : (pickedPDF    ?? this.pickedPDF),
      networkImageUrl:   clearNetworkImage ? null : (networkImageUrl ?? this.networkImageUrl),
      isSubmitting:      isSubmitting   ?? this.isSubmitting,
      listsLoaded:       listsLoaded    ?? this.listsLoaded,
    );
  }
}

class SpotSaleSubmitSuccess extends SpotSaleState {
  const SpotSaleSubmitSuccess();
}

class SpotSaleEntryError extends SpotSaleState {
  final String message;
  const SpotSaleEntryError(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW STATES
// ─────────────────────────────────────────────────────────────────────────────

class SpotSaleViewState extends SpotSaleState {
  final DateTime fromDate;
  final DateTime toDate;
  final List<dynamic> records;
  final bool isLoading;

  const SpotSaleViewState({
    required this.fromDate,
    required this.toDate,
    this.records = const [],
    this.isLoading = false,
  });

  SpotSaleViewState copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    List<dynamic>? records,
    bool? isLoading,
  }) {
    return SpotSaleViewState(
      fromDate:  fromDate  ?? this.fromDate,
      toDate:    toDate    ?? this.toDate,
      records:   records   ?? this.records,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SpotSaleViewError extends SpotSaleState {
  final String message;
  final DateTime fromDate;
  final DateTime toDate;
  const SpotSaleViewError({
    required this.message,
    required this.fromDate,
    required this.toDate,
  });
}