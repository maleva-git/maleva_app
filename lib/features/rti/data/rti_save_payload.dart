import 'package:maleva/features/rti/models/js_values.dart';
import 'package:maleva/features/rti/models/rti_dates.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_rules.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';

/// What the RTI save sends: the master (37 keys, plus `id` on an edit), the job lines
/// (15 keys, plus `rtiMasterRefId` on an edit and `id` for a saved line) and the stops.
class RtiSavePayload {
  const RtiSavePayload({required this.master, required this.details, required this.routeActivities});

  final Map<String, dynamic> master;
  final List<Map<String, dynamic>> details;
  final List<Map<String, dynamic>> routeActivities;
}

/// `RTIService.prepareSaveData` (`R/services/rtiService.ts:565-704`), key for key and in the
/// same order. Rows without a sale order are left out (the validation refuses them first).
abstract final class RtiSavePayloadBuilder {
  static int _yesNo(String v) => v == 'YES' ? 1 : 0;
  static int _exit(String v) => v == 'EMPTY 80' ? 1 : (v == 'EMPTY 50' ? 2 : 0);
  static int _manpower(String v) => v == '1' ? 1 : (v == '2' ? 2 : 0);
  static int _exitAmount(String v) => v == 'NO' ? 0 : (v == 'EMPTY 80' ? 80 : 50);

  static RtiSavePayload build(RtiForm s, List<RtiJobRow> grid, List<RtiStop> stops,
      {required int companyId, required int employeeRefId}) {
    final total = RtiRules.total(s, grid);
    final actor = employeeRefId != 0 ? '$employeeRefId' : 'system';
    final sequenceNo = Js.number([s.rtiNo.replaceAll(RegExp(r'\D'), '')]);
    final isEdit = s.editId > 0;
    final pickupCount = Js.number([s.pickupCount]);
    final dropCount = Js.number([s.dropCount]);

    final master = <String, dynamic>{
      'companyRefId': companyId,
      'employeeRefId': employeeRefId != 0 ? employeeRefId : null,
      'saleDate': RtiDates.apiDateTime(s.rtiDate),
      'CNumberDisplay': Js.text([s.rtiNo]),
      'CNumber': sequenceNo != 0 ? sequenceNo : 0,
      'remarks': s.remarks,
      'eLink': s.eLink,
      'exLink': s.exLink,
      'active': 1,
      'sleeping': _yesNo(s.sleeping),
      'sleepingAmount': s.sleeping == 'YES' ? 50 : 0,
      'amount': total,
      'truckRefId': Js.number([s.truckRefId]),
      'driverRefId': Js.number([s.driverRefId]),
      'pickup': _yesNo(s.pickup),
      'pickupCount': pickupCount,
      'pickupAmount': s.pickup == 'YES' ? pickupCount * 30 : 0,
      'dropCount': dropCount,
      'dropAmount': s.addDrop == 'YES' ? dropCount * 30 : 0,
      'addDrop': _yesNo(s.addDrop),
      'exitYN': _exit(s.exitYN),
      'exitAmount': _exitAmount(s.exitYN),
      'destination': s.destination,
      'sealBy': s.sealBy,
      'breakSealBy': s.breakSealBy,
      'emptyDeliveryYN': _exit(s.emptyDeliveryYN),
      'emptyDeliveryAmount': _exitAmount(s.emptyDeliveryYN),
      'comments': s.comments,
      'outsideDriver': s.outsideDriver,
      'outsideTruck': s.outsideTruck,
      'manpw': _manpower(s.manpw),
      'manpwAmount': s.manpw == '1' ? 50 : (s.manpw == '2' ? 100 : 0),
      'pckHandling': s.pckHandling ? 1 : 0,
      'punctuality': s.punctuality ? 1 : 0,
      'documentSub': s.documentSub ? 1 : 0,
      'createdBy': actor,
      'modifiedBy': actor,
    };
    if (isEdit) master['id'] = s.editId;

    final details = [
      for (final row in grid)
        if (row.saleOrderMasterRefId > 0)
          {
            'saleOrderMasterRefId': row.saleOrderMasterRefId,
            'salary': row.salaryValue,
            'ppic': row.ppic,
            'dpic': row.dpic,
            'pwdType': Js.number([row.pwdType]),
            'pickupDateD': RtiDates.apiDateTime(row.pickupDateD),
            'deliveryDateD': RtiDates.apiDateTime(row.deliveryDateD),
            'originD': row.originD,
            'destinationD': row.destinationD,
            'pickupAddressD': row.pickupAddressD,
            'deliveryAddressD': row.deliveryAddressD,
            'pickupAddressTimelistD': row.pickupAddressTimelistD,
            'pickupAddressQuantityD': row.pickupAddressQuantityD,
            'deliveryAddressQuantityD': row.deliveryAddressQuantityD,
            'deliveryAddressdatelistD': row.deliveryAddressdatelistD,
            if (isEdit) 'rtiMasterRefId': s.editId,
            if (row.id > 0) 'id': row.id,
          },
    ];

    final rtiDay = RtiDates.apiDateTime(s.rtiDate);
    final routeActivities = [
      for (final row in stops) _stop(row, s, companyId: companyId, isEdit: isEdit, rtiDay: rtiDay),
    ];

    return RtiSavePayload(master: master, details: details, routeActivities: routeActivities);
  }

