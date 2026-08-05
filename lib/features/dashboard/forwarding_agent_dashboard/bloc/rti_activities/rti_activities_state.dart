import 'package:equatable/equatable.dart';
import '../../models/rti_route_activity.dart';

abstract class RtiActivitiesState extends Equatable {
  const RtiActivitiesState();
  @override
  List<Object?> get props => [];
}

class RtiActivitiesInitial extends RtiActivitiesState {}

class RtiActivitiesLoading extends RtiActivitiesState {}

class RtiActivitiesLoaded extends RtiActivitiesState {
  final List<RtiRouteActivity> activities;
  const RtiActivitiesLoaded(this.activities);
  @override
  List<Object?> get props => [activities];
}

class RtiActivitiesError extends RtiActivitiesState {
  final String message;
  const RtiActivitiesError(this.message);
  @override
  List<Object?> get props => [message];
}
