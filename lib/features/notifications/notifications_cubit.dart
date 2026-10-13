import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_api.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/core/logging/app_logger.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/features/notifications/notification_signals.dart';
import 'package:maleva/features/notifications/notification_summary_cubit.dart';

class NotificationsState {
  const NotificationsState({
    this.alerts,
    this.alertsError,
    this.vesselInbox,
    this.vesselError,
    this.otherInbox,
    this.otherError,
    this.loading = false,
    this.busy = const {},
  });

  /// Open vessel alerts, the caller's own first; null until loaded (or when the load failed).
  final List<VesselAlert>? alerts;

  /// Why the vessel alerts could not be checked (never shown as "no alerts").
  final String? alertsError;

  /// The vessel ETA notices (`?group=vessel`); null until loaded (or when the load failed).
  final NotificationInbox? vesselInbox;
  final String? vesselError;

  /// Every other notice (`?group=other`); never holds a vessel notice.
  final NotificationInbox? otherInbox;
  final String? otherError;
  final bool loading;

  /// The groups whose "Mark all read" is running.
  final Set<NoticeGroup> busy;

  NotificationInbox? inboxOf(NoticeGroup group) => group == NoticeGroup.vessel ? vesselInbox : otherInbox;

  String? errorOf(NoticeGroup group) => group == NoticeGroup.vessel ? vesselError : otherError;

  /// The Vessel tab's action-needed number: the open vessel alerts.
  int get vesselCount => alerts?.length ?? 0;

  int get vesselUnread => vesselInbox?.unreadCount ?? 0;

  int get otherUnread => otherInbox?.unreadCount ?? 0;

  int unreadOf(NoticeGroup group) => inboxOf(group)?.unreadCount ?? 0;

  /// [group] has something "Mark all read" can clear.
  bool canMarkAll(NoticeGroup group) =>
      !busy.contains(group) && (unreadOf(group) > 0 || (inboxOf(group)?.items.any((i) => !i.read) ?? false));

  /// The Vessel tab has nothing to show and its load failed: it shows the error with a retry.
  bool get vesselFailed => alerts == null && vesselInbox == null && (alertsError != null || vesselError != null);

  /// The Other tab has nothing to show and its load failed.
  bool get otherFailed => otherInbox == null && otherError != null;

  NotificationsState copyWith({
    List<VesselAlert>? alerts,
    NotificationInbox? vesselInbox,
    String? vesselError,
    bool clearVesselError = false,
    NotificationInbox? otherInbox,
    String? otherError,
    bool clearOtherError = false,
    bool? loading,
    Set<NoticeGroup>? busy,
  }) =>
      NotificationsState(
        alerts: alerts ?? this.alerts,
        alertsError: alertsError,
        vesselInbox: vesselInbox ?? this.vesselInbox,
        vesselError: clearVesselError ? null : (vesselError ?? this.vesselError),
        otherInbox: otherInbox ?? this.otherInbox,
        otherError: clearOtherError ? null : (otherError ?? this.otherError),
        loading: loading ?? this.loading,
        busy: busy ?? this.busy,
      );

  NotificationsState withInbox(NoticeGroup group, NotificationInbox inbox) =>
      group == NoticeGroup.vessel ? copyWith(vesselInbox: inbox) : copyWith(otherInbox: inbox);

  NotificationsState withError(NoticeGroup group, String error) =>
      group == NoticeGroup.vessel ? copyWith(vesselError: error) : copyWith(otherError: error);
}

