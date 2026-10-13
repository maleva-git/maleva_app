import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/logging/app_logger.dart';
import 'package:maleva/core/vessel_master/vessel_master_api.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';

/// One row under a vessel field: a vessel, or one of its PTP calls.
class VesselSuggestionRow {
  const VesselSuggestionRow(this.vessel, [this.call]);

  final VesselSuggestion vessel;
  final PtpCall? call;
}

/// Suggestions for one vessel field of the sales form (`GET /api/vessel-masters/suggest`), asked
/// [debounce] after the last keystroke from 2 characters. A failed or late answer shows nothing, so the
/// field keeps working as a plain text field. At most [maxRows] rows: a vessel with PTP calls gives
/// one row per call, a vessel without calls one row.
class VesselSuggestCubit extends Cubit<List<VesselSuggestionRow>> {
  VesselSuggestCubit(this._api, {this.debounce = const Duration(milliseconds: 300), this.maxRows = 5})
      : super(const []);

  final VesselMasterApi _api;
  final Duration debounce;
  final int maxRows;
  Timer? _timer;
  int _asked = 0;

  /// The field's text changed: ask again after [debounce] for that [leg] and its [port].
  void query(String text, {required String leg, String port = ''}) {
    _timer?.cancel();
    final q = text.trim();
    if (q.length < 2) {
      clear();
      return;
    }
    _timer = Timer(debounce, () => _fetch(q, leg, port));
  }

  /// Closes the list (field left, row picked); an answer still on its way is ignored.
  void clear() {
    _timer?.cancel();
    _asked++;
    if (!isClosed && state.isNotEmpty) emit(const []);
  }

  Future<void> _fetch(String q, String leg, String port) async {
    final asked = ++_asked;
    List<VesselSuggestionRow> rows;
    try {
      final vessels = await _api.suggest(q, leg: leg, port: port);
      rows = [
        for (final v in vessels)
          if (v.calls.isEmpty) VesselSuggestionRow(v) else for (final c in v.calls) VesselSuggestionRow(v, c),
      ].take(maxRows).toList();
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Sale order vessel suggest');
      rows = const [];
    }
    if (asked == _asked && !isClosed) emit(rows);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
