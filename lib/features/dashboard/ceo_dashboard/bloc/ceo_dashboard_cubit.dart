import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../data/ceo_analytics_api.dart';
import '../data/ceo_analytics_models.dart';
import '../data/ceo_period.dart';

/// One details list: loading, its rows, or why it could not be loaded.
class CeoDetailsState {
  const CeoDetailsState({this.loading = false, this.data, this.error});

  final bool loading;
  final CeoDetails? data;
  final String? error;
}

/// The spend flow of one period: loading, the flow, or why it could not be loaded.
class CeoSpendState {
  const CeoSpendState({this.loading = false, this.data, this.error});

  final bool loading;
  final CeoSpendFlow? data;
  final String? error;
}

/// Money received for one range: loading, the answer, or why it could not be loaded.
class CeoReceivedState {
  const CeoReceivedState({this.loading = false, this.data, this.error});

  final bool loading;
  final CeoReceived? data;
  final String? error;
}

/// Fuel for one range: loading, the answer, or why it could not be loaded.
class CeoFuelState {
  const CeoFuelState({this.loading = false, this.data, this.error});

  final bool loading;
  final CeoFuel? data;
  final String? error;
}

class CeoDashboardState {
  const CeoDashboardState({
    this.period = CeoPeriod.thisMonth,
    this.loading = false,
    this.overview,
    this.error,
    this.forbidden = false,
    this.updatedAt,
    this.details = const {},
    this.spend = const {},
    this.received = const {},
    this.fuel = const {},
  });

  final CeoPeriod period;

  /// The overview is being (re)loaded; a reload keeps the shown numbers.
  final bool loading;
  final CeoOverview? overview;

  /// The server's message when the last overview load failed.
  final String? error;

  /// The server answered 403: this user is not the CEO.
  final bool forbidden;

  /// When the last overview load finished.
  final DateTime? updatedAt;

  /// Details lists by [CeoDashboardCubit.detailsKey].
  final Map<String, CeoDetailsState> details;

  /// Spend flows by `fromDate|toDate`.
  final Map<String, CeoSpendState> spend;

  /// Money received by `fromDate|toDate`.
  final Map<String, CeoReceivedState> received;

  /// Fuel by `fromDate|toDate`.
  final Map<String, CeoFuelState> fuel;

  CeoDashboardState copyWith({
    CeoPeriod? period,
    bool? loading,
    CeoOverview? overview,
    bool clearOverview = false,
    String? error,
    bool clearError = false,
    bool? forbidden,
    DateTime? updatedAt,
    Map<String, CeoDetailsState>? details,
    Map<String, CeoSpendState>? spend,
    Map<String, CeoReceivedState>? received,
    Map<String, CeoFuelState>? fuel,
  }) =>
      CeoDashboardState(
        period: period ?? this.period,
        loading: loading ?? this.loading,
        overview: clearOverview ? null : (overview ?? this.overview),
        error: clearError ? null : (error ?? this.error),
        forbidden: forbidden ?? this.forbidden,
        updatedAt: updatedAt ?? this.updatedAt,
        details: details ?? this.details,
        spend: spend ?? this.spend,
        received: received ?? this.received,
        fuel: fuel ?? this.fuel,
      );
}

/// The CEO dashboard: the overview for a period (one call), and the list behind a number on demand,
/// kept per kind + key + period so a second tap opens at once (change `ceo-analytics-dashboard`).
class CeoDashboardCubit extends Cubit<CeoDashboardState> {
  CeoDashboardCubit(this._api, {DateTime Function()? clock, CeoPeriod period = CeoPeriod.thisMonth})
      : _clock = clock ?? DateTime.now,
        super(CeoDashboardState(period: period));

  final CeoAnalyticsApi _api;
  final DateTime Function() _clock;

  /// The device's day (the clock), for the Sale orders cards.
  DateTime get today => _clock();

  /// The range of the chosen period, from today.
  (String, String) get range => state.period.range(_clock());

  /// One list's id: kind, key and days, plus the invoice filter and customer when set.
  static String detailsKey(String kind, String? key, (String, String) range, {String? invoice, int? customer}) =>
      '$kind|${key ?? ''}|${range.$1}|${range.$2}'
      '${invoice == null ? '' : '|invoice=$invoice'}${customer == null ? '' : '|customer=$customer'}';

  /// Loads the overview of [period] (default: the chosen one).
  Future<void> load([CeoPeriod? period]) async {
    final p = period ?? state.period;
    final changed = p != state.period;
    emit(state.copyWith(period: p, loading: true, clearError: true, clearOverview: changed));
    final (from, to) = p.range(_clock());
    try {
      final overview = await _api.overview(fromDate: from, toDate: to);
      if (isClosed || state.period != p) return;
      emit(state.copyWith(loading: false, overview: overview, forbidden: false, updatedAt: _clock()));
    } catch (e) {
      if (isClosed || state.period != p) return;
      emit(state.copyWith(loading: false, error: '$e', forbidden: e is ApiFailure && e.statusCode == 403));
    }
  }

  /// Pull-to-refresh and Refresh: fresh numbers, and the lists behind them are asked again.
  Future<void> reload() {
    emit(state.copyWith(details: const {}, spend: const {}, received: const {}, fuel: const {}));
    return load();
  }

  /// Retry after a failed load.
  Future<void> retry() => load();

