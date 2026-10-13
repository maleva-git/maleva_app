import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/logging/app_logger.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';
import 'package:maleva/features/notifications/notification_signals.dart';

/// A job's leg on one vessel call, as the screen selects it.
String vesselJobKey(int callId, VesselChangeJob job) => '$callId|${job.saleOrderId}|${job.leg}';

/// A Java vessel time (`yyyy-MM-dd'T'HH:mm`) shown as "15 Oct 08:00"; "-" for none.
String vesselTimeText(String? value) {
  final d = vesselTime(value);
  return d == null ? '-' : DateFormat('dd MMM HH:mm').format(d);
}

/// `2026-10` as "Oct 2026".
String boardingMonthText(String? value) {
  final d = value == null ? null : DateTime.tryParse('$value-01');
  return d == null ? (value ?? '-') : DateFormat('MMM yyyy').format(d);
}

/// Why a leg's pickup and delivery do not move, in words; null when they can or the job's other leg moves them.
String? pickupReasonText(VesselChangeJob job) {
  switch (job.pickupMoveReason) {
    case PickupMoveReason.planned:
      return 'Planned for ${vesselTimeText(job.plannedDate)}, re-plan in Planning';
    case PickupMoveReason.collected:
      return 'Already collected';
    case PickupMoveReason.past:
      return 'Date in the past';
    case PickupMoveReason.noDates:
      return 'No pickup or delivery date';
    default:
      return null;
  }
}

/// A move request's outcome, in words.
String moveOutcomeText(MoveResult r) {
  switch (r.outcome) {
    case MoveOutcome.moved:
      return 'Pickup and delivery moved';
    case MoveOutcome.planned:
      return 'Planned, re-plan in Planning';
    case MoveOutcome.collected:
      return 'Already collected';
    case MoveOutcome.past:
      return 'Date in the past';
    case MoveOutcome.noDates:
      return 'No pickup or delivery date';
    case MoveOutcome.notThisLeg:
      return "Follows the job's other leg";
    case MoveOutcome.unreadableTimes:
      return 'Pickup or delivery time could not be read';
    case MoveOutcome.notFound:
      return 'Job not found';
    case MoveOutcome.failed:
      return 'Failed, nothing changed';
    default:
      return r.outcome; // an outcome this app does not know yet: shown by its code
  }
}

class VesselChangesState {
  const VesselChangesState({
    this.scope = 'me',
    this.data,
    this.loading = false,
    this.error,
    this.selected = const {},
    this.confirmedBoarding = const {},
    this.movePickupDelivery = true,
    this.busy = false,
    this.notes = const [],
    this.refused = const {},
  });

  /// `me` (My jobs) or `team` (My team).
  final String scope;
  final VesselChanges? data;
  final bool loading;

  /// The server's message when the list could not be loaded (the screen shows it with a retry).
  final String? error;

  /// [vesselJobKey]s ticked for "Update these jobs".
  final Set<String> selected;

  /// Rows whose boarding month change the user confirmed.
  final Set<String> confirmedBoarding;

  /// "Also move pickup and delivery" (on by default).
  final bool movePickupDelivery;

  /// An update or dismiss is running.
  final bool busy;

  /// What the last update did: jobs updated, refused (named, with why), held, to re-plan.
  final List<String> notes;

  /// Why a listed job was not updated (by [vesselJobKey]), shown on its row.
  final Map<String, String> refused;

  VesselChangesState copyWith({
    String? scope,
    VesselChanges? data,
    bool clearData = false,
    bool? loading,
    String? error,
    bool clearError = false,
    Set<String>? selected,
    Set<String>? confirmedBoarding,
    bool? movePickupDelivery,
    bool? busy,
    List<String>? notes,
    Map<String, String>? refused,
  }) =>
      VesselChangesState(
        scope: scope ?? this.scope,
        data: clearData ? null : (data ?? this.data),
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        selected: selected ?? this.selected,
        confirmedBoarding: confirmedBoarding ?? this.confirmedBoarding,
        movePickupDelivery: movePickupDelivery ?? this.movePickupDelivery,
        busy: busy ?? this.busy,
        notes: notes ?? this.notes,
        refused: refused ?? this.refused,
      );
}

