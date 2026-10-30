import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/payable_record.dart';
import '../data/payable_records_api.dart';

/// The period chips of the Records tab.
enum RecordPeriod { thisMonth, lastMonth, custom }

class RecordsState {
  const RecordsState({
    this.kind = RecordKind.po,
    required this.from,
    required this.to,
    this.period = RecordPeriod.thisMonth,
    this.search = '',
    this.status,
    this.loading = true,
    this.records = const [],
    this.error,
    this.fileCounts = const {},
  });

  final RecordKind kind;
  final DateTime from;
  final DateTime to;
  final RecordPeriod period;
  final String search;

  /// The chosen status label (see [statusLabel]); null = all.
  final String? status;
  final bool loading;
  final List<PayableRecord> records;
  final String? error;

  /// Files per record id of [kind]; empty when not known.
  final Map<int, int> fileCounts;

  /// The status labels in the loaded list, most common first.
  List<String> get statuses {
    final count = <String, int>{};
    for (final r in records) {
      final s = statusLabel(r.status);
      count[s] = (count[s] ?? 0) + 1;
    }
    return count.keys.toList()..sort((a, b) => count[b]!.compareTo(count[a]!));
  }

  /// The records after the search and the status chip.
  List<PayableRecord> get shown =>
      records.where((r) => r.matches(search) && (status == null || statusLabel(r.status) == status)).toList();

  RecordsState copyWith({
    RecordKind? kind,
    DateTime? from,
    DateTime? to,
    RecordPeriod? period,
    String? search,
    String? status,
    bool clearStatus = false,
    bool? loading,
    List<PayableRecord>? records,
    String? error,
    bool clearError = false,
    Map<int, int>? fileCounts,
  }) =>
      RecordsState(
        kind: kind ?? this.kind,
        from: from ?? this.from,
        to: to ?? this.to,
        period: period ?? this.period,
        search: search ?? this.search,
        status: clearStatus ? null : (status ?? this.status),
        loading: loading ?? this.loading,
        records: records ?? this.records,
        error: clearError ? null : (error ?? this.error),
        fileCounts: fileCounts ?? this.fileCounts,
      );
}

/// Loads one record type for one period (change `payable-records`). Search and the status chip filter the loaded
/// list on the phone. File counts load beside the list; when they fail the cards simply show no 📎.
class RecordsCubit extends Cubit<RecordsState> {
  RecordsCubit(this._api, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(_initial((clock ?? DateTime.now)()));

  final PayableRecordsApi _api;
  final DateTime Function() _clock;
  int _ticket = 0;

  static RecordsState _initial(DateTime now) =>
      RecordsState(from: DateTime(now.year, now.month, 1), to: DateTime(now.year, now.month, now.day));

  Future<void> load() async {
    final ticket = ++_ticket;
    final s = state;
    emit(s.copyWith(loading: true, clearError: true));
    final counts = Future.sync(() => _api.fileCounts(s.kind)).catchError((_) => <int, int>{});
    try {
      final rows = await _api.list(s.kind, s.from, s.to);
      if (isClosed || ticket != _ticket) return;
      emit(state.copyWith(loading: false, records: rows));
    } catch (e) {
      if (isClosed || ticket != _ticket) return;
      emit(state.copyWith(loading: false, records: const [], error: '$e'));
    }
    final files = await counts;
    if (!isClosed && ticket == _ticket) emit(state.copyWith(fileCounts: files));
  }

  void chooseKind(RecordKind kind) {
    if (kind == state.kind) return;
    emit(state.copyWith(kind: kind, clearStatus: true, records: const [], fileCounts: const {}));
    load();
  }

  void choosePeriod(RecordPeriod period) {
    final now = _clock();
    switch (period) {
      case RecordPeriod.thisMonth:
        emit(state.copyWith(period: period, from: DateTime(now.year, now.month, 1), to: DateTime(now.year, now.month, now.day)));
      case RecordPeriod.lastMonth:
        emit(state.copyWith(
            period: period, from: DateTime(now.year, now.month - 1, 1), to: DateTime(now.year, now.month, 0)));
      case RecordPeriod.custom:
        return; // use chooseDates
    }
    load();
  }

  void chooseDates(DateTime from, DateTime to) {
    emit(state.copyWith(period: RecordPeriod.custom, from: from, to: to));
    load();
  }

  void search(String text) => emit(state.copyWith(search: text));

  void chooseStatus(String? status) => emit(status == null ? state.copyWith(clearStatus: true) : state.copyWith(status: status));
}