  static Map<String, dynamic> _stop(RtiStop row, RtiForm s, {required int companyId, required bool isEdit, String? rtiDay}) {
    final activities = <String>[
      if (row.jobType == 'SEAL_AND_BREAK') ...['SEAL', 'BREAK_SEAL'] else if (row.jobType.isNotEmpty) row.jobType,
    ];
    var eta = (row.eta ?? '').isNotEmpty ? row.eta : rtiDay;
    if (eta != null && eta.length == 16) eta = '$eta:00';
    return {
      if (row.id != null) 'id': row.id,
      'companyRefId': companyId,
      if (isEdit) 'rtiMasterRefId': s.editId,
      'sequenceNo': row.sequenceNo,
      'locationName': row.locationName,
      'activityType': activities.join(','),
      'employeeRefId': row.employeeRefId,
      'agentName': (row.agentName ?? '').isEmpty ? null : row.agentName,
      'agentMobileNo': row.agentMobileNo,
      'status': row.status,
      'plannedDateTime': (row.plannedDateTime ?? '').isNotEmpty ? row.plannedDateTime : rtiDay,
      'eta': eta,
      'completedDateTime': (row.completedDateTime ?? '').isNotEmpty ? row.completedDateTime : null,
      'remarks': row.remarks,
      'fullRoute': row.fullRoute,
      'driverNumber': row.driverNumber,
      'marqisStatus': (row.marqisStatus ?? 0) == 0 ? null : row.marqisStatus,
      'active': true,
    };
  }

  /// `rtiApi.save`'s request (`R/api/rtiApi.ts:310-378`): a new RTI sends no number
  /// (the server assigns it) and no ids that are not positive; an edit sends the number in
  /// both spellings and the RTI id on each line and stop.
  static Map<String, dynamic> request(RtiSavePayload p) {
    final masterId = Js.number([p.master['id']]).toInt();
    final isCreate = masterId == 0;
    Map<String, dynamic> positiveId(Map<String, dynamic> r) {
      final out = Map<String, dynamic>.from(r);
      if (Js.number([out['id']]) <= 0) out.remove('id');
      return out;
    }

    final master = positiveId(p.master);
    if (isCreate) {
      master
        ..remove('CNumber')
        ..remove('cNumber')
        ..remove('CNumberDisplay')
        ..remove('cNumberDisplay');
    } else {
      master['cNumber'] = master['CNumber'];
      master['cNumberDisplay'] = master['CNumberDisplay'];
    }
    Map<String, dynamic> line(Map<String, dynamic> r) {
      final out = positiveId(r)..remove('rtiMasterRefId');
      if (!isCreate) out['rtiMasterRefId'] = masterId;
      return out;
    }

    master['rtiDetails'] = [for (final d in p.details) line(d)];
    master['routeActivities'] = [for (final a in p.routeActivities) line(a)];
    return master;
  }
}
