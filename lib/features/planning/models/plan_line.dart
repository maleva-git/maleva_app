import 'package:maleva/features/planning/data/js_values.dart';

/// One planning row, with the web grid's field names. Read from the Java PascalCase answer
/// exactly like `planningSearch.ts` `mapPlanningSearchItem` ([PlanLine.fromSearch]) and
/// `planningEditMapper.ts` `normalizePlanningDetailItem` ([PlanLine.fromEdit]).
class PlanLine {
  PlanLine({
    int? uid,
    this.id = 0,
    this.sdId = 0,
    this.planingMasterRefId = 0,
    this.saleOrderMasterRefId = 0,
    this.sortByD = '',
    this.originalSortByD = '',
    this.remarks = '',
    this.truckName = '',
    this.truckRefid = 0,
    this.truckNameD = '',
    this.driverName = '',
    this.driverRefid = 0,
    this.driverNameD = '',
    this.sPickupDate = '',
    this.sDeliveryDate = '',
    this.origin = '',
    this.destination = '',
    this.originD = '',
    this.destinationD = '',
    this.customerName = '',
    this.packageType = '',
    this.vesselName = '',
    this.jobNo = '',
    this.picName = '',
    this.loadingETA = '',
    this.offloadingETA = '',
    this.status = '',
    this.jobStatus = '',
    this.rtiNo = '',
    this.rtiMasterRefId = 0,
    this.jobDate = '',
    this.jobName = '',
    this.awbNo = '',
    this.blCopy = '',
    this.truckSize = '',
    this.pickupDate = '',
    this.deliveryDate = '',
    this.pickupDateD = '',
    this.deliveryDateD = '',
    this.sPort = '',
    this.oPort = '',
    this.pickuptimelist = '',
    this.pickupQuantitylist = '',
    this.deliveryQuantitylist = '',
    this.delivertimelist = '',
    this.wareHouseEnterDate = '',
    this.wareHouseExitDate = '',
    this.wareHouseAddress = '',
    this.pickupAddress = '',
    this.deliveryAddress = '',
    this.pickupsList,
    this.deliveriesList,
    this.print = false,
  }) : uid = uid ?? ++_lastUid;

  static int _lastUid = 0;

  /// A new local identity (a clone is a new row on screen).
  static int nextUid() => ++_lastUid;

  /// `mapPlanningSearchItem` (`planningSearch.ts:53-136`).
  factory PlanLine.fromSearch(Map<String, dynamic> item) {
    String s(List<String> keys) => Js.text(Js.or(item, keys));
    final truckRef = Js.or(item, ['TruckRefid', 'TruckRefId']);
    return PlanLine(
      sortByD: '',
      originalSortByD: s(['SortByD', 'sortByD', 'SortBy', 'sortBy']),
      remarks: s(['Remarks']),
      truckName: !Js.truthy(truckRef) ? '' : s(['TruckName']),
      sPickupDate: searchDate(Js.or(item, ['SPickupDate', 'PickupDate'])),
      sDeliveryDate: searchDate(Js.or(item, ['SDeliveryDate', 'DeliveryDate'])),
      origin: s(['Origin']),
      destination: s(['Destination']),
      customerName: s(['CustomerName']),
      packageType: s(['pkg']),
      vesselName: s(['VesselName']),
      jobNo: s(['JobNo']),
      picName: s(['EmployeeName']),
      loadingETA: s(['LETA']),
      offloadingETA: s(['OETA']),
      status: Js.truthy(item['JobStatus']) ? Js.text(item['JobStatus']) : 'Pending',
      rtiNo: s(['RTINo']),
      id: Js.intOr0(item['Id']),
      sdId: Js.intOr0(Js.or(item, ['SDId'])),
      planingMasterRefId: Js.intOr0(Js.or(item, ['PLANINGMasterRefId'])),
      saleOrderMasterRefId: Js.intOr0(Js.or(item, ['SaleOrderMasterRefId', 'Id'])),
      truckRefid: Js.intOr0(truckRef),
      driverRefid: Js.intOr0(Js.or(item, ['DriverRefid', 'DriverRefId', 'driverRefid', 'driverRefId'])),
      driverName: s(['DriverName']),
      jobDate: s(['JobDate']),
      jobStatus: s(['JobStatus']),
      jobName: s(['JobName']),
      awbNo: s(['AWBNo']),
      blCopy: s(['BLCopy']),
      originD: s(['OriginD', 'Origin']),
      destinationD: s(['DestinationD', 'Destination']),
      truckSize: s(['truckSize']),
      pickupDate: s(['PickupDate']),
      deliveryDate: s(['DeliveryDate']),
      pickupDateD: s(['PickupDateD']),
      deliveryDateD: s(['DeliveryDateD']),
      sPort: s(['SPort']),
      oPort: s(['OPort']),
      truckNameD: s(['TruckNameD', 'TruckName']),
      driverNameD: s(['DriverNameD', 'DriverName']),
      pickuptimelist: s(['pickuptimelist', 'PickupTimeList']),
      pickupQuantitylist: s(['pickupQuantitylist', 'PickupQuantityList']),
      deliveryQuantitylist: s(['DeliveryQuantitylist', 'DeliveryQuantityList']),
      delivertimelist: s(['Delivertimelist', 'DeliveryTimeList']),
      wareHouseEnterDate: s(['WareHouseEnterDate']),
      wareHouseExitDate: s(['WareHouseExitDate']),
      wareHouseAddress: s(['WareHouseAddress']),
      pickupAddress: s(['PickupAddress']),
      deliveryAddress: s(['DeliveryAddress']),
    );
  }

