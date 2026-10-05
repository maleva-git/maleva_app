import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/features/rti/models/js_values.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';
import 'package:maleva/features/rti/models/rti_dates.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';

/// Reads the Java RTI answers into the form, as `R/services/rtiService.ts:123-357` does.
abstract final class RtiMapper {
  /// `extractSaleOrderMaster`: the `saleOrderMaster` of a sale-order answer (or the answer itself).
  static Map<String, dynamic> saleOrderMaster(Map<String, dynamic> raw) {
    final m = Js.field(raw, ['saleOrderMaster', 'Master']);
    return m is Map ? JsonRead.map(m) : raw;
  }

  /// `mapSaleOrderToGridRow`: a sale order as a new job line (salary 0).
  static RtiJobRow fromSaleOrder(Map<String, dynamic> so) => RtiJobRow(
        jobNo: Js.fieldText(so, ['cNumberDisplay']),
        customerName: Js.fieldText(so, ['customerName']),
        jobDate: Js.fieldText(so, ['saleDate']),
        originD: Js.fieldText(so, ['origin']),
        destinationD: Js.fieldText(so, ['destination']),
        pickupDateD: Js.fieldText(so, ['pickupDate']),
        deliveryDateD: Js.fieldText(so, ['deliveryDate']),
        pickupAddressD: Js.fieldText(so, ['pickupAddress']),
        deliveryAddressD: Js.fieldText(so, ['deliveryAddress']),
        pickupAddressTimelistD: Js.fieldText(so, ['pickuptimelist', 'PickupAddressTimelist']),
        pickupAddressQuantityD: Js.fieldText(so, ['pickupQuantitylist', 'PickupAddressQuantity']),
        deliveryAddressQuantityD: Js.fieldText(so, ['deliveryQuantitylist', 'DeliveryAddressQuantity']),
        deliveryAddressdatelistD: Js.fieldText(so, ['delivertimelist', 'DeliveryTimeList', 'DeliveryAddressdatelist']),
        saleOrderMasterRefId: Js.fieldNumber(so, ['id']).toInt(),
        editMode: 1,
      );

  /// `mapJobLookupToGridRow`: a search match before its sale order is read.
  static RtiJobRow fromLookup(({int id, String jobNo, String jobDate, String customerName}) m) =>
      RtiJobRow(jobNo: m.jobNo, customerName: m.customerName, jobDate: m.jobDate, saleOrderMasterRefId: m.id, editMode: 1);

  /// `mergeDetailWithSaleOrder`: a saved line, with its sale order's job no., customer and
  /// date first, and the line's own route values first.
  static RtiJobRow fromDetail(Map<String, dynamic> d, [Map<String, dynamic>? so]) {
    String t(List<dynamic> v) => Js.text(v);
    dynamic s(String k) => so == null ? null : JsonRead.field(so, k);
    dynamic f(String k) => JsonRead.field(d, k);
    return RtiJobRow(
      jobNo: t([s('cNumberDisplay'), f('jobNo')]),
      customerName: t([s('customerName'), f('customerName')]),
      jobDate: t([s('saleDate'), f('jobDate')]),
      salary: Js.str(Js.number([f('salary')])),
      ppic: t([f('ppic')]),
      dpic: t([f('dpic')]),
      pwdType: Js.str(Js.number([f('pwdType')])),
      originD: t([f('originD'), s('origin')]),
      destinationD: t([f('destinationD'), s('destination')]),
      pickupDateD: t([f('pickupDateD'), s('pickupDate')]),
      deliveryDateD: t([f('deliveryDateD'), s('deliveryDate')]),
      pickupAddressD: t([f('pickupAddressD'), s('pickupAddress')]),
      deliveryAddressD: t([f('deliveryAddressD'), s('deliveryAddress')]),
      pickupAddressTimelistD: t([f('pickupAddressTimelistD'), s('pickuptimelist'), s('PickupAddressTimelist')]),
      pickupAddressQuantityD: t([f('pickupAddressQuantityD'), s('pickupQuantitylist'), s('PickupAddressQuantity')]),
      deliveryAddressQuantityD: t([f('deliveryAddressQuantityD'), s('deliveryQuantitylist'), s('DeliveryAddressQuantity')]),
      deliveryAddressdatelistD: t([f('deliveryAddressdatelistD'), s('delivertimelist'), s('DeliveryAddressdatelist')]),
      id: Js.number([f('id')]).toInt(),
      saleOrderMasterRefId: Js.number([f('saleOrderMasterRefId'), s('id')]).toInt(),
      rtiMasterRefId: Js.number([f('rtiMasterRefId')]).toInt(),
      editMode: 1,
    );
  }

  static String _flag(dynamic v) => Js.boolean(v) ? 'YES' : 'NO';

  static String _exit(dynamic v) {
    final n = Js.number([v]);
    return n == 1 ? 'EMPTY 80' : (n == 2 ? 'EMPTY 50' : 'NO');
  }

  static String _manpower(dynamic v) {
    final n = Js.number([v]);
    return n == 1 ? '1' : (n == 2 ? '2' : 'NO');
  }

