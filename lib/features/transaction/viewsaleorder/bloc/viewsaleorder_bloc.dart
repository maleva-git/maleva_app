import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/transaction/viewsaleorder/data/viewsaleorder_repository.dart';
import 'package:maleva/features/transaction/viewsaleorder/bloc/viewsaleorder_event.dart';
import 'package:maleva/features/transaction/viewsaleorder/bloc/viewsaleorder_state.dart';


class GetJobNoBloc extends Bloc<GetJobNoEvent, GetJobNoState> {
  final ViewSaleOrderRepository repository;

  GetJobNoBloc(this.repository) : super(GetJobNoInitial()) {
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
    cachedJobList: [],
  );

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      GetJobNoStarted event, Emitter<GetJobNoState> emit) async {
    // Show UI instantly
    final initialState = _defaultLoaded();
    emit(initialState);
    try {
      // Load job list for default BillType = 0 in background
      final jobs = await repository.getJobNoForwarding(0);
      emit(initialState.copyWith(cachedJobList: jobs));
    } catch (e) {
      // Background load failed, ignore
    }
  }

  // ── BillType radio changed ──────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(
      GetJobNoBillTypeChanged event, Emitter<GetJobNoState> emit) async {
    if (state is! GetJobNoLoaded) return;
    final s = state as GetJobNoLoaded;
    
    emit(s.copyWith(
      billType:    event.billType,
      jobNoText:   '',
      saleOrderId: 0,
      suggestions: [],
      cachedJobList: [], // clear until fetched
    ));

    // Re-fetch job list for new bill type
    try {
      final jobs = await repository.getJobNoForwarding(int.parse(event.billType));
      final updatedState = state;
      if (updatedState is GetJobNoLoaded) {
        emit(updatedState.copyWith(cachedJobList: jobs));
      }
    } catch (_) {}
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

    final filtered = s.cachedJobList
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