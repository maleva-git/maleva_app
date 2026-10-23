import 'package:maleva/core/network/api_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/leave_repository.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository _repository;

  /// The last list and types loaded. A submit or review works from it whatever the current
  /// state is: before, after a refused save the state was [LeaveActionError] and the next
  /// submit was silently ignored (openspec change leave-approval-rules).
  LeaveLoaded _loaded = const LeaveLoaded(requests: [], leaveTypes: []);

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

      _loaded = LeaveLoaded(requests: requests, leaveTypes: leaveTypes);
      emit(_loaded);
    } catch (e) {
      emit(LeaveError("Failed to fetch leave data: ${e is ApiFailure ? e.message : e}"));
    }
  }

  /// True while a submit or review is with the server: a second tap is ignored.
  bool _busy = false;

  Future<void> _onSubmitLeaveRequest(SubmitLeaveRequest event, Emitter<LeaveState> emit) =>
      _act(emit, "Leave Request Submitted Successfully", () => _repository.addLeaveRequest(
            leaveTypeRefId: event.leaveTypeRefId,
            fromDate: event.fromDate,
            toDate: event.toDate,
            totalDays: event.totalDays,
            reason: event.reason,
            applicantRefId: event.applicantRefId,
            applicantType: event.applicantType,
            part: event.part,
          ));

  Future<void> _onUpdateLeaveStatus(UpdateLeaveStatusEvent event, Emitter<LeaveState> emit) =>
      _act(emit, "Leave status updated successfully", () => _repository.updateLeaveStatus(
            id: event.id,
            statusRefId: event.statusRefId,
            reviewRemark: event.reviewRemark,
            reviewedBy: event.reviewedBy,
          ));

  /// Sends one write; the list stays on screen and the server's reason is shown on a refusal.
  Future<void> _act(Emitter<LeaveState> emit, String done, Future<bool> Function() write) async {
    if (_busy) return;
    _busy = true;
    emit(_loaded.copyWith(isSubmitting: true));
    try {
      await write();
      emit(_loaded.copyWith(isSubmitting: false));
      emit(LeaveActionSuccess(done));
    } catch (e) {
      emit(_loaded.copyWith(isSubmitting: false));
      emit(LeaveActionError(e is ApiFailure ? e.message : "Error: $e"));
    } finally {
      _busy = false;
    }
  }
}
