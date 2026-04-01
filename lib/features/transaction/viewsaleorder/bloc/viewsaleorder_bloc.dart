import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/features/transaction/viewsaleorder/bloc/viewsaleorder_event.dart';
import 'package:maleva/features/transaction/viewsaleorder/bloc/viewsaleorder_state.dart';


class GetJobNoBloc extends Bloc<GetJobNoEvent, GetJobNoState> {
  GetJobNoBloc() : super(GetJobNoInitial()) {
    on<GetJobNoStarted>(_onStarted);
    on<GetJobNoBillTypeChanged>(_onBillTypeChanged);
    on<GetJobNoTextChanged>(_onTextChanged);
    on<GetJobNoSuggestionSelected>(_onSuggestionSelected);
    on<GetJobNoOverlayDismissed>(_onOverlayDismissed);
    on<GetJobNoViewRequested>(_onViewRequested);
  }

  // ── Default loaded state ────────────────────────────────────────────────────
  GetJobNoLoaded _defaultLoaded() =>  GetJobNoLoaded(
    billType:    '0',
    jobNoText:   '',
    saleOrderId: 0,
    suggestions: [],
  );

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      GetJobNoStarted event, Emitter<GetJobNoState> emit) async {
    emit(GetJobNoLoading());
    try {
      // Load job list for default BillType = 0
      await OnlineApi.GetJobNoForwarding(null, 0);
      emit(_defaultLoaded());
    } catch (e) {
      emit(GetJobNoError(e.toString()));
    }
  }

  // ── BillType radio changed ──────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(
      GetJobNoBillTypeChanged event, Emitter<GetJobNoState> emit) async {
    if (state is! GetJobNoLoaded) return;
    final s = state as GetJobNoLoaded;

    // Re-fetch job list for new bill type
    try {
      await OnlineApi.GetJobNoForwarding(null, int.parse(event.billType));
    } catch (_) {}

    emit(s.copyWith(
      billType:    event.billType,
      jobNoText:   '',
      saleOrderId: 0,
      suggestions: [],
    ));
  }

  // ── Text changed — filter autocomplete ─────────────────────────────────────
  void _onTextChanged(
      GetJobNoTextChanged event, Emitter<GetJobNoState> emit) {
    if (state is! GetJobNoLoaded) return;
    final s = state as GetJobNoLoaded;

    final query = event.text.trim();

    if (query.isEmpty) {
      emit(s.copyWith(jobNoText: query, suggestions: [], saleOrderId: 0));
      return;
    }

    final filtered = objfun.JobNoList
        .where((e) => e['CNumber'].toString().contains(query))
        .toList();

    emit(s.copyWith(
      jobNoText:   query,
      suggestions: filtered,
      saleOrderId: 0, // reset until user picks
    ));
  }

  // ── Suggestion tapped ───────────────────────────────────────────────────────
  void _onSuggestionSelected(
      GetJobNoSuggestionSelected event, Emitter<GetJobNoState> emit) {
    if (state is! GetJobNoLoaded) return;
    final s = state as GetJobNoLoaded;
    emit(s.copyWith(
      jobNoText:   event.jobNo,
      saleOrderId: event.saleOrderId,
      suggestions: [], // close dropdown
    ));
  }

  // ── Overlay dismissed (tapped outside) ─────────────────────────────────────
  void _onOverlayDismissed(
      GetJobNoOverlayDismissed event, Emitter<GetJobNoState> emit) {
    if (state is! GetJobNoLoaded) return;
    final s = state as GetJobNoLoaded;
    emit(s.copyWith(suggestions: []));
  }

  // ── View requested ──────────────────────────────────────────────────────────
  void _onViewRequested(
      GetJobNoViewRequested event, Emitter<GetJobNoState> emit) {
    if (state is! GetJobNoLoaded) return;
    final s = state as GetJobNoLoaded;

    if (s.jobNoText.isEmpty) return; // UI handles toast

    final prev = state;
    emit(GetJobNoNavigateToDetails(
      saleOrderId: s.saleOrderId,
      jobNo:       int.tryParse(s.jobNoText) ?? 0,
    ));
    emit(prev); // restore so UI stays intact after navigation
  }
}