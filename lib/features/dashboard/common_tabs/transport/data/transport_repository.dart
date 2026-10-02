import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';

/// The transport list (today's pickups or a later day's planning), from the
/// shared Java APIs; rows keep the .NET names (`Id`, `CustomerName`, ...).
class TransportRepository {
  TransportRepository({DashboardApi? api}) : _api = api;

  final DashboardApi? _api;

  /// [type] is the day offset: 0 today, 1 tomorrow.
  Future<List<Map<String, dynamic>>> fetchTransportData({required int type, required int comid}) =>
      (_api ?? sl<DashboardApi>()).transportList(comid, type);
}
