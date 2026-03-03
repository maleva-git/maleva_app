abstract class ExpenseReportEvent {
  const ExpenseReportEvent();

  @override
  List<Object> get props => [];

}

class LoadExpReportEvent extends ExpenseReportEvent{
  final String fromDate;
  final String toDate;

  const LoadExpReportEvent({required this.fromDate, required this.toDate});

  @override
  List<Object> get props => [fromDate, toDate];
}

class ChangeFromDateEvent extends ExpenseReportEvent {
  final String fromDate;
  const ChangeFromDateEvent({required this.fromDate});

  @override
  List<Object> get props => [fromDate];

}

class ChangeToDateEvent extends ExpenseReportEvent{
  final String toDate;
  const ChangeToDateEvent({required this.toDate});

  @override
  List<Object> get props => [toDate];
}