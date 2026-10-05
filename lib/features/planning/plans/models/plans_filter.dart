import 'package:equatable/equatable.dart';

/// Planning View's filters (`P/PlanningView.tsx:54-67`): From = yesterday, To = today (the
/// device's own day; React uses UTC by mistake, K11), Planning No, Employee, "Login Employee"
/// and the Report Date (today) that the report prints.
class PlansFilter extends Equatable {
  const PlansFilter({
    required this.fromDate,
    required this.toDate,
    required this.reportDate,
    this.planningNo = '',
    this.employeeId = 0,
    this.employeeName = '',
    this.loginEmployee = false,
  });

  /// The first-open filters for [today] (a date at midnight).
  factory PlansFilter.initial(DateTime today) => PlansFilter(fromDate: today.subtract(const Duration(days: 1)), toDate: today, reportDate: today);

  final DateTime fromDate;
  final DateTime toDate;
  final DateTime reportDate;
  final String planningNo;

  /// The picked employee (0 = everyone).
  final int employeeId;
  final String employeeName;

  /// "Login Employee": the Employee picker is disabled and the user's own id is sent.
  final bool loginEmployee;

  bool get datesInOrder => !fromDate.isAfter(toDate);

  /// How many filters differ from the first-open ones (for the "Filters · n" badge).
  int activeCount(DateTime today) {
    final first = PlansFilter.initial(today);
    var n = 0;
    if (fromDate != first.fromDate || toDate != first.toDate) n++;
    if (planningNo.trim().isNotEmpty) n++;
    if (loginEmployee || employeeId != 0) n++;
    return n;
  }

  PlansFilter copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    DateTime? reportDate,
    String? planningNo,
    int? employeeId,
    String? employeeName,
    bool? loginEmployee,
  }) =>
      PlansFilter(
        fromDate: fromDate ?? this.fromDate,
        toDate: toDate ?? this.toDate,
        reportDate: reportDate ?? this.reportDate,
        planningNo: planningNo ?? this.planningNo,
        employeeId: employeeId ?? this.employeeId,
        employeeName: employeeName ?? this.employeeName,
        loginEmployee: loginEmployee ?? this.loginEmployee,
      );

  @override
  List<Object?> get props => [fromDate, toDate, reportDate, planningNo, employeeId, employeeName, loginEmployee];
}
