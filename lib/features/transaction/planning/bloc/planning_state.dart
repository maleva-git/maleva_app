// ════════════════════════════════════════════════════════════════════
//  planning_state.dart
// ════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:maleva/core/models/model.dart';

abstract class PlanningState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlanningInitial extends PlanningState {}
class PlanningLoading extends PlanningState {}

class PlanningLoaded extends PlanningState {
  final List<PlanningMasterModel> masterList;
  final Map<int, List<dynamic>> detailsMap;
  final int expandedIndex;
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
    expandedIndex,
    masterList,
    detailsMap, // FIX 5: DetailsMap added to props for proper UI refresh
    fromDate,
    toDate,
    employeeId,
    employeeName,
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

class PlanningPdfLoading extends PlanningLoaded {
  final int loadingId; // ID added to show loader only on specific card
  PlanningPdfLoading({
    required this.loadingId,
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

class PlanningError extends PlanningState {
  final String message;
  PlanningError(this.message);
  @override
  List<Object?> get props => [message];
}

class PlanningNavigateToEdit extends PlanningState {
  final int id;
  final int planningNo;
  PlanningNavigateToEdit({required this.id, required this.planningNo});
  @override
  List<Object?> get props => [id, planningNo];
}