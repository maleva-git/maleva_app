import 'package:equatable/equatable.dart';

/// Employee Assignments' filters (`EmployeeAssignmentsPage.tsx:44-98`): From / To (today, both
/// required), Employee ("All Employees") and "My Job Only".
class AssignmentsFilter extends Equatable {
  const AssignmentsFilter({this.fromDate, this.toDate, this.employeeId = 0, this.employeeName = '', this.myJobOnly = false});

  factory AssignmentsFilter.initial(DateTime today) => AssignmentsFilter(fromDate: today, toDate: today);

  /// Null when the user cleared the date ("Please select both From and To dates").
  final DateTime? fromDate;
  final DateTime? toDate;
  final int employeeId;
  final String employeeName;
  final bool myJobOnly;

  int activeCount(DateTime today) {
    var n = 0;
    if (fromDate != today || toDate != today) n++;
    if (employeeId != 0) n++;
    if (myJobOnly) n++;
    return n;
  }

  AssignmentsFilter copyWith({
    DateTime? Function()? fromDate,
    DateTime? Function()? toDate,
    int? employeeId,
    String? employeeName,
    bool? myJobOnly,
  }) =>
      AssignmentsFilter(
        fromDate: fromDate == null ? this.fromDate : fromDate(),
        toDate: toDate == null ? this.toDate : toDate(),
        employeeId: employeeId ?? this.employeeId,
        employeeName: employeeName ?? this.employeeName,
        myJobOnly: myJobOnly ?? this.myJobOnly,
      );

  @override
  List<Object?> get props => [fromDate, toDate, employeeId, employeeName, myJobOnly];
}
