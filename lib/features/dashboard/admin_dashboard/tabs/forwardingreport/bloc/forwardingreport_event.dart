abstract class ForwardingReportEvent {
  const ForwardingReportEvent();

  @override
  List<Object> get props => [];
}

class LoadFWDataEvent extends ForwardingReportEvent {
  final String fromDate;
  final String toDate;

  const LoadFWDataEvent({required this.fromDate, required this.toDate});

  @override
  List<Object> get props => [fromDate, toDate];
}

class ChangFromDateEvent extends ForwardingReportEvent {
  final String fromDate;
  const ChangFromDateEvent({required this.fromDate});

  @override
  List<Object> get props => [fromDate];
}

class ChangeToDateEvent extends ForwardingReportEvent {
  final String toDate;
  const ChangeToDateEvent({required this.toDate});

  @override
  List<Object> get props => [toDate];
}