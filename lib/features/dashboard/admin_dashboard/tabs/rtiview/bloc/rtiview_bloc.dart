import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/rtiview/bloc/rtiview_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/rtiview/bloc/rtiview_state.dart';


class RTIDetailsBloc extends Bloc<RTIDetailsEvent, RTIDetailsState> {
  final BuildContext context;

  RTIDetailsBloc(this.context)
      : super(RTIDetailsLoaded(
    // Default: current year start → year end
    fromDate: DateTime(DateTime.now().year, 1, 1),
    toDate:   DateTime(DateTime.now().year, 12, 31),
  )) {
    on<LoadRTIDetailsEvent>(_onLoad);
    on<SelectRTIDetailsFromDateEvent>(_onFromDate);
    on<SelectRTIDetailsToDateEvent>(_onToDate);
    on<SearchRTIDetailsEvent>(_onSearch);

    add(const LoadRTIDetailsEvent()); // auto-load on init
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  RTIDetailsLoaded get _s => state as RTIDetailsLoaded;

  // ════════════════════════════════════════════════════════════════════════════
  // DATE PICKERS — just update, no reload
  // ════════════════════════════════════════════════════════════════════════════
  void _onFromDate(
      SelectRTIDetailsFromDateEvent e, Emitter<RTIDetailsState> emit) {
    if (state is! RTIDetailsLoaded) return;
    emit(_s.copyWith(fromDate: e.date));
  }

  void _onToDate(
      SelectRTIDetailsToDateEvent e, Emitter<RTIDetailsState> emit) {
    if (state is! RTIDetailsLoaded) return;
    emit(_s.copyWith(toDate: e.date));
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SEARCH BUTTON → reload
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> _onSearch(
      SearchRTIDetailsEvent e, Emitter<RTIDetailsState> emit) async {
    if (state is! RTIDetailsLoaded) return;
    await _fetch(emit, _s);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // INITIAL LOAD
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> _onLoad(
      LoadRTIDetailsEvent e, Emitter<RTIDetailsState> emit) async {
    if (state is! RTIDetailsLoaded) return;
    await _fetch(emit, _s);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FETCH
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> _fetch(
      Emitter<RTIDetailsState> emit, RTIDetailsLoaded s) async {
    emit(s.copyWith(isLoading: true));

    try {
      final comId    = objfun.storagenew.getInt('Comid') ?? 0;
      final fromStr  = DateFormat('yyyy-MM-dd').format(s.fromDate);
      final toStr    = DateFormat('yyyy-MM-dd').format(s.toDate);

      final resultData = await objfun.apiAllinoneSelect(
        "${objfun.apiSelectRTIView}"
            "$comId&Fromdate=$fromStr&Todate=$toStr"
            "&DId=0&TId=0&Employeeid=0&Search=",
        null,
        null,
        context,
      );

      List<RTIMasterViewModel>  masters = [];
      List<RTIDetailsViewModel> details = [];

      if (resultData != null &&
          resultData.isNotEmpty &&
          resultData[0] != null) {
        final data = resultData[0];

        masters = (data["salemaster"] as List)
            .map((e) => RTIMasterViewModel.fromJson(e))
            .toList();

        details = (data["saledetails"] as List)
            .map((e) => RTIDetailsViewModel.fromJson(e))
            .toList();
      }

      emit(s.copyWith(
        masters:   masters,
        details:   details,
        isLoading: false,
      ));
    } catch (err, stack) {
      objfun.msgshow(
        err.toString(), stack.toString(),
        Colors.white, Colors.red,
        null, 18.00 - objfun.reducesize,
        objfun.tll, objfun.tgc, context, 2,
      );
      emit(RTIDetailsError(
        message:  err.toString(),
        fromDate: s.fromDate,
        toDate:   s.toDate,
      ));
    }
  }
}