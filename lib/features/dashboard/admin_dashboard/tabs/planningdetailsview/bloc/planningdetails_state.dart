

import 'package:equatable/equatable.dart';

enum PlanningDetailsStatus { initial, loading, success, failure }

class PlanningDetailsState extends Equatable {
  const PlanningDetailsState({
    this.status              = PlanningDetailsStatus.initial,
    this.planningList        = const [],   // full list from API
    this.filteredPlanningList= const [],   // search-filtered view
    this.searchQuery         = '',
    this.errorMessage        = '',
  });

  final PlanningDetailsStatus status;
  final List<dynamic> planningList;
  final List<dynamic> filteredPlanningList;
  final String searchQuery;
  final String errorMessage;

  // ── Derived ───────────────────────────────────────────────
  bool get isLoading => status == PlanningDetailsStatus.loading;
  bool get hasData   => status == PlanningDetailsStatus.success &&
      planningList.isNotEmpty;
  bool get isEmpty   => status == PlanningDetailsStatus.success &&
      planningList.isEmpty;

  PlanningDetailsState copyWith({
    PlanningDetailsStatus? status,
    List<dynamic>? planningList,
    List<dynamic>? filteredPlanningList,
    String? searchQuery,
    String? errorMessage,
  }) {
    return PlanningDetailsState(
      status:               status               ?? this.status,
      planningList:         planningList         ?? this.planningList,
      filteredPlanningList: filteredPlanningList ?? this.filteredPlanningList,
      searchQuery:          searchQuery          ?? this.searchQuery,
      errorMessage:         errorMessage         ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, planningList, filteredPlanningList, searchQuery, errorMessage,
  ];
}