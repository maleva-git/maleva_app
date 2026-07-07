import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/leave_repository.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository _repository;

  LeaveBloc(this._repository) : super(LeaveInitial()) {
    on<FetchLeaveData>(_onFetchLeaveData);
    on<SubmitLeaveRequest>(_onSubmitLeaveRequest);
    on<UpdateLeaveStatusEvent>(_onUpdateLeaveStatus);
  }

  Future<void> _onFetchLeaveData(
    FetchLeaveData event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leaveTypes = await _repository.getLeaveTypes();
      final requests = await _repository.getLeaveRequests(
        applicantType: event.applicantType,
        applicantRefId: event.applicantRefId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(LeaveLoaded(requests: requests, leaveTypes: leaveTypes));
    } catch (e) {
      emit(LeaveError("Failed to fetch leave data: ${e.toString()}"));
    }
  }

  Future<void> _onSubmitLeaveRequest(
    SubmitLeaveRequest event,
    Emitter<LeaveState> emit,
  ) async {
    if (state is LeaveLoaded) {
      final currentState = state as LeaveLoaded;
      emit(currentState.copyWith(isSubmitting: true));

      try {
        final success = await _repository.addLeaveRequest(
          leaveTypeRefId: event.leaveTypeRefId,
          fromDate: event.fromDate,
          toDate: event.toDate,
          totalDays: event.totalDays,
          reason: event.reason,
          applicantRefId: event.applicantRefId,
          applicantType: event.applicantType,
        );

        emit(currentState.copyWith(isSubmitting: false));

        if (success) {
          emit(const LeaveActionSuccess("Leave Request Submitted Successfully"));
          // Optionally refetch data here, or let UI dispatch FetchLeaveData again
        } else {
          emit(const LeaveActionError("Failed to submit leave request"));
        }
      } catch (e) {
        emit(currentState.copyWith(isSubmitting: false));
        emit(LeaveActionError("Error: ${e.toString()}"));
      }
    }
  }

  Future<void> _onUpdateLeaveStatus(
    UpdateLeaveStatusEvent event,
    Emitter<LeaveState> emit,
  ) async {
    if (state is LeaveLoaded) {
      final currentState = state as LeaveLoaded;
      emit(currentState.copyWith(isSubmitting: true));

      try {
        final success = await _repository.updateLeaveStatus(
          id: event.id,
          statusRefId: event.statusRefId,
          reviewRemark: event.reviewRemark,
          reviewedBy: event.reviewedBy,
        );

        emit(currentState.copyWith(isSubmitting: false));

        if (success) {
          emit(const LeaveActionSuccess("Leave status updated successfully"));
        } else {
          emit(const LeaveActionError("Failed to update leave status"));
        }
      } catch (e) {
        emit(currentState.copyWith(isSubmitting: false));
        emit(LeaveActionError("Error: ${e.toString()}"));
      }
    }
  }
}