/// The "Vessel changes" screen (shared `/api/vessel-changes`, change vessel-master-and-ptp-schedule):
/// load, select, apply PTP's times through the Vessel Planning bulk update, move pickup and delivery,
/// dismiss.
class VesselChangesCubit extends Cubit<VesselChangesState> {
  /// [scope] is the scope the screen opens with (`team` from a leader's "Not handled" notice).
  VesselChangesCubit(this._api, {String scope = 'me'}) : super(VesselChangesState(scope: scope, loading: true));

  final VesselChangesApi _api;

  /// Loads [scope] (or the current one). A failure shows the error, not an empty list.
  Future<void> load({String? scope}) async {
    final changingScope = scope != null && scope != state.scope;
    emit(state.copyWith(
      scope: scope,
      loading: true,
      clearError: true,
      clearData: changingScope,
      selected: changingScope ? const {} : null,
      notes: changingScope ? const [] : null,
      refused: changingScope ? const {} : null,
    ));
    try {
      final data = await _api.list(scope: state.scope);
      if (isClosed) return;
      final keys = {
        for (final g in data.groups)
          for (final j in g.jobs) vesselJobKey(g.call.id, j)
      };
      emit(state.copyWith(
        data: data,
        loading: false,
        selected: state.selected.intersection(keys),
        confirmedBoarding: state.confirmedBoarding.intersection(keys),
        refused: {for (final e in state.refused.entries) if (keys.contains(e.key)) e.key: e.value},
      ));
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Vessel changes load');
      if (!isClosed) emit(state.copyWith(loading: false, clearData: true, error: '$e'));
    }
  }

  void toggle(VesselChangeGroup group, VesselChangeJob job, bool on) {
    final key = vesselJobKey(group.call.id, job);
    emit(state.copyWith(selected: on ? {...state.selected, key} : ({...state.selected}..remove(key))));
  }

  void selectAll(VesselChangeGroup group, bool on) {
    final keys = {for (final j in group.jobs) vesselJobKey(group.call.id, j)};
    emit(state.copyWith(selected: on ? {...state.selected, ...keys} : state.selected.difference(keys)));
  }

  /// The user agrees the boarding pay may move to the other month; the row can now be updated.
  void confirmBoarding(VesselChangeGroup group, VesselChangeJob job) =>
      emit(state.copyWith(confirmedBoarding: {...state.confirmedBoarding, vesselJobKey(group.call.id, job)}));

  void setMovePickupDelivery(bool on) => emit(state.copyWith(movePickupDelivery: on));

