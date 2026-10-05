import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/data/planning_rules.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/planning_navigation.dart';
import 'package:maleva/features/planning/view/create_all/create_all_rti_view.dart';
import 'package:maleva/features/planning/view/sale_order_update/sale_order_update_page.dart';
import 'package:maleva/features/planning/widgets/rti_review_sheet.dart';
import 'package:maleva/features/rti/rti_navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// The web's Truck Location board (Q-TRUCKLOC: opened in the device browser). The web app's
/// host is taken to be the Java host; change here if the web is served elsewhere.
final Uri truckLocationBoardUrl = Uri.parse('${AppConfig.javaBaseUrl}/truck-location-board');

/// The plan screen's flows that need a confirm, a sheet or another page. Each checks the
/// role first and words every step as the web does.
abstract final class PlanFlows {
  static PlanCubit _c(BuildContext context) => context.read<PlanCubit>();

  static Future<void> _guarded(BuildContext context, Future<void> Function() open) async {
    try {
      await open();
    } on UnimplementedError {
      if (context.mounted) showSnack(context, 'This screen is not available in the app yet', kind: SnackKind.info);
    }
  }

  /// Clone (`PlanningFilters.tsx:539-548`).
  static Future<void> clone(BuildContext context, [int? uid]) async {
    final cubit = _c(context);
    if (!cubit.canClone(uid)) return;
    final ok = await showConfirm(context,
        title: 'Duplicate Planning Row?',
        message: 'This row will be duplicated and added to the planning list. The truck assignment will be cleared.',
        confirmLabel: 'Duplicate');
    if (ok && !cubit.isClosed) cubit.clone(uid);
  }

  /// Remove a row (`useConfirm('delete')`).
  static Future<void> remove(BuildContext context, int uid) async {
    final cubit = _c(context);
    if (!cubit.guardWrite()) return;
    final ok = await showConfirm(context,
        title: 'Delete Record', message: 'This action cannot be undone. Continue?', confirmLabel: 'Delete', destructive: true);
    if (ok && !cubit.isClosed) cubit.remove(uid);
  }

  /// Delete the plan (`PlanningList.tsx:411-420`).
  static Future<void> deletePlan(BuildContext context) async {
    final cubit = _c(context);
    if (!cubit.canDelete()) return;
    final ok = await showConfirm(context,
        title: 'Delete Planning',
        message: 'Are you sure you want to delete this planning? This action cannot be undone.',
        confirmLabel: 'Delete',
        destructive: true);
    if (ok && !cubit.isClosed) await cubit.delete();
  }

  /// Leaving unsaved work asks first (PV8); answers true when the user may go on.
  static Future<bool> confirmDiscard(BuildContext context) async {
    final s = _c(context).state;
    if (!s.hasChanges) return true;
    return showConfirm(context,
        title: 'Discard changes?',
        message: '${s.changeCount} ${s.changeCount == 1 ? 'change is' : 'changes are'} not saved. They will be lost.',
        confirmLabel: 'Discard',
        destructive: true);
  }

  /// Clear / New plan.
  static Future<void> newPlan(BuildContext context) async {
    final cubit = _c(context);
    if (await confirmDiscard(context) && !cubit.isClosed) await cubit.newPlan();
  }

  /// Excel: the CSV through the share sheet.
  static Future<void> exportCsv(BuildContext context) async {
    final cubit = _c(context);
    final rows = cubit.state.rows;
    if (rows.isEmpty) {
      cubit.notify('No data to export', NoticeKind.error);
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${PlanningRules.csvFileName(DateTime.now())}');
      await file.writeAsString(PlanningRules.csv(rows));
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
      if (!cubit.isClosed) cubit.notify('Excel downloaded successfully');
    } catch (e) {
      if (!cubit.isClosed) cubit.notify('$e', NoticeKind.error);
    }
  }

  static Future<void> truckLocation(BuildContext context) async {
    final ok = await launchUrl(truckLocationBoardUrl, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) showSnack(context, 'Could not open $truckLocationBoardUrl', kind: SnackKind.error);
  }

  /// F5 / Plans: the saved plans list.
  static Future<void> openPlans(BuildContext context) async {
    if (!await confirmDiscard(context) || !context.mounted) return;
    await _guarded(context, () => PlanningNavigation.openPlans(context));
  }

  /// Update sale order (`handleUpdateRow`): the refusal, or the Update window.
  static Future<void> updateSaleOrder(BuildContext context, [int? uid]) async {
    final cubit = _c(context);
    final refusal = cubit.updateRefusal(uid);
    if (refusal != null) {
      cubit.notify(refusal, NoticeKind.error);
      return;
    }
    final row = uid == null ? cubit.state.selected! : cubit.state.rows.firstWhere((r) => r.uid == uid);
    final saved = await SaleOrderUpdatePage.open(context, saleOrderId: row.saleOrderMasterRefId, jobNo: row.jobNo, repo: cubit.repo);
    if (saved != null && !cubit.isClosed) {
      cubit.applySaleOrderUpdate(saved.$1);
      cubit.notify(saved.$2);
    }
  }

  /// Create RTI: refused when nothing is ticked, else the review sheet.
  static Future<void> createRti(BuildContext context) async {
    final cubit = _c(context);
    if (!cubit.canCreateRti()) return;
    cubit.resetRtiStage();
    await RtiReviewSheet.showCreate(context, cubit);
  }

  /// Push RTI: the review, then the RTI form opened with the ticked jobs (the user saves there).
  static Future<void> pushRti(BuildContext context) async {
    final cubit = _c(context);
    final items = cubit.pushItems();
    if (items == null) return;
    final go = await RtiReviewSheet.showPush(context, items);
    if (go == true && context.mounted) await _guarded(context, () => RtiNavigation.openNew(context, fromPlanning: items));
  }

  /// Create All RTI: the preview of the whole plan (phone full screen, tablet dialog).
  static Future<void> createAllRti(BuildContext context) async {
    final cubit = _c(context);
    final planId = cubit.createAllPlanId();
    if (planId == null) return;
    final outcome = await CreateAllRtiView.open(context, repo: cubit.repo, planningId: planId, drivers: cubit.state.drivers);
    if (outcome != null && !cubit.isClosed) {
      cubit.applyBatchResult(outcome.result, outcome.preview);
      cubit.notify(outcome.message);
      if (outcome.info != null) cubit.notify(outcome.info!, NoticeKind.info);
    }
  }

  /// The RTI badge: open that RTI.
  static Future<void> openRti(BuildContext context, PlanLine row) async {
    final id = _c(context).rtiOf(row);
    if (id != null) await _guarded(context, () => RtiNavigation.openEdit(context, id));
  }

  /// "Revise RTI" on a row (Q-REV-ROW): the RTI's own revise flow asks before changing anything.
  static Future<void> reviseRti(BuildContext context, PlanLine row) async {
    final id = _c(context).rtiOf(row, revise: true);
    if (id != null) await _guarded(context, () => RtiNavigation.openRevise(context, id));
  }

  /// A value copied to the clipboard ("Copied: {value}").
  static Future<void> copy(BuildContext context, String value) async {
    if (value.trim().isEmpty) return;
    final cubit = _c(context);
    await Clipboard.setData(ClipboardData(text: value));
    if (!cubit.isClosed) cubit.copied(value);
  }
}
