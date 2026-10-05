import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';

/// Ticked planning rows as RTI items, as the web's `mapPlanningRowToTransferItem` and
/// `savePlanningRTITransfer` build them (`R/services/planningTransferService.ts:107-340`).
abstract final class PlanningTransfer {
  static String _norm(String v) => v.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  /// `mapPlanningRowToTransferItem`: null for a row with no sale order.
  static PlanningTransferItem? item(PlanLine row) {
    final saleOrder = Js.firstPositive([row.saleOrderMasterRefId, row.id]);
    if (saleOrder == 0) return null;
    return PlanningTransferItem(
      saleOrderMasterRefId: saleOrder,
      jobNo: Js.firstText([row.jobNo]),
      customerName: Js.firstText([row.customerName]),
      jobDate: Js.firstText([row.jobDate]),
      truckName: Js.firstText([row.truckName, row.truckNameD]),
      truckRefId: Js.firstPositive([row.truckRefid]),
      driverName: Js.firstText([row.driverName, row.driverNameD]),
      driverRefId: Js.firstPositive([row.driverRefid]),
      pickupDate: Js.firstText([row.pickupDateD, row.pickupDate, row.sPickupDate]),
      deliveryDate: Js.firstText([row.deliveryDateD, row.deliveryDate, row.sDeliveryDate]),
      origin: Js.firstText([row.origin, row.originD]),
      destination: Js.firstText([row.destination, row.destinationD]),
      pickupAddress: Js.firstText([row.pickupAddress]),
      deliveryAddress: Js.firstText([row.deliveryAddress]),
      pickupAddressTimelist: Js.firstText([row.pickuptimelist]),
      pickupAddressQuantity: Js.firstText([row.pickupQuantitylist]),
      deliveryAddressQuantity: Js.firstText([row.deliveryQuantitylist]),
      deliveryAddressDatelist: Js.firstText([row.delivertimelist]),
    );
  }

  /// The items with the driver looked up by name when the row has no id, the outside-driver
  /// flag (`resolvePlanningDriver`), and the truck looked up by name when it has no id.
  static List<PlanningTransferItem> items(List<PlanLine> rows, {List<DriverOption> drivers = const [], List<TruckOption> trucks = const []}) {
    int idByName(Iterable<(int, String)> list, String name) {
      final target = _norm(name);
      if (target.isEmpty) return 0;
      for (final e in list) {
        if (_norm(e.$2) == target && e.$1 > 0) return e.$1;
      }
      return 0;
    }

    String nameById(int id) => drivers.where((d) => d.id == id).map((d) => d.name.trim()).firstOrNull ?? '';
    final driverPairs = drivers.map((d) => (d.id, d.name));
    final truckPairs = trucks.map((t) => (t.id, t.name));

    final out = <PlanningTransferItem>[];
    for (final row in rows) {
      final it = item(row);
      if (it == null) continue;
      var driverRefId = it.driverRefId;
      if (driverRefId == 0 && it.driverName.isNotEmpty) driverRefId = idByName(driverPairs, it.driverName);
      final outside = driverRefId > 0 ? _norm(nameById(driverRefId)) == 'OUTSIDEDRIVER' : it.driverName.isNotEmpty;
      var truckRefId = it.truckRefId;
      if (truckRefId == 0 && it.truckName.isNotEmpty) truckRefId = idByName(truckPairs, it.truckName);
      out.add(PlanningTransferItem(
        saleOrderMasterRefId: it.saleOrderMasterRefId,
        jobNo: it.jobNo,
        customerName: it.customerName,
        jobDate: it.jobDate,
        truckName: it.truckName,
        truckRefId: truckRefId,
        driverName: it.driverName,
        driverRefId: driverRefId,
        isOutsideDriver: outside,
        pickupDate: it.pickupDate,
        deliveryDate: it.deliveryDate,
        origin: it.origin,
        destination: it.destination,
        pickupAddress: it.pickupAddress,
        deliveryAddress: it.deliveryAddress,
        pickupAddressTimelist: it.pickupAddressTimelist,
        pickupAddressQuantity: it.pickupAddressQuantity,
        deliveryAddressQuantity: it.deliveryAddressQuantity,
        deliveryAddressDatelist: it.deliveryAddressDatelist,
      ));
    }
    return out;
  }
}
