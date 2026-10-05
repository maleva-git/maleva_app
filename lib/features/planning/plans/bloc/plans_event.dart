part of 'plans_bloc.dart';

sealed class PlansEvent extends Equatable {
  const PlansEvent();

  @override
  List<Object?> get props => [];
}

/// The page opened: load the employees and the plans of the first-open filters.
final class PlansStarted extends PlansEvent {
  const PlansStarted();
}

/// The filter form changed (nothing is loaded until [PlansApplied]).
final class PlansDraftChanged extends PlansEvent {
  const PlansDraftChanged(this.filter);

  final PlansFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// View: check the filters and load the plans.
final class PlansApplied extends PlansEvent {
  const PlansApplied();
}

/// Clear all: back to the first-open filters, then load.
final class PlansCleared extends PlansEvent {
  const PlansCleared();
}

/// The search bar's plan number (exact; ignores the dates on the server), then load.
final class PlansSearchSubmitted extends PlansEvent {
  const PlansSearchSubmitted(this.planningNo);

  final String planningNo;

  @override
  List<Object?> get props => [planningNo];
}

/// A filter chip changed one filter: apply it straight away.
final class PlansQuickFilterChanged extends PlansEvent {
  const PlansQuickFilterChanged(this.filter);

  final PlansFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// The Report Date the report prints (does not reload the list).
final class PlansReportDateChanged extends PlansEvent {
  const PlansReportDateChanged(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

/// A plan picked for the tablet's preview pane.
final class PlanSelected extends PlansEvent {
  const PlanSelected(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

/// Open the plan's report.
final class PlanReportRequested extends PlansEvent {
  const PlanReportRequested(this.plan);

  final PlanRow plan;

  @override
  List<Object?> get props => [plan];
}

/// Retry / back from a plan: load the applied filters again.
final class PlansRefreshed extends PlansEvent {
  const PlansRefreshed();
}
