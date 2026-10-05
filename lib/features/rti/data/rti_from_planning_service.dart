import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/features/rti/data/rti_entry_repository.dart';
import 'package:maleva/features/rti/data/rti_from_planning.dart';
import 'package:maleva/features/rti/data/rti_mapper.dart';
import 'package:maleva/features/rti/data/rti_save_payload.dart';
import 'package:maleva/features/rti/models/js_values.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_rules.dart';

/// "Create RTI" from ticked planning rows, as the web's `createRTIFromPlanningRows`
/// (`R/services/planningDirectCreateService.ts:121-257`): its refusals word for word and in
/// its order, the OUTSIDE DRIVER and NONE placeholders found by name (fallback ids 22 and
/// 43, decision Q-IDS), RTI date today, then `POST /api/rti-masters` with the same payload
/// as the RTI form. A server refusal comes back as the server's `ApiFailure`.
class RtiFromPlanningService implements RtiFromPlanning {
  RtiFromPlanningService({
    required RtiEntryRepository repository,
    required DriverApi drivers,
    required TruckApi trucks,
    RtiForm Function()? initialForm,
  })  : _repository = repository,
        _drivers = drivers,
        _trucks = trucks,
        _initialForm = initialForm ?? RtiForm.initial;

  final RtiEntryRepository _repository;
  final DriverApi _drivers;
  final TruckApi _trucks;
  final RtiForm Function() _initialForm;

  static const outsideDriverName = 'OUTSIDEDRIVER';
  static const outsideDriverFallbackId = 22;
  static const noneTruckFallbackId = 43;

  static String normalizeName(String? v) => (v ?? '').replaceAll(RegExp(r'\s+'), '').toUpperCase();

  static String _entryName(Map<String, dynamic> r) =>
      Js.str(Js.field(r, ['name', 'driverName', 'truckName', 'EmployeeName']));

  static int findIdByName(List<Map<String, dynamic>> list, String normalizedTarget) {
    for (final r in list) {
      if (normalizeName(_entryName(r)) == normalizedTarget) {
        final id = Js.positiveInt([Js.field(r, ['id'])]);
        if (id != 0) return id;
      }
    }
    return 0;
  }

  static String findNameById(List<Map<String, dynamic>> list, int id) {
    if (id == 0) return '';
    for (final r in list) {
      if (Js.positiveInt([Js.field(r, ['id'])]) == id) return Js.text([_entryName(r)]);
    }
    return '';
  }

  Future<List<Map<String, dynamic>>> _safe(Future<List<Map<String, dynamic>>> Function() load) async {
    try {
      return await load();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<CreatedRti> create(List<PlanningTransferItem> items) async {
    if (items.isEmpty) throw const RtiCreateRefused('Please select orders to create RTI');
    final companyId = _repository.companyId;
    if (companyId == 0) throw const RtiCreateRefused('Company is required before creating RTI.');

    final valid = items.where((i) => i.saleOrderMasterRefId > 0).toList();
    if (valid.isEmpty) {
      throw const RtiCreateRefused('Selected rows are missing their sale order reference — save the planning first.');
    }
    if (valid.length != items.length) {
      throw const RtiCreateRefused('Some selected rows are missing their sale order reference — save the planning first.');
    }

    final truckKeys = {for (final i in items) '${i.truckRefId > 0 ? i.truckRefId : 0}|${normalizeName(i.truckName.trim())}'};
    final driverKeys = {for (final i in items) '${i.driverRefId > 0 ? i.driverRefId : 0}|${normalizeName(i.driverName.trim())}'};
    if (truckKeys.length > 1) {
      throw const RtiCreateRefused('Selected rows have different trucks — select rows for one truck only.');
    }
    if (driverKeys.length > 1) {
      throw const RtiCreateRefused('Selected rows have different drivers — select rows for one driver only.');
    }

    final drivers = await _safe(_drivers.allDetails);
    final trucks = await _safe(_trucks.allDetailCombo);

    final first = items.first;
    final truckName = first.truckName.trim();
    final driverName = first.driverName.trim();

    var driverId = first.driverRefId > 0 ? first.driverRefId : 0;
    if (driverId == 0 && driverName.isNotEmpty) driverId = findIdByName(drivers, normalizeName(driverName));

    final isOutside = driverId > 0 ? normalizeName(findNameById(drivers, driverId)) == outsideDriverName : driverName.isNotEmpty;

    int driverRefId;
    var outsideDriver = '';
    var outsideTruck = '';
    if (isOutside) {
      if (driverName.isEmpty) throw const RtiCreateRefused('Type the outside driver name in the planning row first.');
      driverRefId = driverId > 0 ? driverId : _or(findIdByName(drivers, outsideDriverName), outsideDriverFallbackId);
      outsideDriver = driverName;
      outsideTruck = driverName;
    } else if (driverId > 0) {
      driverRefId = driverId;
    } else {
      throw const RtiCreateRefused('Selected rows have no driver — assign or type a driver first.');
    }

    final truckNorm = normalizeName(truckName);
    final truckIsMarker = truckNorm == outsideDriverName || truckNorm == 'OUTSIDETRUCK';
    var truckId = first.truckRefId > 0 ? first.truckRefId : 0;
    if (truckId == 0 && truckName.isNotEmpty && !truckIsMarker) truckId = findIdByName(trucks, truckNorm);
    final hasRealTruck = truckId > 0 && !truckIsMarker;
    if (!hasRealTruck && !isOutside) {
      throw RtiCreateRefused(truckName.isNotEmpty
          ? 'Truck "$truckName" was not found in the truck master — assign a valid truck first.'
          : 'Selected rows have no truck — assign a truck first.');
    }
    final truckRefId = hasRealTruck ? truckId : _or(findIdByName(trucks, 'NONE'), noneTruckFallbackId);

    final form = _initialForm().copyWith(
      driverRefId: '$driverRefId',
      truckRefId: '$truckRefId',
      outsideDriver: outsideDriver,
      outsideTruck: outsideTruck,
    );
    final grid = [for (final i in valid) RtiMapper.fromPlanning(i)];
    final errors = RtiRules.validate(form, grid);
    if (errors.isNotEmpty) throw RtiCreateRefused(errors.join('\n'));

    final payload = RtiSavePayloadBuilder.build(form, grid, const [], companyId: companyId, employeeRefId: _repository.employeeId);
    final saved = await _repository.save(payload);
    return CreatedRti(id: saved.id, rtiNo: saved.rtiNo);
  }

  static int _or(int a, int b) => a != 0 ? a : b;
}
