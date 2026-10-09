import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_api.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';

class ForwardingRequestsState {
  const ForwardingRequestsState({required this.filter, this.rows = const [], this.loading = false, this.error, this.busyId});

  final ForwardingRequestFilter filter;
  final List<ForwardingRequest> rows;
  final bool loading;

  /// The server's message when the list could not be loaded.
  final String? error;

  /// The row being saved or cancelled, so its card shows a spinner.
  final int? busyId;

  int get openCount => rows.where((r) => !r.cancelled && r.status != 'APPROVED' && r.status != 'RELEASED').length;
  int get overdueCount => rows.where((r) => r.isOverdue()).length;

  ForwardingRequestsState copyWith({
    ForwardingRequestFilter? filter,
    List<ForwardingRequest>? rows,
    bool? loading,
    String? error,
    bool clearError = false,
    int? busyId,
    bool clearBusy = false,
  }) =>
      ForwardingRequestsState(
        filter: filter ?? this.filter,
        rows: rows ?? this.rows,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        busyId: clearBusy ? null : (busyId ?? this.busyId),
      );
}

/// The planning list (the forwarding team) or "my requests" (Customer Service), on the shared
/// `/api/forwarding-requests/search`. A save or cancel re-reads the list so every card is current.
class ForwardingRequestsCubit extends Cubit<ForwardingRequestsState> {
  ForwardingRequestsCubit(this._api, {required bool mine, DateTime? now})
      : super(ForwardingRequestsState(filter: ForwardingRequestFilter.defaults(now: now, mine: mine), loading: true));

  final ForwardingRequestApi _api;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final rows = await _api.search(state.filter);
      if (!isClosed) emit(state.copyWith(rows: rows, loading: false));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(loading: false, error: '$e'));
    }
  }

  Future<void> applyFilter(ForwardingRequestFilter filter) async {
    emit(state.copyWith(filter: filter));
    await load();
  }

  Future<void> resetFilter() => applyFilter(ForwardingRequestFilter.defaults(mine: state.filter.mine));

  /// Saves one row; throws the server's message so the screen can show it. The list is re-read after.
  Future<ForwardingRequest> saveTicks(int id, ForwardingRequestTicks ticks) async {
    emit(state.copyWith(busyId: id));
    try {
      final saved = await _api.saveTicks(id, ticks);
      await load();
      return saved;
    } finally {
      if (!isClosed) emit(state.copyWith(clearBusy: true));
    }
  }

  Future<ForwardingRequest> cancel(int id) async {
    emit(state.copyWith(busyId: id));
    try {
      final cancelled = await _api.cancel(id);
      await load();
      return cancelled;
    } finally {
      if (!isClosed) emit(state.copyWith(clearBusy: true));
    }
  }
}