/// The notifications page, in two separate tabs (owner, 2026-10-13): Vessel = open vessel alerts
/// (`/api/vessel-changes/alerts`) pinned on top and the vessel ETA notices (`mine?group=vessel`); Other =
/// every other notice (`mine?group=other`). All three load together; each failure is kept on its own.
/// Mark one read, or all of one tab. Reloads on [NotificationSignals] (a push arrived, jobs were updated).
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._notices, this._vessels, {Stream<void>? signals})
      : super(const NotificationsState(loading: true)) {
    _signals = (signals ?? NotificationSignals.refresh).listen((_) => load());
  }

  final EmployeeNotificationsApi _notices;
  final VesselChangesApi _vessels;
  StreamSubscription<void>? _signals;

  /// Loads the three lists at once. A list that fails keeps what was shown and says why.
  Future<void> load() async {
    emit(state.copyWith(loading: true));
    Object? vesselError;
    Object? otherError;
    Object? alertsError;
    final vesselCall = orNullOnError(() => _notices.mine(group: NoticeGroup.vessel), 'Vessel notices load',
        onError: (e) => vesselError = e);
    final otherCall = orNullOnError(() => _notices.mine(group: NoticeGroup.other), 'Notifications load',
        onError: (e) => otherError = e);
    final alertsCall = orNullOnError(_vessels.alerts, 'Vessel alerts load', onError: (e) => alertsError = e);
    final vessel = await vesselCall;
    final other = await otherCall;
    final alerts = await alertsCall;
    if (isClosed) return;
    emit(NotificationsState(
      vesselInbox: vessel?.only(NoticeGroup.vessel) ?? state.vesselInbox,
      vesselError: vesselError == null ? null : '$vesselError',
      otherInbox: other?.only(NoticeGroup.other) ?? state.otherInbox,
      otherError: otherError == null ? null : '$otherError',
      alerts: alerts == null ? state.alerts : pinMineFirst(alerts),
      alertsError: alertsError == null ? null : '$alertsError',
      busy: state.busy,
    ));
  }

  /// Marks [n] read in whichever tab holds it (shown read at once; put back when the server refuses)
  /// and tells the bell.
  Future<void> markRead(EmployeeNotification n) async {
    if (n.read) return;
    final group = _groupHolding(n);
    if (group == null) return;
    final before = state.inboxOf(group)!;
    _replace(
        group,
        (items, unread) => (
              [for (final i in items) i.id == n.id ? i.asRead() : i],
              unread > 0 ? unread - 1 : 0,
            ));
    try {
      await _notices.markRead(n.id);
      NotificationSignals.changed();
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Notification mark read');
      if (!isClosed) emit(state.withInbox(group, before));
    }
  }

  /// "Mark all read" of one tab only (`read-all?group=`); the other tab is never touched.
  Future<void> markAllRead(NoticeGroup group) async {
    if (!state.canMarkAll(group)) return;
    final before = state.inboxOf(group);
    emit(state.copyWith(busy: {...state.busy, group}));
    _replace(group, (items, _) => ([for (final i in items) i.read ? i : i.asRead()], 0));
    try {
      await _notices.markAllRead(group: group);
      if (!isClosed) emit(state.copyWith(busy: _without(group)));
      NotificationSignals.changed();
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Notifications mark all read');
      if (isClosed) return;
      var next = state.copyWith(busy: _without(group)).withError(group, '$e');
      if (before != null) next = next.withInbox(group, before);
      emit(next);
    }
  }

  /// "Not this vessel" on a LINK alert (`POST /api/vessel-changes/alerts/{id}/close`): on success the
  /// card goes at once and the bell, the banner and this page reload ([NotificationSignals]). Answers
  /// the server's refusal message, or null when it closed.
  Future<String?> closeAlert(VesselAlert alert) async {
    try {
      await _vessels.closeAlert(alert.id);
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Vessel alert close');
      return '$e';
    }
    if (!isClosed && state.alerts != null) {
      emit(state.copyWith(alerts: [
        for (final a in state.alerts!)
          if (a.id != alert.id) a
      ]));
    }
    NotificationSignals.changed();
    return null;
  }

  Set<NoticeGroup> _without(NoticeGroup group) => {...state.busy}..remove(group);

  NoticeGroup? _groupHolding(EmployeeNotification n) {
    for (final g in NoticeGroup.values) {
      if (state.inboxOf(g)?.items.any((i) => i.id == n.id) ?? false) return g;
    }
    return null;
  }

  void _replace(
    NoticeGroup group,
    (List<EmployeeNotification>, int) Function(List<EmployeeNotification> items, int unread) change,
  ) {
    final inbox = state.inboxOf(group);
    if (inbox == null) return;
    final (items, unread) = change(inbox.items, inbox.unreadCount);
    emit(state.withInbox(group, NotificationInbox(unreadCount: unread, items: items)));
  }

  @override
  Future<void> close() {
    _signals?.cancel();
    return super.close();
  }
}
