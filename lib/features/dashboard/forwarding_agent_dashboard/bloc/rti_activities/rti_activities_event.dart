import 'package:equatable/equatable.dart';

abstract class RtiActivitiesEvent extends Equatable {
  const RtiActivitiesEvent();
  @override
  List<Object?> get props => [];
}

class FetchRtiActivities extends RtiActivitiesEvent {
  final DateTime fromDate;
  final DateTime toDate;

  const FetchRtiActivities(this.fromDate, this.toDate);

  @override
  List<Object?> get props => [fromDate, toDate];
}
