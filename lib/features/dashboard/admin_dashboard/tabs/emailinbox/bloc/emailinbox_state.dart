import 'package:maleva/core/models/model.dart';

abstract class EmailState {
  const EmailState();
}

// ── Initial ───────────────────────────────────────────────────────────────────
class EmailInitial extends EmailState {
  const EmailInitial();
}

// ── Employees Loading ─────────────────────────────────────────────────────────
class EmployeesLoading extends EmailState {
  const EmployeesLoading();
}

// ── Employees Loaded ──────────────────────────────────────────────────────────
class EmployeesLoaded extends EmailState {
  final List<EmployeeModel> employees;
  final EmployeeModel? selectedEmployee;
  final List<EmailModel> emails;
  final bool emailsLoading;
  final bool saving;

  const EmployeesLoaded({
    required this.employees,
    this.selectedEmployee,
    this.emails = const [],
    this.emailsLoading = false,
    this.saving = false,
  });

  EmployeesLoaded copyWith({
    List<EmployeeModel>? employees,
    EmployeeModel? selectedEmployee,
    List<EmailModel>? emails,
    bool? emailsLoading,
    bool? saving,
  }) {
    return EmployeesLoaded(
      employees: employees ?? this.employees,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      emails: emails ?? this.emails,
      emailsLoading: emailsLoading ?? this.emailsLoading,
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object?> get props => [
    employees,
    selectedEmployee,
    emails,
    emailsLoading,
    saving,
  ];
}

// ── Error ─────────────────────────────────────────────────────────────────────
class EmailError extends EmailState {
  final String message;
  const EmailError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Save Success ──────────────────────────────────────────────────────────────
class EmailSaveSuccess extends EmailState {
  final String message;
  const EmailSaveSuccess(this.message);

  @override
  List<Object?> get props => [message];
}