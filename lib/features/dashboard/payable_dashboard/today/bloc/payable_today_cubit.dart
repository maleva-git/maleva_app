import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/payable_today_api.dart';
import '../data/payable_today_models.dart';

/// The Today tab's sections. Each loads and fails on its own.
enum PayableSection { pending, completed, documents, expenses }

/// One section: loading, its data, or why it could not be loaded. A reload keeps the data shown.
class SectionState<T> {
  const SectionState({this.loading = false, this.data, this.error});

  final bool loading;
  final T? data;
  final String? error;
}

class PayableTodayState {
  const PayableTodayState({this.sections = const {}, this.updatedAt});

  final Map<PayableSection, SectionState<Object>> sections;

  /// When the last full load finished.
  final DateTime? updatedAt;

  SectionState<T> _get<T>(PayableSection s) {
    final v = sections[s];
    return SectionState<T>(loading: v?.loading ?? true, data: v?.data as T?, error: v?.error);
  }

  SectionState<List<PendingPayment>> get pending => _get(PayableSection.pending);
  SectionState<List<CompletedPayment>> get completed => _get(PayableSection.completed);
  SectionState<DocumentIndex> get documents => _get(PayableSection.documents);
  SectionState<ExpenseSummary> get expenses => _get(PayableSection.expenses);

  PayableTodayState withSection(PayableSection s, SectionState<Object> v) =>
      PayableTodayState(sections: {...sections, s: v}, updatedAt: updatedAt);

  PayableTodayState loadedAt(DateTime t) => PayableTodayState(sections: sections, updatedAt: t);
}

/// Loads every section in parallel; one failing section never blocks the others (change `payable-desk-today`).
/// No timer: the tab reloads on pull-to-refresh or Refresh.
class PayableTodayCubit extends Cubit<PayableTodayState> {
  PayableTodayCubit(this._api, {required int Function() companyId, DateTime Function()? clock})
      : _companyId = companyId,
        _clock = clock ?? DateTime.now,
        super(const PayableTodayState());

  final PayableTodayApi _api;
  final int Function() _companyId;
  final DateTime Function() _clock;

  DateTime get _today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> load() async {
    await Future.wait(PayableSection.values.map(retry));
    if (!isClosed) emit(state.loadedAt(_clock()));
  }

  /// Reloads one section; the others are left as they are.
  Future<void> retry(PayableSection section) async {
    final before = state.sections[section];
    emit(state.withSection(section, SectionState(loading: true, data: before?.data)));
    try {
      final data = await _fetch(section);
      if (!isClosed) emit(state.withSection(section, SectionState(data: data)));
    } catch (e) {
      if (!isClosed) emit(state.withSection(section, SectionState(data: before?.data, error: '$e')));
    }
  }

  Future<Object> _fetch(PayableSection s) {
    final comid = _companyId();
    return switch (s) {
      PayableSection.pending => _api.pending(comid, _today),
      PayableSection.completed => _api.completed(comid, _today),
      PayableSection.documents => _api.documents(comid),
      PayableSection.expenses => _api.expenses(comid, _today),
    };
  }
}
