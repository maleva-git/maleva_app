import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/admin_overview_models.dart';
import '../data/admin_overview_repository.dart';

/// The Overview tab's areas. Each loads and fails on its own.
enum OverviewArea { sales, jobOrders, mail, incidents, truckPlanning, vesselPlanning, truckLocation }

/// One area: loading, its data, or why it could not be loaded. A reload keeps the shown data.
class AreaState<T> {
  const AreaState({this.loading = false, this.data, this.error});

  final bool loading;
  final T? data;

  /// The server's message, when the last load failed.
  final String? error;
}

class AdminOverviewState {
  const AdminOverviewState({this.areas = const {}, this.updatedAt});

  final Map<OverviewArea, AreaState<Object>> areas;

  /// When the last full load finished.
  final DateTime? updatedAt;

  AreaState<T> _area<T>(OverviewArea a) {
    final s = areas[a];
    return AreaState<T>(loading: s?.loading ?? true, data: s?.data as T?, error: s?.error);
  }

  AreaState<SalesSummary> get sales => _area(OverviewArea.sales);
  AreaState<JobOrderSummary> get jobOrders => _area(OverviewArea.jobOrders);
  AreaState<MailSummary> get mail => _area(OverviewArea.mail);
  AreaState<IrSummary> get incidents => _area(OverviewArea.incidents);
  AreaState<int> get truckPlanning => _area(OverviewArea.truckPlanning);
  AreaState<int> get vesselPlanning => _area(OverviewArea.vesselPlanning);
  AreaState<TruckLocationSummary> get truckLocation => _area(OverviewArea.truckLocation);

  AdminOverviewState withArea(OverviewArea a, AreaState<Object> s) =>
      AdminOverviewState(areas: {...areas, a: s}, updatedAt: updatedAt);

  AdminOverviewState loadedAt(DateTime t) => AdminOverviewState(areas: areas, updatedAt: t);
}

/// Loads every area in parallel; one failing area never blocks the others (change
/// `super-admin-overview-tab`). No timer: the tab reloads on pull-to-refresh or Refresh.
class AdminOverviewCubit extends Cubit<AdminOverviewState> {
  AdminOverviewCubit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const AdminOverviewState());

  final AdminOverviewRepository _repository;
  final DateTime Function() _clock;

  Future<void> load() async {
    await Future.wait(OverviewArea.values.map(retry));
    if (!isClosed) emit(state.loadedAt(_clock()));
  }

  /// Reloads one area; the others are left as they are.
  Future<void> retry(OverviewArea area) async {
    final before = state.areas[area];
    emit(state.withArea(area, AreaState(loading: true, data: before?.data)));
    try {
      final data = await _fetch(area);
      if (!isClosed) emit(state.withArea(area, AreaState(data: data)));
    } catch (e) {
      if (!isClosed) emit(state.withArea(area, AreaState(data: before?.data, error: '$e')));
    }
  }

  Future<Object> _fetch(OverviewArea area) => switch (area) {
        OverviewArea.sales => _repository.sales(),
        OverviewArea.jobOrders => _repository.jobOrders(),
        OverviewArea.mail => _repository.mail(),
        OverviewArea.incidents => _repository.incidents(),
        OverviewArea.truckPlanning => _repository.truckPlanningToday(),
        OverviewArea.vesselPlanning => _repository.vesselPlanningNextWeek(),
        OverviewArea.truckLocation => _repository.truckLocation(),
      };
}
