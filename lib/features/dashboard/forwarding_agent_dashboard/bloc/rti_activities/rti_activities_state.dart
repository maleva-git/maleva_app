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

class RtiActivitiesActionSuccess extends RtiActivitiesLoaded {
  final String actionMessage;
  const RtiActivitiesActionSuccess(this.actionMessage, List<RtiRouteActivity> activities) : super(activities);

  @override
  List<Object?> get props => [actionMessage, activities];
}

/// A status change the server did not save. The list stays as it was (the stop keeps its old
/// status) and [errorMessage] tells the agent why. [attempt] makes a second identical failure
/// a new state, so the message shows again.
class RtiActivitiesActionFailure extends RtiActivitiesLoaded {
  final String errorMessage;
  final int attempt;
  const RtiActivitiesActionFailure(this.errorMessage, List<RtiRouteActivity> activities, {this.attempt = 0})
      : super(activities);

  @override
  List<Object?> get props => [errorMessage, activities, attempt];
}
