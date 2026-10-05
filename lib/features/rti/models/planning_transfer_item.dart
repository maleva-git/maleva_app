/// A planning row handed to the RTI screens, as the web's `mapPlanningRowToTransferItem`
/// builds it (`maleva-front-end/src/features/rti/services/planningTransferService.ts:151-261`).
/// Used by Push RTI (opens the RTI form with these jobs) and Create RTI (saves one RTI now).
class PlanningTransferItem {
  const PlanningTransferItem({
    required this.saleOrderMasterRefId,
    this.jobNo = '',
    this.customerName = '',
    this.jobDate = '',
    this.truckName = '',
    this.truckRefId = 0,
    this.driverName = '',
    this.driverRefId = 0,
    this.isOutsideDriver = false,
    this.pickupDate = '',
    this.deliveryDate = '',
    this.origin = '',
    this.destination = '',
    this.pickupAddress = '',
    this.deliveryAddress = '',
    this.pickupAddressTimelist = '',
    this.pickupAddressQuantity = '',
    this.deliveryAddressQuantity = '',
    this.deliveryAddressDatelist = '',
  });

  final int saleOrderMasterRefId;
  final String jobNo;
  final String customerName;
  final String jobDate;
  final String truckName;
  final int truckRefId;
  final String driverName;
  final int driverRefId;

  /// The row's truck is the OUTSIDE DRIVER placeholder; [driverName] is the typed name.
  final bool isOutsideDriver;
  final String pickupDate;
  final String deliveryDate;
  final String origin;
  final String destination;
  final String pickupAddress;
  final String deliveryAddress;
  final String pickupAddressTimelist;
  final String pickupAddressQuantity;
  final String deliveryAddressQuantity;
  final String deliveryAddressDatelist;
}
