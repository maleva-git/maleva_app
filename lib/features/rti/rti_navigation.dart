import 'package:flutter/material.dart';
import 'package:maleva/features/rti/list/view/rti_list_page.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';
import 'package:maleva/features/rti/view/rti_entry_page.dart';
import 'package:maleva/features/rti_assignments/view/assignments_page.dart';

/// How other features open the RTI screens.
abstract final class RtiNavigation {
  /// The RTI list (RTI View). With [replace] the current page gives way to it, like the web's
  /// View (F5) on the RTI page.
  static Future<void> openList(BuildContext context, {bool replace = false}) => replace
      ? Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const RtiListPage()))
      : _push(context, const RtiListPage());

  /// A new RTI; with [fromPlanning] it opens pre-filled like the web's Push RTI
  /// (`?planning=1`): truck and driver from the first item, one job row per item.
  static Future<void> openNew(BuildContext context, {List<PlanningTransferItem> fromPlanning = const []}) =>
      _push(context, RtiEntryPage(fromPlanning: fromPlanning));

  /// A saved RTI in edit mode.
  static Future<void> openEdit(BuildContext context, int rtiId) => _push(context, RtiEntryPage(rtiId: rtiId));

  /// A saved RTI straight into the revise flow (decision Q-REV = B).
  static Future<void> openRevise(BuildContext context, int rtiId) => _push(context, RtiEntryPage(rtiId: rtiId, revise: true));

  /// Employee Assignments.
  static Future<void> openAssignments(BuildContext context) => _push(context, const AssignmentsPage());

  static Future<void> _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
