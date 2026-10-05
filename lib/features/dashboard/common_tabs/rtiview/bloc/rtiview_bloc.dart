import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../data/rtiview_repository.dart';
import 'rtiview_event.dart';
import 'rtiview_state.dart';

class RTIDetailsBloc extends Bloc<RTIDetailsEvent, RTIDetailsState> {
  final RTIViewRepository repository;

  RTIDetailsBloc({required this.repository})
      : super(RTIDetailsLoaded(
    fromDate: DateTime(DateTime.now().year, 1, 1),
    toDate: DateTime(DateTime.now().year, 12, 31),
  )) {
    on<LoadRTIDetailsEvent>(_onLoad);
    on<SelectRTIDetailsFromDateEvent>(_onFromDate);
    on<SelectRTIDetailsToDateEvent>(_onToDate);
    on<SearchRTIDetailsEvent>(_onSearch);
    on<RTIViewEvent>(_onRTIView);

    add(const LoadRTIDetailsEvent());
  }

  RTIDetailsLoaded get _s => state as RTIDetailsLoaded;

  void _onFromDate(SelectRTIDetailsFromDateEvent e, Emitter<RTIDetailsState> emit) {
    if (state is! RTIDetailsLoaded) return;
    emit(_s.copyWith(fromDate: e.date));
  }

  void _onToDate(SelectRTIDetailsToDateEvent e, Emitter<RTIDetailsState> emit) {
    if (state is! RTIDetailsLoaded) return;
    emit(_s.copyWith(toDate: e.date));
  }

  Future<void> _onSearch(SearchRTIDetailsEvent e, Emitter<RTIDetailsState> emit) async {
    if (state is! RTIDetailsLoaded) return;
    await _fetch(emit, _s);
  }

  Future<void> _onLoad(LoadRTIDetailsEvent e, Emitter<RTIDetailsState> emit) async {
    if (state is! RTIDetailsLoaded) return;
    await _fetch(emit, _s);
  }

  Future<void> _onRTIView(RTIViewEvent event, Emitter<RTIDetailsState> emit) async {
    if (state is! RTIDetailsLoaded) return;
    final currentState = _s; // snapshot before any emit

    try {
      final pdfUrl = await repository.fetchRTIPdfUrl(rtiId: event.id);

      if (pdfUrl.isNotEmpty) {
        // ✅ Emit success — listener in UI will open the PDF
        emit(RTIPdfLaunchSuccess(pdfUrl));
      } else {
        emit(const RTIActionError("Failed to load PDF."));
      }
    } catch (err) {
      emit(RTIActionError(err.toString()));
    } finally {
      // ✅ Always restore the loaded list state so UI stays intact.
      // No isLoading wrapping — the loading dialog in _openPdf handles feedback.
      emit(currentState);
    }
  }

  Future<void> _fetch(Emitter<RTIDetailsState> emit, RTIDetailsLoaded s) async {
    emit(s.copyWith(isLoading: true));

    try {
      final fromStr = DateFormat('yyyy-MM-dd').format(s.fromDate);
      final toStr   = DateFormat('yyyy-MM-dd').format(s.toDate);

      final list = await repository.fetchRTIRecords(fromDate: fromStr, toDate: toStr);
      final masters = list.masters;
      final details = list.details;

      emit(s.copyWith(masters: masters, details: details, isLoading: false));
    } catch (err) {
      emit(RTIDetailsError(
        message:  err.toString(),
        fromDate: s.fromDate,
        toDate:   s.toDate,
      ));
    }
  }
}