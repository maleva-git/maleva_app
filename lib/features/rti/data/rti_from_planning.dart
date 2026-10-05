import 'package:maleva/features/rti/models/planning_transfer_item.dart';

/// The RTI that "Create RTI" made from ticked planning rows.
class CreatedRti {
  const CreatedRti({required this.id, required this.rtiNo});

  final int id;
  final String rtiNo;
}

/// Create RTI refused the rows; [message] is the web's text, word for word.
class RtiCreateRefused implements Exception {
  const RtiCreateRefused(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One RTI from ticked planning rows, as the web's `createRTIFromPlanningRows`
/// (`R/services/planningDirectCreateService.ts:121-257`): the checks in the web's order
/// ([RtiCreateRefused]), the OUTSIDE DRIVER / NONE truck rules, RTI date today, then
/// `POST /api/rti-masters`. Implemented by the RTI feature; Planning calls it.
abstract interface class RtiFromPlanning {
  Future<CreatedRti> create(List<PlanningTransferItem> items);
}
