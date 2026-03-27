import 'package:maleva/core/models/model.dart';

abstract class ReviewState {
  const ReviewState();
}

// ── Initial ───────────────────────────────────────────────────────────────────
class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

// ── Employees Loading ─────────────────────────────────────────────────────────
class ReviewEmployeesLoading extends ReviewState {
  const ReviewEmployeesLoading();
}

// ── Entry Form State ──────────────────────────────────────────────────────────
class ReviewFormState extends ReviewState {
  final List<EmployeeModel> employees;
  final int? selectedEmpId;
  final int selectedReview;
  final DateTime selectedDate;
  final bool saving;
  final bool showMobileField;

  const ReviewFormState({
    required this.employees,
    this.selectedEmpId,
    this.selectedReview = 1,
    required this.selectedDate,
    this.saving = false,
    this.showMobileField = true,
  });

  ReviewFormState copyWith({
    List<EmployeeModel>? employees,
    int? selectedEmpId,
    int? selectedReview,
    DateTime? selectedDate,
    bool? saving,
    bool? showMobileField,
  }) {
    return ReviewFormState(
      employees: employees ?? this.employees,
      selectedEmpId: selectedEmpId ?? this.selectedEmpId,
      selectedReview: selectedReview ?? this.selectedReview,
      selectedDate: selectedDate ?? this.selectedDate,
      saving: saving ?? this.saving,
      showMobileField: showMobileField ?? this.showMobileField,
    );
  }

  @override
  List<Object?> get props => [
    employees,
    selectedEmpId,
    selectedReview,
    selectedDate,
    saving,
    showMobileField,
  ];
}

// ── Grid State ────────────────────────────────────────────────────────────────
class ReviewGridState extends ReviewState {
  final List<EmployeeModel> employees;
  final int? selectedEmpId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<Review> reviews;
  final bool loading;

  const ReviewGridState({
    required this.employees,
    this.selectedEmpId,
    this.fromDate,
    this.toDate,
    this.reviews = const [],
    this.loading = false,
  });

  ReviewGridState copyWith({
    List<EmployeeModel>? employees,
    int? selectedEmpId,
    DateTime? fromDate,
    DateTime? toDate,
    List<Review>? reviews,
    bool? loading,
  }) {
    return ReviewGridState(
      employees: employees ?? this.employees,
      selectedEmpId: selectedEmpId ?? this.selectedEmpId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reviews: reviews ?? this.reviews,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [
    employees,
    selectedEmpId,
    fromDate,
    toDate,
    reviews,
    loading,
  ];
}

// ── Save Success ──────────────────────────────────────────────────────────────
class ReviewSaveSuccess extends ReviewState {
  final String message;
  const ReviewSaveSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Error ─────────────────────────────────────────────────────────────────────
class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}