  /// The state of one details list in [range] (default: the chosen period); loading until asked.
  CeoDetailsState detailsOf(String kind, String? key, {(String, String)? range, String? invoice, int? customer}) =>
      state.details[detailsKey(kind, key, range ?? this.range, invoice: invoice, customer: customer)] ??
      const CeoDetailsState(loading: true);

  /// Whether the list was asked for already (loading, loaded or failed).
  bool hasDetails(String kind, String? key, {(String, String)? range, String? invoice, int? customer}) =>
      state.details.containsKey(detailsKey(kind, key, range ?? this.range, invoice: invoice, customer: customer));

  /// Loads the list behind a number for [range] (default: the chosen period; the Sale orders cards and a
  /// revenue month give their own days), unless it is already loaded or loading ([force]: ask again).
  /// [invoice] (`WITH` / `WITHOUT`; `ALL` is the default) and [customer] narrow the sale order and
  /// invoice lists.
  Future<void> loadDetails(String kind, String? key,
      {(String, String)? range, bool force = false, String? invoice, int? customer}) async {
    final r = range ?? this.range;
    final id = detailsKey(kind, key, r, invoice: invoice, customer: customer);
    final current = state.details[id];
    if (!force && current != null && (current.loading || current.data != null)) return;
    _putDetails(id, const CeoDetailsState(loading: true));
    try {
      final data = invoice == null && customer == null
          ? await _api.details(kind: kind, key: key, fromDate: r.$1, toDate: r.$2)
          : await _api.details(
              kind: kind, key: key, fromDate: r.$1, toDate: r.$2, invoice: invoice, customer: customer);
      if (!isClosed) _putDetails(id, CeoDetailsState(data: data));
    } catch (e) {
      if (!isClosed) _putDetails(id, CeoDetailsState(error: '$e'));
    }
  }

  void _putDetails(String id, CeoDetailsState s) => emit(state.copyWith(details: {...state.details, id: s}));

  static String _spendKey((String, String) r) => '${r.$1}|${r.$2}';

  /// The spend flow of [range] (default: the chosen period); loading until asked.
  CeoSpendState spendOf({(String, String)? range}) =>
      state.spend[_spendKey(range ?? this.range)] ?? const CeoSpendState(loading: true);

  bool hasSpend({(String, String)? range}) => state.spend.containsKey(_spendKey(range ?? this.range));

  /// Loads the spend flow of [range] unless it is loaded or loading ([force]: ask again).
  Future<void> loadSpend({(String, String)? range, bool force = false}) async {
    final r = range ?? this.range;
    final id = _spendKey(r);
    final current = state.spend[id];
    if (!force && current != null && (current.loading || current.data != null)) return;
    _putSpend(id, const CeoSpendState(loading: true));
    try {
      final data = await _api.spend(fromDate: r.$1, toDate: r.$2);
      if (!isClosed) _putSpend(id, CeoSpendState(data: data));
    } catch (e) {
      if (!isClosed) _putSpend(id, CeoSpendState(error: '$e'));
    }
  }

  void _putSpend(String id, CeoSpendState s) => emit(state.copyWith(spend: {...state.spend, id: s}));

  /// Money received in [range]; loading until asked.
  CeoReceivedState receivedOf((String, String) range) =>
      state.received[_spendKey(range)] ?? const CeoReceivedState(loading: true);

  bool hasReceived((String, String) range) => state.received.containsKey(_spendKey(range));

  /// Loads the money received in [range] unless it is loaded or loading ([force]: ask again).
  Future<void> loadReceived((String, String) range, {bool force = false}) async {
    final id = _spendKey(range);
    final current = state.received[id];
    if (!force && current != null && (current.loading || current.data != null)) return;
    _putReceived(id, const CeoReceivedState(loading: true));
    try {
      final data = await _api.received(fromDate: range.$1, toDate: range.$2);
      if (!isClosed) _putReceived(id, CeoReceivedState(data: data));
    } catch (e) {
      if (!isClosed) _putReceived(id, CeoReceivedState(error: '$e'));
    }
  }

  void _putReceived(String id, CeoReceivedState s) => emit(state.copyWith(received: {...state.received, id: s}));

  /// Fuel of [range] (default: the chosen period); loading until asked.
  CeoFuelState fuelOf({(String, String)? range}) =>
      state.fuel[_spendKey(range ?? this.range)] ?? const CeoFuelState(loading: true);

  bool hasFuel({(String, String)? range}) => state.fuel.containsKey(_spendKey(range ?? this.range));

  /// Loads the fuel of [range] unless it is loaded or loading ([force]: ask again).
  Future<void> loadFuel({(String, String)? range, bool force = false}) async {
    final r = range ?? this.range;
    final id = _spendKey(r);
    final current = state.fuel[id];
    if (!force && current != null && (current.loading || current.data != null)) return;
    _putFuel(id, const CeoFuelState(loading: true));
    try {
      final data = await _api.fuel(fromDate: r.$1, toDate: r.$2);
      if (!isClosed) _putFuel(id, CeoFuelState(data: data));
    } catch (e) {
      if (!isClosed) _putFuel(id, CeoFuelState(error: '$e'));
    }
  }

  void _putFuel(String id, CeoFuelState s) => emit(state.copyWith(fuel: {...state.fuel, id: s}));
}
