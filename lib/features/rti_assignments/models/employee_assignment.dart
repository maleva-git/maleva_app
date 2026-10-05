import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';

/// One job on an RTI as Employee Assignments lists it: the Java `RtiEmployeeAssignmentResponse`
/// (`R/api/employeeAssignmentsApi.ts:11-36`), field names as they come.
class EmployeeAssignment extends Equatable {
  const EmployeeAssignment({
    required this.id,
    this.rtiMasterRefId = 0,
    this.saleOrderMasterRefId = 0,
    this.pickupDateD = '',
    this.deliveryDateD = '',
    this.originD = '',
    this.destinationD = '',
    this.rtiNumber = '',
    this.remarks = '',
    this.pickupCount = 0,
    this.dropCount = 0,
    this.saleOrderNumber = '',
    this.vesselNameRaw = '',
    this.customerName = '',
    this.commodity = '',
    this.quantity = '',
    this.truckSize = '',
    this.employeeName = '',
    this.driverName = '',
    this.truckNumber = '',
    this.truckType = '',
  });

  factory EmployeeAssignment.fromJava(Map<String, dynamic> j) {
    String s(String k) => JsonRead.string(j[k]).trim();
    return EmployeeAssignment(
      id: JsonRead.integer(j['id']),
      rtiMasterRefId: JsonRead.integer(j['rtiMasterRefId']),
      saleOrderMasterRefId: JsonRead.integer(j['saleOrderMasterRefId']),
      pickupDateD: s('pickupDateD'),
      deliveryDateD: s('deliveryDateD'),
      originD: s('originD'),
      destinationD: s('destinationD'),
      rtiNumber: s('rtiNumber'),
      remarks: s('remarks'),
      pickupCount: JsonRead.integer(j['pickupCount']),
      dropCount: JsonRead.integer(j['dropCount']),
      saleOrderNumber: s('saleOrderNumber'),
      vesselNameRaw: s('vesselNameRaw'),
      customerName: s('customerName'),
      commodity: s('commodity'),
      quantity: s('quantity'),
      truckSize: s('truckSize'),
      employeeName: s('employeeName'),
      driverName: s('driverName'),
      truckNumber: s('truckNumber'),
      truckType: s('truckType'),
    );
  }

  final int id;
  final int rtiMasterRefId;
  final int saleOrderMasterRefId;
  final String pickupDateD;
  final String deliveryDateD;
  final String originD;
  final String destinationD;
  final String rtiNumber;
  final String remarks;
  final int pickupCount;
  final int dropCount;
  final String saleOrderNumber;
  final String vesselNameRaw;
  final String customerName;
  final String commodity;
  final String quantity;
  final String truckSize;
  final String employeeName;
  final String driverName;
  final String truckNumber;
  final String truckType;

  /// React's `formatDateTime`: "05 Oct 2026, 08:30 AM"; '-' when empty or "N/A"; the text as it
  /// is when it is not a date.
  static String formatDateTime(String raw) {
    if (raw.isEmpty || raw == 'N/A') return '-';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('dd MMM yyyy, hh:mm a', 'en_US').format(d);
  }

  /// `value || '-'`.
  static String orDash(String v) => v.isEmpty ? '-' : v;

  @override
  List<Object?> get props => [
        id, rtiMasterRefId, saleOrderMasterRefId, pickupDateD, deliveryDateD, originD, destinationD, rtiNumber, remarks,
        pickupCount, dropCount, saleOrderNumber, vesselNameRaw, customerName, commodity, quantity, truckSize,
        employeeName, driverName, truckNumber, truckType,
      ];
}
