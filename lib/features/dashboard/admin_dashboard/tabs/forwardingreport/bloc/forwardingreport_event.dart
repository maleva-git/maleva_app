import 'package:equatable/equatable.dart';

sealed class ForwardingReportEvent extends Equatable {
  const ForwardingReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadForwardingReportEvent extends ForwardingReportEvent {
  final bool isDateSearch;
  const LoadForwardingReportEvent({this.isDateSearch = false});

  @override
  List<Object?> get props => [isDateSearch];
}

class SelectFromDateEvent extends ForwardingReportEvent {
  final DateTime date;
  const SelectFromDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectToDateEvent extends ForwardingReportEvent {
  final DateTime date;
  const SelectToDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}