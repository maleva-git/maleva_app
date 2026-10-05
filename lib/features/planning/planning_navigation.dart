import 'package:flutter/material.dart';
import 'package:maleva/features/planning/plans/view/plans_page.dart';
import 'package:maleva/features/planning/view/plan_page.dart';

/// How other features open the Planning screens.
abstract final class PlanningNavigation {
  /// The saved plans list (Planning View).
  static Future<void> openPlans(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PlansPage()));

  /// The plan screen: a saved plan by [id], or a new plan.
  static Future<void> openPlan(BuildContext context, {int? id}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PlanPage(planId: id)));
}
