import 'dart:io';

abstract class SparePartsState {
  const SparePartsState();
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY PAGE STATES
// ─────────────────────────────────────────────────────────────────────────────

class SparePartsEntryState extends SparePartsState {
  final String? selectedTruck;
  final DateTime? selectedDate;
  final String spareParts;
  final String amount;
  final File? pickedImage;
  final File? pickedPDF;
  final bool isSubmitting;

  const SparePartsEntryState({
    this.selectedTruck,
    this.selectedDate,
    this.spareParts = '',
    this.amount = '',
    this.pickedImage,
    this.pickedPDF,
    this.isSubmitting = false,
  });

  SparePartsEntryState copyWith({
    String? selectedTruck,
    DateTime? selectedDate,
    String? spareParts,
    String? amount,
    File? pickedImage,
    File? pickedPDF,
    bool? isSubmitting,
    bool clearTruck = false,
    bool clearDate = false,
    bool clearImage = false,
    bool clearPDF = false,
  }) {
    return SparePartsEntryState(
      selectedTruck: clearTruck ? null : (selectedTruck ?? this.selectedTruck),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      spareParts: spareParts ?? this.spareParts,
      amount: amount ?? this.amount,
      pickedImage: clearImage ? null : (pickedImage ?? this.pickedImage),
      pickedPDF: clearPDF ? null : (pickedPDF ?? this.pickedPDF),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    selectedTruck, selectedDate, spareParts,
    amount, pickedImage, pickedPDF, isSubmitting,
  ];
}

class SparePartsSubmitSuccess extends SparePartsState {
  const SparePartsSubmitSuccess();
}

class SparePartsEntryError extends SparePartsState {
  final String message;
  const SparePartsEntryError(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW PAGE STATES
// ─────────────────────────────────────────────────────────────────────────────

class SparePartsViewState extends SparePartsState {
  final DateTime fromDate;
  final DateTime toDate;
  final List<dynamic> records;
  final bool isLoading;
  final Map<String, dynamic>? selectedRecord;
  const SparePartsViewState({
    required this.fromDate,
    required this.toDate,
    this.records = const [],
    this.isLoading = false,
    this.selectedRecord,
  });

  SparePartsViewState copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    List<dynamic>? records,
    bool? isLoading,
    Map<String, dynamic>? selectedRecord, // ← add
    bool clearSelected = false,
  }) {
    return SparePartsViewState(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      selectedRecord: clearSelected
          ? null
          : (selectedRecord ?? this.selectedRecord),
    );
  }

  @override
  List<Object?> get props => [fromDate, toDate, records, isLoading, selectedRecord];
}

class SparePartsViewError extends SparePartsState {
  final String message;
  final DateTime fromDate;
  final DateTime toDate;

  const SparePartsViewError({
    required this.message,
    required this.fromDate,
    required this.toDate,
  });
}