  /// `normalizePlanningDetailItem` (`planningEditMapper.ts:37-140`).
  factory PlanLine.fromEdit(Map<String, dynamic> item, int index) {
    String s(List<String> keys) => Js.text(Js.nn(item, keys));
    final truckRefRaw = Js.nn(item, ['TruckRefid', 'truckRefid', 'TruckRefId', 'truckRefId']) ?? 0;
    final noTruck = truckRefRaw is num && truckRefRaw == 0;
    final truckLabel = s(['TruckNameD', 'truckNameD', 'TruckName', 'truckName']);
    List<Map<String, dynamic>> list(List<String> keys) {
      final v = Js.nn(item, keys);
      return v is List
          ? [
              for (final e in v)
                if (e is Map) Map<String, dynamic>.from(e)
            ]
          : const [];
    }

    return PlanLine(
      sortByD: '',
      originalSortByD: s(['SortByD', 'sortByD', 'SortBy', 'sortBy']),
      remarks: s(['Remarks', 'remarks']),
      truckName: noTruck ? '' : truckLabel,
      sPickupDate: s(['SPickupDate', 'sPickupDate', 'PickupDateD', 'pickupDateD', 'PickupDate', 'pickupDate']),
      sDeliveryDate: s(['SDeliveryDate', 'sDeliveryDate', 'DeliveryDateD', 'deliveryDateD', 'DeliveryDate', 'deliveryDate']),
      origin: s(['Origin', 'origin', 'OriginD', 'originD']),
      destination: s(['Destination', 'destination', 'DestinationD', 'destinationD']),
      customerName: s(['CustomerName', 'customerName']),
      packageType: s(['pkg', 'packageType']),
      vesselName: s(['VesselName', 'vesselName']),
      jobNo: s(['JobNo', 'jobNo']),
      picName: s(['EmployeeName', 'employeeName', 'picName']),
      loadingETA: s(['LETA', 'loadingETA']),
      offloadingETA: s(['OETA', 'offloadingETA']),
      status: s(['JobStatus', 'jobStatus', 'status']),
      rtiNo: s(['RTINo', 'rtiNo']),
      id: Js.intOr0(Js.nn(item, ['Id', 'id']) ?? index + 1),
      sdId: Js.intOr0(Js.nn(item, ['SDId', 'sdId', 'sdid'])),
      planingMasterRefId: Js.intOr0(Js.nn(item, ['PLANINGMasterRefId', 'planningMasterRefId'])),
      saleOrderMasterRefId: Js.intOr0(Js.nn(item, ['SaleOrderMasterRefId', 'saleOrderMasterRefId'])),
      truckRefid: Js.intOr0(truckRefRaw),
      driverRefid: Js.intOr0(Js.nn(item, ['DriverRefid', 'driverRefid', 'DriverRefId', 'driverRefId'])),
      driverName: s(['DriverName', 'driverName']),
      jobDate: s(['JobDate']),
      jobStatus: s(['JobStatus', 'jobStatus']),
      jobName: s(['JobName']),
      awbNo: s(['AWBNo']),
      blCopy: s(['BLCopy']),
      originD: s(['OriginD', 'originD', 'Origin', 'origin']),
      destinationD: s(['DestinationD', 'destinationD', 'Destination', 'destination']),
      truckSize: s(['truckSize']),
      pickupDate: s(['PickupDate', 'pickupDate', 'PickupDateD', 'pickupDateD']),
      deliveryDate: s(['DeliveryDate', 'deliveryDate', 'DeliveryDateD', 'deliveryDateD']),
      pickupDateD: s(['PickupDateD', 'pickupDateD', 'PickupDate', 'pickupDate']),
      deliveryDateD: s(['DeliveryDateD', 'deliveryDateD', 'DeliveryDate', 'deliveryDate']),
      sPort: s(['SPort']),
      oPort: s(['OPort']),
      truckNameD: noTruck ? '' : truckLabel,
      driverNameD: s(['DriverNameD', 'driverNameD']),
      pickuptimelist: s(['pickuptimelist', 'pickupTimeList', 'PickupTimeList']),
      pickupQuantitylist: s(['pickupQuantitylist', 'pickupQuantityList', 'PickupQuantityList']),
      deliveryQuantitylist: s(['DeliveryQuantitylist', 'deliveryQuantitylist', 'deliveryQuantityList', 'DeliveryQuantityList']),
      delivertimelist: s(['Delivertimelist', 'delivertimelist', 'deliveryTimeList', 'DeliveryTimeList']),
      wareHouseEnterDate: s(['WareHouseEnterDate', 'wareHouseEnterDate']),
      wareHouseExitDate: s(['WareHouseExitDate', 'wareHouseExitDate']),
      wareHouseAddress: s(['WareHouseAddress', 'wareHouseAddress']),
      pickupAddress: s(['PickupAddress', 'pickupAddress']),
      deliveryAddress: s(['DeliveryAddress', 'deliveryAddress']),
      pickupsList: list(['PickupsList', 'pickupsList']),
      deliveriesList: list(['DeliveriesList', 'deliveriesList']),
    );
  }