  /// `mapMasterToFormState`.
  static RtiForm form(Map<String, dynamic> m) {
    dynamic f(String k) => JsonRead.field(m, k);
    final date = RtiDates.dateInput(f('saleDate'));
    final id = Js.number([f('id')]).toInt();
    return RtiForm(
      rtiNo: Js.text([f('CNumberDisplay')]),
      rtiDate: date.isEmpty ? RtiDates.today() : date,
      driverRefId: Js.text([f('driverRefId'), f('driverRefid')]),
      truckRefId: Js.text([f('truckRefId'), f('truckRefid')]),
      eLink: Js.text([f('eLink')]),
      exLink: Js.text([f('exLink')]),
      sleeping: _flag(f('sleeping')),
      exitYN: _exit(f('exitYN')),
      emptyDeliveryYN: _exit(f('emptyDeliveryYN')),
      pickup: _flag(f('pickup')),
      addDrop: _flag(f('addDrop')),
      manpw: _manpower(f('manpw')),
      pickupCount: Js.text([f('pickupCount')]),
      dropCount: Js.text([f('dropCount')]),
      destination: Js.text([f('destination')]),
      sealBy: Js.text([f('sealBy')]),
      breakSealBy: Js.text([f('breakSealBy')]),
      remarks: Js.text([f('remarks')]),
      comments: Js.text([f('comments')]),
      outsideDriver: Js.text([f('outsideDriver')]),
      outsideTruck: Js.text([f('outsideTruck')]),
      punctuality: Js.boolean(f('punctuality')),
      documentSub: Js.boolean(f('documentSub')),
      pckHandling: Js.boolean(f('pckHandling')),
      editId: id,
    );
  }

  /// `mapRouteActivityRecord`: `SEAL,BREAK_SEAL` → `SEAL_AND_BREAK`.
  static RtiStop stop(Map<String, dynamic> a) {
    dynamic f(String k) => JsonRead.field(a, k);
    final type = Js.str(f('activityType'));
    final set = type.split(',').toSet();
    final seal = set.contains('SEAL');
    final breakSeal = set.contains('BREAK_SEAL');
    var jobType = type;
    if (seal && breakSeal) {
      jobType = 'SEAL_AND_BREAK';
    } else if (seal && set.length == 1) {
      jobType = 'SEAL';
    } else if (breakSeal && set.length == 1) {
      jobType = 'BREAK_SEAL';
    }
    final id = Js.number([f('id')]).toInt();
    final marqis = Js.number([f('marqisStatus')]).toInt();
    String? orNull(dynamic v) => Js.str(v).isEmpty ? null : Js.str(v);
    return RtiStop(
      id: id == 0 ? null : id,
      sequenceNo: Js.number([f('sequenceNo')]).toInt(),
      locationName: Js.str(f('locationName')),
      employeeRefId: f('employeeRefId') == null ? null : Js.number([f('employeeRefId')]).toInt(),
      agentName: Js.str(f('agentName')),
      agentMobileNo: Js.str(f('agentMobileNo')),
      jobType: jobType,
      remarks: Js.str(f('remarks')),
      fullRoute: Js.str(f('fullRoute')),
      driverNumber: Js.str(f('driverNumber')),
      marqisStatus: marqis == 0 ? null : marqis,
      status: Js.number([f('status')]).toInt(),
      plannedDateTime: orNull(f('plannedDateTime')),
      eta: orNull(f('eta')),
      createdDate: orNull(f('createdDate')),
    );
  }

  /// `buildRTIGridRowFromTransferItem`: one planning job as a job line.
  static RtiJobRow fromPlanning(PlanningTransferItem i) => RtiJobRow(
        jobNo: i.jobNo,
        customerName: i.customerName,
        jobDate: i.jobDate,
        originD: i.origin,
        destinationD: i.destination,
        pickupDateD: i.pickupDate,
        deliveryDateD: i.deliveryDate,
        pickupAddressD: i.pickupAddress,
        deliveryAddressD: i.deliveryAddress,
        pickupAddressTimelistD: i.pickupAddressTimelist,
        pickupAddressQuantityD: i.pickupAddressQuantity,
        deliveryAddressQuantityD: i.deliveryAddressQuantity,
        deliveryAddressdatelistD: i.deliveryAddressDatelist,
        saleOrderMasterRefId: i.saleOrderMasterRefId,
      );

  /// `buildRTIStateFromPlanningTransfer` (`R/services/planningTransferService.ts:410-444`):
  /// truck and driver from the first item; an outside driver's typed name goes into Outside
  /// Driver and Outside Truck.
  static RtiForm planningForm(List<PlanningTransferItem> items) {
    final first = items.isEmpty ? null : items.first;
    final driverId = first?.driverRefId ?? 0;
    final outside = first != null && (first.isOutsideDriver || (driverId == 0 && first.driverName.isNotEmpty));
    final typed = outside ? first.driverName : '';
    return RtiForm.initial().copyWith(
      truckRefId: (first?.truckRefId ?? 0) > 0 ? '${first!.truckRefId}' : '',
      driverRefId: driverId > 0 ? '$driverId' : '',
      outsideDriver: typed,
      outsideTruck: typed,
    );
  }
}
