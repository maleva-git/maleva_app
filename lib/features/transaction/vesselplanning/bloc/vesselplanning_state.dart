

import '../../../../core/models/model.dart';

abstract class VesselPlanningState {}

class VesselPlanningInitial extends VesselPlanningState {}

class VesselPlanningLoading extends VesselPlanningState {}

class VesselPlanningLoaded extends VesselPlanningState {
  final List<VesselPlanningMasterModel> masterList;
  final List<dynamic> detailsList;
  final List<dynamic> selectedDetails; // details for currently expanded row
  final int expandedIndex;             // -1 = none expanded
  final String fromDate;
  final String toDate;
  final String planningNo;
  final int empId;
  final String empName;
  final bool isLoggedInEmp;

  VesselPlanningLoaded({
    required this.masterList,
    required this.detailsList,
    required this.selectedDetails,
    required this.expandedIndex,
    required this.fromDate,
    required this.toDate,
    required this.planningNo,
    required this.empId,
    required this.empName,
    required this.isLoggedInEmp,
  });

  VesselPlanningLoaded copyWith({
    List<VesselPlanningMasterModel>? masterList,
    List<dynamic>? detailsList,
    List<dynamic>? selectedDetails,
    int? expandedIndex,
    String? fromDate,
    String? toDate,
    String? planningNo,
    int? empId,
    String? empName,
    bool? isLoggedInEmp,
  }) {
    return VesselPlanningLoaded(
      masterList: masterList ?? this.masterList,
      detailsList: detailsList ?? this.detailsList,
      selectedDetails: selectedDetails ?? this.selectedDetails,
      expandedIndex: expandedIndex ?? this.expandedIndex,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      planningNo: planningNo ?? this.planningNo,
      empId: empId ?? this.empId,
      empName: empName ?? this.empName,
      isLoggedInEmp: isLoggedInEmp ?? this.isLoggedInEmp,
    );
  }
}

class VesselPlanningError extends VesselPlanningState {
  final String message;
  VesselPlanningError(this.message);
}

// Navigate to edit page after password + API done
class VesselPlanningNavigateToEdit extends VesselPlanningState {}