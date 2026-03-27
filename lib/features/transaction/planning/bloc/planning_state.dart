// ════════════════════════════════════════════════════════════════════
//  planning_state.dart
// ════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:maleva/core/models/model.dart';

abstract class PlanningState extends Equatable {
  @override
  List<Object?> get props => [];
}

// ── App just started ──
class PlanningInitial extends PlanningState {}

// ── Full screen loading (first load) ──
class PlanningLoading extends PlanningState {}

// ── PDF export in progress ──
class PlanningPdfLoading extends PlanningLoaded {
   PlanningPdfLoading({
    required super.masterList,
    required super.detailsMap,
    required super.expandedIndex,
    required super.fromDate,
    required super.toDate,
    required super.employeeId,
    required super.employeeName,
    required super.planningNo,
    required super.checkLoggedEmp,
  });
}

// ── Data loaded successfully ──
class PlanningLoaded extends PlanningState {
  final List<PlanningMasterModel> masterList;

  // key = PLANINGMasterRefId, value = filtered detail rows
  final Map<int, List<dynamic>> detailsMap;

  final int expandedIndex; // -1 = none expanded

  // Filter values
  final String fromDate;
  final String toDate;
  final int employeeId;
  final String employeeName;
  final String planningNo;
  final bool checkLoggedEmp;

   PlanningLoaded({
    required this.masterList,
    required this.detailsMap,
    required this.expandedIndex,
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
    required this.employeeName,
    required this.planningNo,
    required this.checkLoggedEmp,
  });

  @override
  List<Object?> get props => [
    expandedIndex,     // expand/collapse → rebuild
    masterList,        // data changed → rebuild
    fromDate,
    toDate,
    employeeId,
    planningNo,
    checkLoggedEmp,
  ];

  PlanningLoaded copyWith({
    List<PlanningMasterModel>? masterList,
    Map<int, List<dynamic>>? detailsMap,
    int? expandedIndex,
    String? fromDate,
    String? toDate,
    int? employeeId,
    String? employeeName,
    String? planningNo,
    bool? checkLoggedEmp,
  }) {
    return PlanningLoaded(
      masterList: masterList ?? this.masterList,
      detailsMap: detailsMap ?? this.detailsMap,
      expandedIndex: expandedIndex ?? this.expandedIndex,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      planningNo: planningNo ?? this.planningNo,
      checkLoggedEmp: checkLoggedEmp ?? this.checkLoggedEmp,
    );
  }
}

// ── Error state ──
class PlanningError extends PlanningState {
  final String message;
  PlanningError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Navigate to edit page ──
class PlanningNavigateToEdit extends PlanningState {
  final int id;
  final int planningNo;
  PlanningNavigateToEdit({required this.id, required this.planningNo});

  @override
  List<Object?> get props => [id, planningNo];
}