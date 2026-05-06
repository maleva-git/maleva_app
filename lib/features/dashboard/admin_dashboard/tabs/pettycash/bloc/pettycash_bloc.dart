import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../data/pettycash_repository.dart';
import 'pettycash_event.dart';
import 'pettycash_state.dart';

class PettyCashBloc extends Bloc<PettyCashEvent, PettyCashState> {
  // ❌ REMOVED: final BuildContext context;
  final PettyCashRepository repository; // ✅ Injected Repository

  PettyCashBloc({required this.repository})
      : super(PettyCashInitial(
    // ✅ Sets the default fromDate to 30 days ago!
    fromDate: DateTime.now().subtract(const Duration(days: 30)),
    toDate: DateTime.now(),
  )) {
    on<SelectFromDateEvent>(_onFromDate);
    on<SelectToDateEvent>(_onToDate);
    on<LoadPettyCashEvent>(_onLoad);
    on<SelectPettyCashMasterEvent>(_onSelectMaster);
  }

  // ── From Date ───────────────────────────────────────────────────────────────
  void _onFromDate(SelectFromDateEvent event, Emitter<PettyCashState> emit) {
    final toDate = _currentToDate();
    emit(PettyCashInitial(fromDate: event.date, toDate: toDate));
  }

  // ── To Date ─────────────────────────────────────────────────────────────────
  void _onToDate(SelectToDateEvent event, Emitter<PettyCashState> emit) {
    final fromDate = _currentFromDate();
    emit(PettyCashInitial(fromDate: fromDate, toDate: event.date));
  }

  // ── Select Master ───────────────────────────────────────────────────────────
  void _onSelectMaster(
      SelectPettyCashMasterEvent event,
      Emitter<PettyCashState> emit,
      ) {
    if (state is PettyCashLoaded) {
      emit((state as PettyCashLoaded)
          .copyWith(selectedMaster: event.master));
    }
  }

  // ── Load Petty Cash ─────────────────────────────────────────────────────────
  Future<void> _onLoad(
      LoadPettyCashEvent event,
      Emitter<PettyCashState> emit,
      ) async {
    final fromDate = _currentFromDate();
    final toDate = _currentToDate();

    emit(PettyCashLoading(fromDate: fromDate, toDate: toDate));

    try {
      final String fromStr = DateFormat('yyyy-MM-dd').format(fromDate);
      final String toStr = DateFormat('yyyy-MM-dd').format(toDate);

      // ✅ REFACTORED: Using the injected repository without context
      final resultData = await repository.fetchPettyCashData(
        comId: objfun.storagenew.getInt('Comid') ?? 0,
        fromDate: fromStr,
        toDate: toStr,
      );

      List<PattycashMasterModel> masters = [];
      List<PattyCashDetailsModel> details = [];

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final data = resultData[0];
        if (data != null && data is Map) {
          if (data['PattycashMasterModel'] != null) {
            masters = (data['PattycashMasterModel'] as List)
                .map((e) => PattycashMasterModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          if (data['PattyCashDetailsModel'] != null) {
            details = (data['PattyCashDetailsModel'] as List)
                .map((e) => PattyCashDetailsModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      }

      emit(PettyCashLoaded(
        masterRecords: masters,
        detailRecords: details,
        fromDate: fromDate,
        toDate: toDate,
      ));
    } catch (e) {
      emit(PettyCashError(
        message: e.toString(),
        fromDate: fromDate,
        toDate: toDate,
      ));
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  DateTime _currentFromDate() {
    final s = state;
    if (s is PettyCashInitial) return s.fromDate;
    if (s is PettyCashLoading) return s.fromDate;
    if (s is PettyCashLoaded) return s.fromDate;
    if (s is PettyCashError) return s.fromDate;
    return DateTime.now().subtract(const Duration(days: 30));
  }

  DateTime _currentToDate() {
    final s = state;
    if (s is PettyCashInitial) return s.toDate;
    if (s is PettyCashLoading) return s.toDate;
    if (s is PettyCashLoaded) return s.toDate;
    if (s is PettyCashError) return s.toDate;
    return DateTime.now();
  }
}