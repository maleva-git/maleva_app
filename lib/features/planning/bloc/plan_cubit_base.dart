import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/data/planning_repository.dart';
import 'package:maleva/features/planning/data/planning_rules.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

/// What the plan cubit's parts share: messages, the access guard and change tracking.
mixin PlanCubitBase on Cubit<PlanState> {
  PlanningRepository get repo;

  int _noticeSeq = 0;

  /// A toast of the web, shown once.
  void notify(String message, [NoticeKind kind = NoticeKind.success]) => emit(state.copyWith(notice: PlanNotice(message, kind, ++_noticeSeq)));

  /// The role may change the plan; otherwise the web's reason is shown
  /// (`toast.error(access.deniedReason, {id: 'planning-access-denied'})`).
  bool guardWrite() {
    final a = state.access;
    if (a.canWrite) return true;
    notify(a.deniedReason, NoticeKind.error);
    return false;
  }

  /// Rows edited here: the web's dirty marks (by job) and the "N changes" count (by row).
  PlanState markEdited(PlanState s, Iterable<PlanLine> edited) => s.copyWith(
        dirtyJobIds: {
          ...s.dirtyJobIds,
          for (final r in edited)
            if (r.saleOrderMasterRefId != 0) r.saleOrderMasterRefId
        },
        changedUids: {...s.changedUids, for (final r in edited) r.uid},
      );

  /// Replaces the rows whose uid is in [uids] with [change] of them.
  List<PlanLine> mapRows(Set<int> uids, PlanLine Function(PlanLine) change) => [for (final r in state.rows) uids.contains(r.uid) ? change(r) : r];

  /// The RTI badges, fetched again whenever the set of jobs changes; a failure is silent.
  Future<void> syncRtiStatuses() async {
    final key = PlanningRules.jobKey(state.rows);
    if (key.isEmpty || key == state.rtiKey) return;
    emit(state.copyWith(rtiKey: key));
    try {
      final ids = key.split(',').map(int.parse).toList();
      final statuses = await repo.rtiStatus(ids);
      if (isClosed) return;
      final next = PlanningRules.applyRtiStatuses(state.rows, statuses);
      if (!identical(next, state.rows)) emit(state.copyWith(rows: next));
    } catch (_) {
      // Status badges are informational: never block the grid on a failed lookup.
    }
  }
}
