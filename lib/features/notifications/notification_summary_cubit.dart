import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_api.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/core/logging/app_logger.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/features/notifications/notification_signals.dart';

class NotificationSummaryState {
  const NotificationSummaryState({this.otherUnread = 0, this.vesselUnread = 0, this.alerts = const []});

  /// Unread notices other than vessel ETA ones (`mine?group=other`): the bell's badge.
  final int otherUnread;

  /// Unread vessel ETA notices (`mine?group=vessel`): the ship's amber badge when no alert is open.
  final int vesselUnread;

  /// Open vessel alerts: the caller's own first, then the team's escalated ones.
  final List<VesselAlert> alerts;

  List<VesselAlert> get mineAlerts => [
        for (final a in alerts)
          if (a.mine) a
      ];

  List<VesselAlert> get teamAlerts => [
        for (final a in alerts)
          if (!a.mine) a
      ];
}

/// What the dashboard bell, ship and banner show, the two kinds kept apart (owner, 2026-10-13): the
/// unread counts of `/api/employee-notifications/mine?group=other` and `?group=vessel`, and the open
/// vessel alerts (`/api/vessel-changes/alerts`). One per app (DI singleton) so the bell and the banner
/// share one fetch; reloads on [NotificationSignals]. A failed fetch keeps the last numbers.
class NotificationSummaryCubit extends Cubit<NotificationSummaryState> {
  NotificationSummaryCubit(this._notices, this._vessels, {Stream<void>? signals})
      : super(const NotificationSummaryState()) {
    _signals = (signals ?? NotificationSignals.refresh).listen((_) => load());
  }

  final EmployeeNotificationsApi _notices;
  final VesselChangesApi _vessels;
  StreamSubscription<void>? _signals;
  Future<void>? _running;

  /// Loads the counts; a call while one is running waits for that one.
  Future<void> load() => _running ??= _load().whenComplete(() => _running = null);

  Future<void> _load() async {
    // the requests run at once; a failed one keeps its last value
    final otherCall = orNullOnError(() => _notices.mine(group: NoticeGroup.other), 'Notification count');
    final vesselCall = orNullOnError(() => _notices.mine(group: NoticeGroup.vessel), 'Vessel notice count');
    final alertsCall = orNullOnError(_vessels.alerts, 'Vessel alerts');
    final other = await otherCall;
    final vessel = await vesselCall;
    final alerts = await alertsCall;
    if (isClosed) return;
    emit(NotificationSummaryState(
      otherUnread: other?.only(NoticeGroup.other).unreadCount ?? state.otherUnread,
      vesselUnread: vessel?.only(NoticeGroup.vessel).unreadCount ?? state.vesselUnread,
      alerts: alerts == null ? state.alerts : pinMineFirst(alerts),
    ));
  }

  /// Signed out: nothing of the last person is shown to the next one.
  void clear() => emit(const NotificationSummaryState());

  @override
  Future<void> close() {
    _signals?.cancel();
    return super.close();
  }
}

/// [call]'s answer, or null (logged, and passed to [onError]) when it failed.
Future<T?> orNullOnError<T>(Future<T> Function() call, String what, {void Function(Object error)? onError}) async {
  try {
    return await call();
  } catch (e, st) {
    AppLogger.instance.logError(e, st, what);
    onError?.call(e);
    return null;
  }
}

/// The caller's own alerts first, then the team's, each in the server's order.
List<VesselAlert> pinMineFirst(List<VesselAlert> alerts) => [
      for (final a in alerts)
        if (a.mine) a,
      for (final a in alerts)
        if (!a.mine) a
    ];
