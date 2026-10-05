import 'package:maleva/core/models/shared/employee_details_model.dart';

abstract class EmployeeState {
  const EmployeeState();
}

class EmployeeListLoading extends EmployeeState {
  const EmployeeListLoading();
}

class EmployeeListLoaded extends EmployeeState {
  final List<EmployeeDetailsModel> allRecords;
  final List<EmployeeDetailsModel> filteredRecords;
  final String searchQuery;
  final EmployeeDetailsModel? selectedRecord;

  const EmployeeListLoaded({
    required this.allRecords,
    required this.filteredRecords,
    this.searchQuery = '',
    this.selectedRecord,
  });

  EmployeeListLoaded copyWith({
    List<EmployeeDetailsModel>? allRecords,
    List<EmployeeDetailsModel>? filteredRecords,
    String? searchQuery,
    EmployeeDetailsModel? selectedRecord, // ← add
    bool clearSelected = false,           // ← add
  }) {
    return EmployeeListLoaded(
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRecord:   clearSelected ? null : (selectedRecord ?? this.selectedRecord),

    );
  }

  @override
  List<Object?> get props => [allRecords, filteredRecords, searchQuery, selectedRecord];
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
  /// The roles an employee can hold (`{id, name}`), from the Java role list.
  final List<Map<String, dynamic>> roles;

  const EmployeeFormState({
    required this.employee,
    this.selectedCurrency,
    this.selectedEmployeeType,
    this.selectedRulesType,
    this.currentStep = 0,
    this.isSaving = false,
    this.roles = const [],
  });

  EmployeeFormState copyWith({
    EmployeeDetailsModel? employee,
    String? selectedCurrency,
    String? selectedEmployeeType,
    String? selectedRulesType,
    int? currentStep,
    bool? isSaving,
    List<Map<String, dynamic>>? roles,
  }) {
    return EmployeeFormState(
      employee: employee ?? this.employee,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      selectedEmployeeType: selectedEmployeeType ?? this.selectedEmployeeType,
      selectedRulesType: selectedRulesType ?? this.selectedRulesType,
      currentStep: currentStep ?? this.currentStep,
      isSaving: isSaving ?? this.isSaving,
      roles: roles ?? this.roles,
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
    roles,
    employee.RoleId,
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