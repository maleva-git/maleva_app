import 'package:maleva/core/models/model.dart';

abstract class EmployeeState {
  const EmployeeState();
}

// ─────────────────────────────────────────────────────────────────────────────
// LIST PAGE STATES
// ─────────────────────────────────────────────────────────────────────────────

class EmployeeListLoading extends EmployeeState {
  const EmployeeListLoading();
}

class EmployeeListLoaded extends EmployeeState {
  final List<EmployeeDetailsModel> allRecords;
  final List<EmployeeDetailsModel> filteredRecords;
  final String searchQuery;

  const EmployeeListLoaded({
    required this.allRecords,
    required this.filteredRecords,
    this.searchQuery = '',
  });

  EmployeeListLoaded copyWith({
    List<EmployeeDetailsModel>? allRecords,
    List<EmployeeDetailsModel>? filteredRecords,
    String? searchQuery,
  }) {
    return EmployeeListLoaded(
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allRecords, filteredRecords, searchQuery];
}

class EmployeeDeleteSuccess extends EmployeeState {
  final String message;
  const EmployeeDeleteSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD / EDIT PAGE STATES
// ─────────────────────────────────────────────────────────────────────────────

class EmployeeFormState extends EmployeeState {
  final EmployeeDetailsModel employee;
  final String? selectedCurrency;
  final String? selectedEmployeeType;
  final String? selectedRulesType;
  final int currentStep;
  final bool isSaving;

  const EmployeeFormState({
    required this.employee,
    this.selectedCurrency,
    this.selectedEmployeeType,
    this.selectedRulesType,
    this.currentStep = 0,
    this.isSaving = false,
  });

  EmployeeFormState copyWith({
    EmployeeDetailsModel? employee,
    String? selectedCurrency,
    String? selectedEmployeeType,
    String? selectedRulesType,
    int? currentStep,
    bool? isSaving,
  }) {
    return EmployeeFormState(
      employee: employee ?? this.employee,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      selectedEmployeeType: selectedEmployeeType ?? this.selectedEmployeeType,
      selectedRulesType: selectedRulesType ?? this.selectedRulesType,
      currentStep: currentStep ?? this.currentStep,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
    employee,
    selectedCurrency,
    selectedEmployeeType,
    selectedRulesType,
    currentStep,
    isSaving,
  ];
}

class EmployeeSaveSuccess extends EmployeeState {
  final String message;
  const EmployeeSaveSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED ERROR STATE
// ─────────────────────────────────────────────────────────────────────────────

class EmployeeError extends EmployeeState {
  final String message;
  const EmployeeError(this.message);

  @override
  List<Object?> get props => [message];
}