part of 'salary_bloc.dart';

enum SalaryStatus { initial, loading, success, failure }

class SalaryState extends Equatable {
  // ── Status ──────────────────────────────────────────────
  final SalaryStatus status;
  final String? errorMessage;

  // ── Date range ──────────────────────────────────────────
  final String fromDate; // "yyyy-MM-dd"
  final String toDate;   // "yyyy-MM-dd"

  // ── Data ────────────────────────────────────────────────
  /// Raw list from API — each item is a Map<String, dynamic>
  /// with keys: BillDate, BillNoDisplay, NetAmt, …
  final List<Map<String, dynamic>> salaryList;

  /// Sum of NetAmt across all rows.
  final double salaryAmount;

  const SalaryState({
    this.status = SalaryStatus.initial,
    this.errorMessage,
    required this.fromDate,
    required this.toDate,
    this.salaryList = const [],
    this.salaryAmount = 0.0,
  });

  SalaryState copyWith({
    SalaryStatus? status,
    String? errorMessage,
    String? fromDate,
    String? toDate,
    List<Map<String, dynamic>>? salaryList,
    double? salaryAmount,
  }) {
    return SalaryState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      salaryList: salaryList ?? this.salaryList,
      salaryAmount: salaryAmount ?? this.salaryAmount,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    fromDate,
    toDate,
    salaryList,
    salaryAmount,
  ];
}