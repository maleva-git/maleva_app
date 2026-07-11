import 'package:equatable/equatable.dart';
import '../data/leave_request_model.dart';

abstract class LeaveState extends Equatable {
  const LeaveState();
  
  @override
  List<Object?> get props => [];
}

class LeaveInitial extends LeaveState {}

class LeaveLoading extends LeaveState {}

class LeaveLoaded extends LeaveState {
  final List<LeaveRequestModel> requests;
  final List<LeaveTypeModel> leaveTypes;
  final bool isSubmitting;

  const LeaveLoaded({
    required this.requests,
    required this.leaveTypes,
    this.isSubmitting = false,
  });

  LeaveLoaded copyWith({
    List<LeaveRequestModel>? requests,
    List<LeaveTypeModel>? leaveTypes,
    bool? isSubmitting,
  }) {
    return LeaveLoaded(
      requests: requests ?? this.requests,
      leaveTypes: leaveTypes ?? this.leaveTypes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [requests, leaveTypes, isSubmitting];
}

class LeaveError extends LeaveState {
  final String message;
  const LeaveError(this.message);

  @override
  List<Object?> get props => [message];
}

class LeaveActionSuccess extends LeaveState {
  final String message;
  const LeaveActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class LeaveActionError extends LeaveState {
  final String message;
  const LeaveActionError(this.message);

  @override
  List<Object?> get props => [message];
}
