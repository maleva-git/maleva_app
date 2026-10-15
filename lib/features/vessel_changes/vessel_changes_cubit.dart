import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/logging/app_logger.dart';
import 'package:maleva/core/vessel_changes/vessel_change_look.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';
import 'package:maleva/features/notifications/notification_signals.dart';

/// A job's leg on one vessel call, as the screen keys it.
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

class VesselChangesState {
  const VesselChangesState({
    this.scope = 'me',
    this.data,
    this.loading = false,
    this.error,
    this.confirmedBoarding = const {},
    this.busy = false,
    this.notes = const [],
    this.refused = const {},
    this.done,
    this.doneSeq = 0,
  });

  /// `me` (My jobs) or `team` (My team).
  final String scope;
  final VesselChanges? data;
  final bool loading;

  /// The server's message when the list could not be loaded (the screen shows it with a retry).
  final String? error;

  /// Rows whose boarding month change the user confirmed.
  final Set<String> confirmedBoarding;

  /// An update or dismiss is running.
  final bool busy;

  /// What the last update did: jobs updated, refused (named, with why), held.
  final List<String> notes;

  /// Why a listed job was not updated (by [vesselJobKey]), shown on its row.
  final Map<String, String> refused;

  /// What the last update did, for the snackbar ("MY002605808 updated to PTP's times"); shown once per
  /// [doneSeq].
  final String? done;
  final int doneSeq;

  VesselChangesState copyWith({
    String? scope,
    VesselChanges? data,
    bool clearData = false,
    bool? loading,
    String? error,
    bool clearError = false,
    Set<String>? confirmedBoarding,
    bool? busy,
    List<String>? notes,
    Map<String, String>? refused,
    String? done,
    int? doneSeq,
  }) =>
      VesselChangesState(
        scope: scope ?? this.scope,
        data: clearData ? null : (data ?? this.data),
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        confirmedBoarding: confirmedBoarding ?? this.confirmedBoarding,
        busy: busy ?? this.busy,
        notes: notes ?? this.notes,
        refused: refused ?? this.refused,
        done: done ?? this.done,
        doneSeq: doneSeq ?? this.doneSeq,
      );
}

/// The "Vessel changes" screen (shared `/api/vessel-changes`, change vessel-master-and-ptp-schedule):
/// load, apply PTP's times (one job, or all jobs of a vessel call) through the Vessel Planning bulk update,
/// dismiss. Pickup and delivery are not moved with the ETA (the owner removed that on 2026-10-13).
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
        confirmedBoarding: state.confirmedBoarding.intersection(keys),
        refused: {for (final e in state.refused.entries) if (keys.contains(e.key)) e.key: e.value},
      ));
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Vessel changes load');
      if (!isClosed) emit(state.copyWith(loading: false, clearData: true, error: '$e'));
    }
  }

  /// The user agrees the boarding pay may move to the other month; the row can now be updated.
  void confirmBoarding(VesselChangeGroup group, VesselChangeJob job) =>
      emit(state.copyWith(confirmedBoarding: {...state.confirmedBoarding, vesselJobKey(group.call.id, job)}));

  /// "Update all N jobs to PTP": every job of [group].
  Future<void> update(VesselChangeGroup group) => _apply(group, group.jobs);

  /// "Use PTP's times" on one job: only that job.
  Future<void> updateJob(VesselChangeGroup group, VesselChangeJob job) => _apply(group, [job]);

  /// PTP's ETA and ETD on [chosen] through the bulk update (one request per leg type and PTP time pair,
  /// only that leg's two dates). Rows with an unconfirmed boarding month change wait. The updated jobs
  /// are said in a snackbar, refused and held ones in the notes; then the list reloads.
  Future<void> _apply(VesselChangeGroup group, List<VesselChangeJob> chosen) async {
    final callId = group.call.id;
    // an omitted call's times are not the job's: those jobs get another vessel or voyage, or are dismissed
    if (chosen.isEmpty || state.busy || group.call.omitted) return;
    final held = [
      for (final j in chosen)
        if (j.boardingMonthChanges && !state.confirmedBoarding.contains(vesselJobKey(callId, j))) j
    ];
    final send = [for (final j in chosen) if (!held.contains(j)) j];
    final notes = <String>[];
    final refused = <String, String>{};

    emit(state.copyWith(busy: true, notes: const [], refused: const {}));

    // ETA / ETD: one request per leg type and per PTP time pair
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
            notes.add('${vesselJobName(j)}: not updated - $why');
          }
        }
      } catch (e, st) {
        AppLogger.instance.logError(e, st, 'Vessel changes update');
        for (final j in batch) {
          refused[vesselJobKey(callId, j)] = '$e';
          notes.add('${vesselJobName(j)}: not updated - $e');
        }
      }
    }

    for (final j in held) {
      notes.add('${vesselJobName(j)} waits for confirmation: boarding pay moves from '
          '${boardingMonthText(j.boardingMonthFrom)} to ${boardingMonthText(j.boardingMonthTo)}');
    }

    if (isClosed) return;
    emit(state.copyWith(
      busy: false,
      notes: notes,
      refused: refused,
      done: ok.isEmpty ? null : updatedText(ok, label: group.call.sourceLabel),
      doneSeq: ok.isEmpty ? null : state.doneSeq + 1,
    ));
    await load();
    // the bell, banner and pinned vessel alerts re-check the jobs
    if (ok.isNotEmpty) NotificationSignals.changed();
  }

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

  /// "Keep mine (dismiss)": the job's leg is no longer listed for this call.
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
