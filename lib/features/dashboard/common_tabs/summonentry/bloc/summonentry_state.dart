import 'dart:io';

abstract class SummonState {
  const SummonState();
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY PAGE STATES
// ─────────────────────────────────────────────────────────────────────────────

class SummonEntryState extends SummonState {
  final String? selectedTruck;
  final DateTime? selectedDate;
  final String selectedCountry;
  final String? selectedSummon;
  final String amount;
  final String portPass;
  final String truckLcnMnt;
  final String levy;
  final String fuel;
  final File? pickedImage;
  final File? pickedPDF;
  final bool isSubmitting;

  const SummonEntryState({
    this.selectedTruck,
    this.selectedDate,
    this.selectedCountry = 'Malaysia',
    this.selectedSummon,
    this.amount = '',
    this.portPass = '',
    this.truckLcnMnt = '',
    this.levy = '',
    this.fuel = '',
    this.pickedImage,
    this.pickedPDF,
    this.isSubmitting = false,
  });

  SummonEntryState copyWith({
    String? selectedTruck,
    DateTime? selectedDate,
    String? selectedCountry,
    String? selectedSummon,
    String? amount,
    String? portPass,
    String? truckLcnMnt,
    String? levy,
    String? fuel,
    File? pickedImage,
    File? pickedPDF,
    bool? isSubmitting,
    bool clearTruck = false,
    bool clearDate = false,
    bool clearSummon = false,
    bool clearImage = false,
    bool clearPDF = false,
  }) {
    return SummonEntryState(
      selectedTruck: clearTruck ? null : (selectedTruck ?? this.selectedTruck),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedSummon:
      clearSummon ? null : (selectedSummon ?? this.selectedSummon),
      amount: amount ?? this.amount,
      portPass: portPass ?? this.portPass,
      truckLcnMnt: truckLcnMnt ?? this.truckLcnMnt,
      levy: levy ?? this.levy,
      fuel: fuel ?? this.fuel,
      pickedImage: clearImage ? null : (pickedImage ?? this.pickedImage),
      pickedPDF: clearPDF ? null : (pickedPDF ?? this.pickedPDF),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    selectedTruck, selectedDate, selectedCountry, selectedSummon,
    amount, portPass, truckLcnMnt, levy, fuel,
    pickedImage, pickedPDF, isSubmitting,
  ];
}

class SummonSubmitSuccess extends SummonState {
  const SummonSubmitSuccess();
}

class SummonEntryError extends SummonState {
  final String message;
  const SummonEntryError(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW PAGE STATES
// ─────────────────────────────────────────────────────────────────────────────

class SummonViewState extends SummonState {
  final DateTime fromDate;
  final DateTime toDate;
  final List<dynamic> records;
  final bool isLoading;

  const SummonViewState({
    required this.fromDate,
    required this.toDate,
    this.records = const [],
    this.isLoading = false,
  });

  SummonViewState copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    List<dynamic>? records,
    bool? isLoading,
  }) {
    return SummonViewState(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [fromDate, toDate, records, isLoading];
}

class SummonViewError extends SummonState {
  final String message;
  final DateTime fromDate;
  final DateTime toDate;

  const SummonViewError({
    required this.message,
    required this.fromDate,
    required this.toDate,
  });
}