  /// "Update these jobs" for the selected rows of [group]: PTP's ETA and ETD through the bulk update
  /// (one request per leg type and PTP time pair, only that leg's two dates), then - with "Also move
  /// pickup and delivery" on - the move request for the legs whose update was ok and whose
  /// pickup can move. Rows with an unconfirmed boarding month change wait. Then the list reloads.
  Future<void> update(VesselChangeGroup group) async {
    final callId = group.call.id;
    final chosen = [for (final j in group.jobs) if (state.selected.contains(vesselJobKey(callId, j))) j];
    if (chosen.isEmpty || state.busy) return;
    final held = [
      for (final j in chosen)
        if (j.boardingMonthChanges && !state.confirmedBoarding.contains(vesselJobKey(callId, j))) j
    ];
    final send = [for (final j in chosen) if (!held.contains(j)) j];
    final notes = <String>[];
    final refused = <String, String>{};
    String nameOf(VesselChangeJob j) => j.jobNo.isEmpty ? '#${j.saleOrderId}' : j.jobNo;

    emit(state.copyWith(busy: true, notes: const [], refused: const {}));

    // 1. ETA / ETD: one request per leg type and per PTP time pair
    final batches = <String, List<VesselChangeJob>>{};
    for (final j in send) {
      batches.putIfAbsent('${j.leg}|${j.ptpEta}|${j.ptpEtd}', () => []).add(j);
    }
    final ok = <VesselChangeJob>[];
    for (final batch in batches.values) {
      final first = batch.first;
      try {
        final result = await _api.applyTimes(
            leg: first.leg, saleOrderIds: [for (final j in batch) j.saleOrderId], eta: first.ptpEta, etd: first.ptpEtd);
        final byId = {for (final r in result.results) r.saleOrderId: r};
        for (final j in batch) {
          final r = byId[j.saleOrderId];
          if (r?.ok ?? (result.results.isEmpty && result.updated == result.requested)) {
            ok.add(j);
          } else {
            final why = r?.message ?? 'Not updated';
            refused[vesselJobKey(callId, j)] = why;
            notes.add('${nameOf(j)}: not updated - $why');
          }
        }
      } catch (e, st) {
        AppLogger.instance.logError(e, st, 'Vessel changes update');
        for (final j in batch) {
          refused[vesselJobKey(callId, j)] = '$e';
          notes.add('${nameOf(j)}: not updated - $e');
        }
      }
    }

    // 2. Pickup and delivery: legs whose ETA update was ok and that can move (the server names the leg; never PLANNED)
    if (state.movePickupDelivery) {
      final movable = [for (final j in ok) if (j.canMovePickup) j];
      if (movable.isNotEmpty) {
        try {
          final moves = await _api.movePickupDelivery(
              ptpVesselCallId: callId, saleOrderIds: [for (final j in movable) j.saleOrderId]);
          for (final m in moves) {
            if (!m.moved) {
              notes.add('${m.jobNo ?? '#${m.saleOrderId}'}: pickup and delivery not moved - ${moveOutcomeText(m)}');
            }
          }
        } catch (e, st) {
          AppLogger.instance.logError(e, st, 'Vessel changes move pickup and delivery');
          for (final j in movable) {
            notes.add('${nameOf(j)}: pickup and delivery not moved - $e');
          }
        }
      }
    }
    for (final j in ok) {
      if (j.pickupMoveReason == PickupMoveReason.planned) {
        notes.add('${nameOf(j)}: ${pickupReasonText(j)}');
      }
    }
    for (final j in held) {
      notes.add('${nameOf(j)} waits for confirmation: boarding pay moves from '
          '${boardingMonthText(j.boardingMonthFrom)} to ${boardingMonthText(j.boardingMonthTo)}');
    }
    if (ok.isNotEmpty) notes.insert(0, 'Updated ${ok.length} job${ok.length == 1 ? '' : 's'}.');

    if (isClosed) return;
    emit(state.copyWith(
      busy: false,
      notes: notes,
      refused: refused,
      selected: state.selected.difference({for (final j in ok) vesselJobKey(callId, j)}),
    ));
    await load();
    // the bell, banner and pinned vessel alerts re-check the jobs
    if (ok.isNotEmpty) NotificationSignals.changed();
  }

  /// "Dismiss": the job's leg is no longer listed for this call.
  /// "Read PTP now": refreshes PTP's schedule (or reuses a read from the last few minutes), says what
  /// happened, then reloads the list, which now compares the jobs with the fresh times.
  Future<void> readPtpNow() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, notes: const []));
    String note;
    try {
      final r = await _api.readPtpNow();
      note = r.recent
          ? 'PTP was read at ${vesselTimeText(r.startedAt)}; this is the latest schedule'
          : r.ok
              ? 'PTP read: ${r.rows} vessel calls, ${r.changes} changes'
              : 'PTP read failed${r.message == null ? '' : ': ${r.message}'}';
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Read PTP now');
      note = 'Could not read PTP now: $e';
    }
    if (isClosed) return;
    emit(state.copyWith(busy: false, notes: [note]));
    await load();
  }

  Future<void> dismiss(VesselChangeGroup group, VesselChangeJob job) async {
    final key = vesselJobKey(group.call.id, job);
    emit(state.copyWith(busy: true));
    try {
      await _api.dismiss(saleOrderId: job.saleOrderId, leg: job.leg, ptpVesselCallId: group.call.id);
      NotificationSignals.changed();
      if (isClosed) return;
      final data = state.data;
      emit(state.copyWith(
        busy: false,
        selected: {...state.selected}..remove(key),
        data: data == null
            ? null
            : VesselChanges(lastGoodReadAt: data.lastGoodReadAt, groups: [
                for (final g in data.groups)
                  if (g.call.id != group.call.id)
                    g
                  else if (g.jobs.length > 1)
                    g.withJobs([for (final j in g.jobs) if (vesselJobKey(g.call.id, j) != key) j])
              ]),
      ));
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Vessel changes dismiss');
      if (!isClosed) emit(state.copyWith(busy: false, notes: ['${job.jobNo}: not dismissed - $e']));
    }
  }
}