  /// The search's `formatDate`: a `yyyy-MM-dd[T ]HH:mm...` value keeps its first 19 characters
  /// with a space; another parseable date is written `yyyy-MM-dd HH:mm:ss`; anything else as it is.
  static String searchDate(dynamic raw) {
    if (!Js.truthy(raw)) return '';
    final text = Js.text(raw);
    if (RegExp(r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}').hasMatch(text)) {
      final spaced = text.replaceFirst('T', ' ');
      return spaced.length > 19 ? spaced.substring(0, 19) : spaced;
    }
    final d = DateTime.tryParse(text);
    if (d == null) return text;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  final int uid;
  final int id;
  final int sdId;
  final int planingMasterRefId;
  final int saleOrderMasterRefId;
  final String sortByD;
  final String originalSortByD;
  final String remarks;
  final String truckName;
  final int truckRefid;
  final String truckNameD;
  final String driverName;
  final int driverRefid;
  final String driverNameD;
  final String sPickupDate;
  final String sDeliveryDate;
  final String origin;
  final String destination;
  final String originD;
  final String destinationD;
  final String customerName;
  final String packageType;
  final String vesselName;
  final String jobNo;
  final String picName;
  final String loadingETA;
  final String offloadingETA;
  final String status;
  final String jobStatus;
  final String rtiNo;
  final int rtiMasterRefId;
  final String jobDate;
  final String jobName;
  final String awbNo;
  final String blCopy;
  final String truckSize;
  final String pickupDate;
  final String deliveryDate;
  final String pickupDateD;
  final String deliveryDateD;
  final String sPort;
  final String oPort;
  final String pickuptimelist;
  final String pickupQuantitylist;
  final String deliveryQuantitylist;
  final String delivertimelist;
  final String wareHouseEnterDate;
  final String wareHouseExitDate;
  final String wareHouseAddress;
  final String pickupAddress;
  final String deliveryAddress;
  final List<Map<String, dynamic>>? pickupsList;
  final List<Map<String, dynamic>>? deliveriesList;

  /// The tick (the web's `print`).
  final bool print;

  /// A truck is on the row (`hasTruckSelected`, `planningCellRenderers.tsx:90-95`).
  bool get hasTruck => truckRefid != 0 || truckName.trim().isNotEmpty;

  /// The OUTSIDE DRIVER truck (id 22 or that name, `planningCellRenderers.tsx:69-73`).
  bool get isOutsideDriverTruck => truckRefid == 22 || truckName.trim().toUpperCase() == 'OUTSIDE DRIVER';

  /// The driver is picked from the list only with a real truck; otherwise it is typed.
  bool get usesDriverPicker => hasTruck && !isOutsideDriverTruck;
}
