

import 'package:equatable/equatable.dart';

abstract class PlanningDetailsEvent extends Equatable {
  const PlanningDetailsEvent();
  @override
  List<Object?> get props => [];
}

/// Initial load on page entry
class PlanningDetailsStartupRequested extends PlanningDetailsEvent {
  const PlanningDetailsStartupRequested();
}

/// Pull-to-refresh
class PlanningDetailsRefreshRequested extends PlanningDetailsEvent {
  const PlanningDetailsRefreshRequested();
}

/// Search field changed — filters the list client-side
class PlanningDetailsSearchChanged extends PlanningDetailsEvent {
  final String query;
  const PlanningDetailsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}