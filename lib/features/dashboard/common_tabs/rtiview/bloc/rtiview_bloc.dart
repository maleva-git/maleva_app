import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/rtiview_repository.dart';
import 'rtiview_event.dart';
import 'rtiview_state.dart';
import 'package:maleva/core/models/shared/r_t_i_master_view_model.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';

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

    final String currentRtiNo =
    event.rtiNo.isEmpty ? "DriverRTI" : event.rtiNo;

    try {
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

      final pdfUrl = await repository.fetchRTIPdfUrl(
        soId: event.id,
        rtiNo: currentRtiNo,
        comId: comId,
      );

      if (pdfUrl != null && pdfUrl.isNotEmpty) {
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
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final fromStr = DateFormat('yyyy-MM-dd').format(s.fromDate);
      final toStr   = DateFormat('yyyy-MM-dd').format(s.toDate);

      final resultData = await repository.fetchRTIRecords(
        comId:    comId,
        fromDate: fromStr,
        toDate:   toStr,
      );

      List<RTIMasterViewModel>  masters = [];
      List<RTIDetailsViewModel> details = [];

      if (resultData != null &&
          resultData is List &&
          resultData.isNotEmpty &&
          resultData[0] != null) {
        final data = resultData[0];
        masters = (data["salemaster"] as List)
            .map((e) => RTIMasterViewModel.fromJson(e as Map<String, dynamic>))
            .toList();
        details = (data["saledetails"] as List)
            .map((e) => RTIDetailsViewModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

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