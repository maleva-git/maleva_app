import 'package:equatable/equatable.dart';

sealed class ExpenseReportEvent extends Equatable {
  const ExpenseReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenseReportEvent extends ExpenseReportEvent {
  final bool isDateSearch;
  const LoadExpenseReportEvent({this.isDateSearch = false});

  @override
  List<Object?> get props => [isDateSearch];
}

class SelectFromDateEvent extends ExpenseReportEvent {
  final DateTime date;
  const SelectFromDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectToDateEvent extends ExpenseReportEvent {
  final DateTime date;
  const SelectToDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}