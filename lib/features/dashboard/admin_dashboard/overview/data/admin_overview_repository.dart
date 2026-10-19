import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/job_order/job_order_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_filter.dart';
import 'package:maleva/features/ir_report/domain/repositories/ir_repository.dart';
import 'package:maleva/features/truck_location/domain/repositories/truck_location_repository.dart';

import 'admin_overview_models.dart';

/// The Overview tab's data, from the shared Java endpoints the app already calls for each area's own
/// screen (change `super-admin-overview-tab`). No endpoint of its own.
class AdminOverviewRepository {
  AdminOverviewRepository({
    required DashboardApi dashboard,
    required JobOrderApi jobOrders,
    required MailMonitorApi mail,
    required IrRepository incidents,
    required TruckLocationRepository trucks,
    required AppSession session,
    DateTime Function()? clock,
  })  : _dashboard = dashboard,
        _jobOrders = jobOrders,
        _mail = mail,
        _incidents = incidents,
        _trucks = trucks,
        _session = session,
        _clock = clock ?? DateTime.now;

  factory AdminOverviewRepository.fromServiceLocator() => AdminOverviewRepository(
        dashboard: sl<DashboardApi>(),
        jobOrders: sl<JobOrderApi>(),
        mail: sl<MailMonitorApi>(),
        incidents: sl<IrRepository>(),
        trucks: sl<TruckLocationRepository>(),
        session: sl<AppSession>(),
      );

  final DashboardApi _dashboard;
  final JobOrderApi _jobOrders;
  final MailMonitorApi _mail;
  final IrRepository _incidents;
  final TruckLocationRepository _trucks;
  final AppSession _session;
  final DateTime Function() _clock;

  int get _comid => _session.companyId;
  DateTime get _today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  /// The SO tab's "all" numbers (type 1).
  Future<SalesSummary> sales() async => SalesSummary.fromJava(await _dashboard.sales(_comid, 1));

  /// The invoice numbers (type 0), the web report card's Invoice view.
  Future<SalesSummary> invoices() async => SalesSummary.fromJava(await _dashboard.sales(_comid, 0));

  Future<JobOrderSummary> jobOrders() async => JobOrderSummary.fromRows(await _jobOrders.list());

  Future<MailSummary> mail() async => MailSummary.of(await _mail.mailboxes());

  /// Open reports with an incident date in the last 30 days.
  Future<IrSummary> incidents() async =>
      IrSummary.of(await _incidents.search(IrFilter.lastDays(30, today: _today).copyWith(openOnly: true)));

  Future<TruckLocationSummary> truckLocation() async {
    final day = Fmt.ymd(_today);
    return TruckLocationSummary.of(await _trucks.week(day), day);
  }
}
