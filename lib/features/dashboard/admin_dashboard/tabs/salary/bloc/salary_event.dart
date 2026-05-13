part of 'salary_bloc.dart';

abstract class SalaryEvent extends Equatable {
  const SalaryEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the tab opens — loads data for the default date range.
class SalaryInitialLoad extends SalaryEvent {
  const SalaryInitialLoad();
}

/// Fired whenever from-date or to-date changes or a reload is needed.
class LoadSalaryData extends SalaryEvent {
  final String fromDate; // "yyyy-MM-dd"
  final String toDate;   // "yyyy-MM-dd"

  const LoadSalaryData({required this.fromDate, required this.toDate});

  @override
  List<Object?> get props => [fromDate, toDate];
}

/// Updates only the from-date (picker selection).
class UpdateFromDate extends SalaryEvent {
  final String fromDate;

  const UpdateFromDate({required this.fromDate});

  @override
  List<Object?> get props => [fromDate];
}

/// Updates only the to-date (picker selection).
class UpdateToDate extends SalaryEvent {
  final String toDate;

  const UpdateToDate({required this.toDate});

  @override
  List<Object?> get props => [toDate];
}