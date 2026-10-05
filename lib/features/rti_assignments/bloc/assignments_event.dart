part of 'assignments_bloc.dart';

sealed class AssignmentsEvent extends Equatable {
  const AssignmentsEvent();

  @override
  List<Object?> get props => [];
}

/// The page opened: load the employees only (nothing is searched until Search).
final class AssignmentsStarted extends AssignmentsEvent {
  const AssignmentsStarted();
}

/// A filter changed. "My Job Only" filters the loaded rows at once; nothing is fetched.
final class AssignmentsFilterChanged extends AssignmentsEvent {
  const AssignmentsFilterChanged(this.filter);

  final AssignmentsFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Search / Refresh.
final class AssignmentsSearchRequested extends AssignmentsEvent {
  const AssignmentsSearchRequested();
}

/// Clear: today, no employee, My Job Only off. It does not search (`handleClear`).
final class AssignmentsCleared extends AssignmentsEvent {
  const AssignmentsCleared();
}

final class AssignmentReportRequested extends AssignmentsEvent {
  const AssignmentReportRequested(this.job);

  final EmployeeAssignment job;

  @override
  List<Object?> get props => [job];
}
