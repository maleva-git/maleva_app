import 'package:maleva/core/session/app_session.dart';

import '../../domain/entities/truck_location_week.dart';
import '../../domain/repositories/truck_location_repository.dart';
import '../datasources/truck_location_remote_data_source.dart';
import '../models/truck_location_json.dart';

class TruckLocationRepositoryImpl implements TruckLocationRepository {
  TruckLocationRepositoryImpl({
    required TruckLocationRemoteDataSource remote,
    required AppSession session,
  })  : _remote = remote,
        _session = session;

  final TruckLocationRemoteDataSource _remote;
  final AppSession _session;

  @override
  Future<TruckLocationWeek> week(String date) async {
    final data = await _remote.selectWeek(
      TruckLocationJson.weekRequest(companyId: _session.companyId, date: date),
    );
    return TruckLocationJson.week(data);
  }

  @override
  Future<TruckLocationWeek> saveWeek({
    required String weekStart,
    required List<TruckLocationCellChange> cells,
    required List<TruckLocationDoneTick> doneTicks,
  }) async {
    final data = await _remote.saveWeek(TruckLocationJson.saveRequest(
      companyId: _session.companyId,
      // 0 for a driver login; the server then stamps "system". Drivers have
      // no menu entry, so this is belt and braces, not a code path.
      userRefId: _session.employeeId,
      weekStart: weekStart,
      cells: cells,
      doneTicks: doneTicks,
    ));
    return TruckLocationJson.week(data);
  }

  @override
  Future<void> saveOrder(List<int> truckRefIds) => _remote.saveOrder(
        TruckLocationJson.orderRequest(
          companyId: _session.companyId,
          userRefId: _session.employeeId,
          truckRefIds: truckRefIds,
        ),
      );
}
