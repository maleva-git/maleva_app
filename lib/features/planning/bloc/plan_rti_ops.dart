import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/bloc/plan_cubit_base.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/data/planning_rti_batch.dart';
import 'package:maleva/features/planning/data/planning_transfer.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/plan_line_copy.dart';
import 'package:maleva/features/planning/models/rti_batch.dart';
import 'package:maleva/features/rti/data/rti_from_planning.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';

/// Planning → RTI: Create RTI, Push RTI, Create All RTI's result, Revise / Open from a row.
mixin PlanRtiOps on Cubit<PlanState>, PlanCubitBase {
  RtiFromPlanning get rtiFromPlanning;

  /// Create RTI before its review: false (with the web's refusal) when it may not run.
  bool canCreateRti() {
    if (!guardWrite()) return false;
    if (state.ticked.isEmpty) {
      notify('Tick the jobs for this RTI first, or use Create All RTI', NoticeKind.error);
      return false;
    }
    return true;
  }

  /// The ticked rows as RTI items (truck / driver ids looked up by name, outside flag).
  List<PlanningTransferItem> tickedItems() => PlanningTransfer.items(state.ticked, drivers: state.drivers, trucks: state.trucks);

  /// One RTI from the ticked rows, created now (`usePlanningListPage.ts:703-744`). The rows get
  /// the new number and lose their tick.
  Future<void> createRti() async {
    if (state.rtiStage == RtiCreateStage.working) return;
    if (!canCreateRti()) return;
    final ticked = state.ticked;
    emit(state.copyWith(rtiStage: RtiCreateStage.working, rtiMessage: ''));
    try {
      final created = await rtiFromPlanning.create(tickedItems());
      final n = ticked.length;
      final message = created.rtiNo.isNotEmpty ? 'RTI ${created.rtiNo} created with $n job${n == 1 ? '' : 's'}' : 'RTI created successfully';
      emit(state.copyWith(
        rows: [
          for (final r in state.rows)
            r.print
                ? r.copyWith(
                    print: false,
                    rtiNo: created.rtiNo.isNotEmpty ? created.rtiNo : r.rtiNo,
                    rtiMasterRefId: created.id != 0 ? created.id : r.rtiMasterRefId)
                : r,
        ],
        rtiStage: RtiCreateStage.done,
        rtiMessage: message,
      ));
      notify(message);
    } on RtiCreateRefused catch (e) {
      emit(state.copyWith(rtiStage: RtiCreateStage.refused, rtiMessage: e.message));
      notify(e.message, NoticeKind.error);
    } catch (e) {
      final message = errorText(e, 'Failed to create RTI');
      emit(state.copyWith(rtiStage: RtiCreateStage.refused, rtiMessage: message));
      notify(message, NoticeKind.error);
    }
  }

  void resetRtiStage() => emit(state.copyWith(rtiStage: RtiCreateStage.idle, rtiMessage: ''));

  /// Push RTI's items, or null after the web's refusal (`usePlanningOperations.ts:223-248`).
  List<PlanningTransferItem>? pushItems() {
    if (!guardWrite()) return null;
    if (state.ticked.isEmpty) {
      notify('Please select orders to push to RTI', NoticeKind.error);
      return null;
    }
    final items = tickedItems();
    if (items.isEmpty) {
      notify('Unable to prepare the selected orders for RTI', NoticeKind.error);
      return null;
    }
    return items;
  }

  /// Create All RTI before its preview: the plan id, or null after the web's refusal
  /// (`useCreateAllRti.ts:72-111`). Ticks are ignored on purpose.
  int? createAllPlanId() {
    if (!guardWrite()) return null;
    if (state.editId <= 0) {
      notify('Save the plan first, then create its RTI.', NoticeKind.error);
      return null;
    }
    if (repo.companyId <= 0) {
      notify('Company is required.', NoticeKind.error);
      return null;
    }
    return state.editId;
  }

  /// After Create All RTI: the new numbers on the rows it covered, and every tick cleared.
  void applyBatchResult(RtiBatchResult result, RtiBatchPreview preview) {
    final stamped = RtiBatchRules.applyResultToRows(state.rows, result, preview);
    emit(state.copyWith(rows: [for (final r in stamped) r.print ? r.copyWith(print: false) : r]));
  }

  /// "Revise RTI" / "Open RTI" on a row: the RTI id, or null after the web's refusal
  /// (`usePlanningListPage.ts:813-868`). Revise changes the RTI, so it needs write access.
  int? rtiOf(PlanLine row, {bool revise = false}) {
    if (revise && !guardWrite()) return null;
    if (row.rtiMasterRefId <= 0) {
      notify('No RTI created for this job yet', NoticeKind.error);
      return null;
    }
    return row.rtiMasterRefId;
  }
}
