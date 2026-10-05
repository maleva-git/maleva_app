import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';

/// The web tests' `state()` (`R/services/rtiMoney.test.ts:27-34`).
RtiForm rtiState({
  String sleeping = 'NO',
  String exitYN = 'NO',
  String emptyDeliveryYN = 'NO',
  String manpw = 'NO',
  String pickup = 'NO',
  String pickupCount = '',
  String addDrop = 'NO',
  String dropCount = '',
  int editId = 0,
}) =>
    RtiForm(
      rtiNo: 'RTI000009542',
      rtiDate: '2026-10-02',
      driverRefId: '5',
      truckRefId: '72',
      sleeping: sleeping,
      exitYN: exitYN,
      emptyDeliveryYN: emptyDeliveryYN,
      manpw: manpw,
      pickup: pickup,
      pickupCount: pickupCount,
      addDrop: addDrop,
      dropCount: dropCount,
      editId: editId,
    );

/// The web tests' `job()`: a looked-up row with its job id.
RtiJobRow rtiJob(String salary, {String jobNo = 'TR002601394', int saleOrderId = 20498, int id = 0}) =>
    RtiJobRow(jobNo: jobNo, saleOrderMasterRefId: saleOrderId, salary: salary, id: id);
