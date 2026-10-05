import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/plan_line_copy.dart';

/// One pickup or delivery stop of the Update window (the web's `AddressRow`).
class StopRow {
  const StopRow(
      {required this.key, this.dbId, this.address = '', this.datetime = '', this.weight = '', this.quantity = '', this.dateRequired = true});

  final String key;
  final int? dbId;
  final String address;

  /// `yyyy-MM-ddTHH:mm` or ''.
  final String datetime;
  final String weight;
  final String quantity;
  final bool dateRequired;

  StopRow copyWith({String? address, String? datetime, String? weight, String? quantity, bool? dateRequired}) => StopRow(
        key: key,
        dbId: dbId,
        address: address ?? this.address,
        datetime: datetime ?? this.datetime,
        weight: weight ?? this.weight,
        quantity: quantity ?? this.quantity,
        dateRequired: dateRequired ?? this.dateRequired,
      );
}

/// The Update window's working copy (`planningSaleOrderUpdate.ts` `buildPlanningSaleOrderUpdateState`).
class SaleOrderDraft {
  const SaleOrderDraft({
    required this.saleOrderId,
    this.orderNo = '',
    this.customerName = '',
    this.pickupDate = '',
    this.deliveryDate = '',
    this.origin = '',
    this.destination = '',
    this.originRefId = '',
    this.destinationRefId = '',
    this.quantity = '',
    this.weight = '',
    this.warehouseAddress = '',
    this.warehouseEnterDate = '',
    this.warehouseExitDate = '',
    this.pickups = const [],
    this.deliveries = const [],
    this.loadedPickupIds = const [],
    this.loadedDeliveryIds = const [],
  });

  /// The job the form belongs to; a save is refused for any other row.
  final int saleOrderId;
  final String orderNo;
  final String customerName;
  final String pickupDate;
  final String deliveryDate;
  final String origin;
  final String destination;
  final String originRefId;
  final String destinationRefId;
  final String quantity;
  final String weight;
  final String warehouseAddress;
  final String warehouseEnterDate;
  final String warehouseExitDate;
  final List<StopRow> pickups;
  final List<StopRow> deliveries;
  final List<int> loadedPickupIds;
  final List<int> loadedDeliveryIds;

  SaleOrderDraft copyWith({
    String? pickupDate,
    String? deliveryDate,
    String? origin,
    String? destination,
    String? originRefId,
    String? destinationRefId,
    String? quantity,
    String? weight,
    String? warehouseAddress,
    String? warehouseEnterDate,
    String? warehouseExitDate,
    List<StopRow>? pickups,
    List<StopRow>? deliveries,
  }) =>
      SaleOrderDraft(
        saleOrderId: saleOrderId,
        orderNo: orderNo,
        customerName: customerName,
        pickupDate: pickupDate ?? this.pickupDate,
        deliveryDate: deliveryDate ?? this.deliveryDate,
        origin: origin ?? this.origin,
        destination: destination ?? this.destination,
        originRefId: originRefId ?? this.originRefId,
        destinationRefId: destinationRefId ?? this.destinationRefId,
        quantity: quantity ?? this.quantity,
        weight: weight ?? this.weight,
        warehouseAddress: warehouseAddress ?? this.warehouseAddress,
        warehouseEnterDate: warehouseEnterDate ?? this.warehouseEnterDate,
        warehouseExitDate: warehouseExitDate ?? this.warehouseExitDate,
        pickups: pickups ?? this.pickups,
        deliveries: deliveries ?? this.deliveries,
        loadedPickupIds: loadedPickupIds,
        loadedDeliveryIds: loadedDeliveryIds,
      );

  /// Changing the job's pickup date carries it onto the only pickup stop (`:394-418`).
  SaleOrderDraft withPickupDate(String value) => copyWith(
        pickupDate: value,
        pickups: pickups.length == 1 ? [pickups.first.copyWith(datetime: value, dateRequired: value.isNotEmpty)] : null,
      );

  SaleOrderDraft withDeliveryDate(String value) => copyWith(
        deliveryDate: value,
        deliveries: deliveries.length == 1 ? [deliveries.first.copyWith(datetime: value, dateRequired: value.isNotEmpty)] : null,
      );
}

abstract final class SaleOrderUpdateRules {
  static const _blank = {
    '',
    'null',
    'undefined',
    '0001-01-01',
    '0001-01-01T00:00:00',
    '0001-01-01T00:00:00Z',
    '0001/01/01',
    '1900-01-01',
    '1900-01-01T00:00:00'
  };

  static bool isBlankDate(dynamic v) => v == null || _blank.contains(Js.text(v).trim());

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// `toDateTimeInputValue` (`edit-mapper/dateInputUtils.ts`): `yyyy-MM-ddTHH:mm` or ''.
  static String dateTimeInput(dynamic v) {
    if (isBlankDate(v)) return '';
    final raw = Js.text(v).trim();
    final m = RegExp(r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})(?:[T\s](\d{1,2}):(\d{2})(?::(\d{2}))?)?').firstMatch(raw);
    DateTime? d;
    if (m != null) {
      d = DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!), int.parse(m[4] ?? '0'), int.parse(m[5] ?? '0'));
    } else {
      final p = DateTime.tryParse(raw);
      d = p == null ? null : (p.isUtc ? p.toLocal() : p);
    }
    if (d == null) return '';
    return '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}T${_two(d.hour)}:${_two(d.minute)}';
  }

  static List<StopRow> _stopsFromArray(List<Map<String, dynamic>> items, String type) => [
        for (var i = 0; i < items.length; i++)
          () {
            final it = items[i];
            final time = Js.nn(it, ['datetime', 'pickupTime', 'deliveryTime']) ?? '';
            return StopRow(
              key: '$type-${i + 1}',
              dbId: Js.positiveInt(Js.or(it, ['id', 'Id'])) == 0 ? null : Js.positiveInt(Js.or(it, ['id', 'Id'])),
              address: Js.text(Js.nn(it, ['address', 'pickupAddress', 'deliveryAddress']) ?? ''),
              datetime: dateTimeInput(time),
              weight: Js.text(Js.nn(it, ['weight', 'pickupWeaight', 'pickupWeight', 'deliveryWeight']) ?? ''),
              quantity: Js.text(Js.nn(it, ['quantity', 'pickupQuantity', 'deliveryQuantity']) ?? ''),
              dateRequired: !isBlankDate(time),
            );
          }(),
      ];

  static List<StopRow> _stopsFromMaster(Map<String, dynamic> m, String type) {
    List<String> split(dynamic v) => isBlankDate(v) ? const [] : Js.text(v).split('{@}');
    final pickup = type == 'pickup';
    final addresses = split(m[pickup ? 'PickupAddress' : 'DeliveryAddress']);
    final quantities = split(pickup
        ? (m['pickupQuantityList'] ?? m['PickupQuantityList'] ?? m['pickupQuantitylist'])
        : (m['DeliveryQuantityList'] ?? m['deliveryQuantityList'] ?? m['deliveryQuantitylist']));
    final times = split(pickup
        ? (m['pickuptimelist'] ?? m['PickupTimelist'] ?? m['SPickupDate'])
        : (m['DelivertimeList'] ?? m['delivertimelist'] ?? m['SDeliveryDate']));
    final count = [addresses.length, quantities.length, times.length].reduce((a, b) => a > b ? a : b);
    return [
      for (var i = 0; i < count; i++)
        StopRow(
          key: '$type-${i + 1}',
          address: i < addresses.length ? addresses[i] : '',
          datetime: dateTimeInput(i < times.length ? times[i] : ''),
          quantity: i < quantities.length ? quantities[i] : '',
          dateRequired: !isBlankDate(i < times.length ? times[i] : ''),
        ),
    ].where((s) => s.address.isNotEmpty || s.datetime.isNotEmpty || s.quantity.isNotEmpty).toList();
  }

  /// The draft of [saleOrderId] from the sale order edit read (`saleOrderMaster`, `pickupDetails`,
  /// `deliveryDetails`); null when there is no order.
  static SaleOrderDraft? draftFrom(
      int saleOrderId, Map<String, dynamic> master, List<Map<String, dynamic>> pickupRows, List<Map<String, dynamic>> deliveryRows) {
    if (master.isEmpty) return null;
    String t(String k) => Js.text(master[k]);
    final pickups = pickupRows.isNotEmpty ? _stopsFromArray(pickupRows, 'pickup') : _stopsFromMaster(master, 'pickup');
    final deliveries = deliveryRows.isNotEmpty ? _stopsFromArray(deliveryRows, 'delivery') : _stopsFromMaster(master, 'delivery');
    final orderNo = [master['cNumberDisplay'], master['billNoDisplay']].where(Js.truthy).map(Js.text).firstOrNull ?? '';
    return SaleOrderDraft(
      saleOrderId: saleOrderId,
      orderNo: orderNo.isNotEmpty ? orderNo : 'Pending',
      customerName: t('customerName').isNotEmpty ? t('customerName') : 'Customer',
      pickupDate: dateTimeInput(master['pickupDate'] ?? master['sPickupDate']),
      deliveryDate: dateTimeInput(master['deliveryDate'] ?? master['sDeliveryDate']),
      origin: t('origin'),
      destination: t('destination'),
      originRefId: master['originRefId'] == null ? '' : Js.text(master['originRefId']),
      destinationRefId: master['destinationRefId'] == null ? '' : Js.text(master['destinationRefId']),
      quantity: t('quantity'),
      weight: t('totalWeight'),
      warehouseAddress: Js.text(Js.nn(master, ['wareHouseAddress', 'WareHouseAddress', 'warehouseAddress'])),
      warehouseEnterDate: dateTimeInput(Js.nn(master, ['wareHouseEnterDate', 'sWareHouseEnterDate', 'WareHouseEnterDate', 'SWareHouseEnterDate'])),
      warehouseExitDate: dateTimeInput(Js.nn(master, ['wareHouseExitDate', 'sWareHouseExitDate', 'WareHouseExitDate', 'SWareHouseExitDate'])),
      pickups: pickups,
      deliveries: deliveries,
      loadedPickupIds: [
        for (final s in pickups)
          if (s.dbId != null) s.dbId!
      ],
      loadedDeliveryIds: [
        for (final s in deliveries)
          if (s.dbId != null) s.dbId!
      ],
    );
  }

  static int? _positiveOrNull(dynamic v) => Js.positiveInt(v) == 0 ? null : Js.positiveInt(v);
  static String? _nullableText(String v) => v.trim().isEmpty ? null : v.trim();

  static List<Map<String, dynamic>> _stopRows(List<StopRow> stops) => [
        for (final s in stops)
          if (s.dbId != null || [s.address, s.quantity, s.weight, s.datetime].any((v) => v.trim().isNotEmpty))
            {
              'id': s.dbId,
              'address': s.address.trim(),
              'time': s.dateRequired && s.datetime.trim().isNotEmpty ? s.datetime.trim() : null,
              'weight': s.weight.trim(),
              'quantity': s.quantity.trim(),
            },
      ];

  static List<int> _removed(List<int> loaded, List<StopRow> stops) {
    final kept = {
      for (final s in stops)
        if (s.dbId != null) s.dbId
    };
    return loaded.where((id) => !kept.contains(id)).toList();
  }

  /// `buildPlanningJobUpdatePayload`: the 18 keys of `POST /api/planing/update-dates`.
  static Map<String, dynamic> payload(SaleOrderDraft d, {required int saleOrderId, required int companyId, required int employeeId}) => {
        'saleOrderId': saleOrderId,
        'companyId': companyId,
        'employeeId': _positiveOrNull(employeeId),
        'pickupDate': _nullableText(d.pickupDate),
        'deliveryDate': _nullableText(d.deliveryDate),
        'origin': d.origin.trim(),
        'destination': d.destination.trim(),
        'originRefId': _positiveOrNull(d.originRefId),
        'destinationRefId': _positiveOrNull(d.destinationRefId),
        'quantity': d.quantity.trim(),
        'totalWeight': d.weight.trim(),
        'wareHouseEnterDate': _nullableText(d.warehouseEnterDate),
        'wareHouseExitDate': _nullableText(d.warehouseExitDate),
        'wareHouseAddress': d.warehouseAddress,
        'pickups': _stopRows(d.pickups),
        'deliveries': _stopRows(d.deliveries),
        'removedPickupIds': _removed(d.loadedPickupIds, d.pickups),
        'removedDeliveryIds': _removed(d.loadedDeliveryIds, d.deliveries),
      };

  /// `applySaleOrderUpdateToRows`: the saved values onto every row of that job; the same list
  /// when the answer names no job.
  static List<PlanLine> applyToRows(List<PlanLine> rows, Map<String, dynamic>? saved) {
    final id = Js.intOr0(saved?['saleOrderId']);
    if (saved == null || id <= 0) return rows;
    String v(String k) => Js.text(saved[k]);
    return [
      for (final r in rows)
        if (r.saleOrderMasterRefId == id)
          r.copyWith(
            sPickupDate: v('pickupDate'),
            sDeliveryDate: v('deliveryDate'),
            origin: v('origin'),
            destination: v('destination'),
            packageType: v('packageType'),
            wareHouseEnterDate: v('wareHouseEnterDate'),
            wareHouseExitDate: v('wareHouseExitDate'),
            wareHouseAddress: v('wareHouseAddress'),
            pickupAddress: v('pickupAddress'),
            deliveryAddress: v('deliveryAddress'),
            pickupQuantitylist: v('pickupQuantityList'),
            deliveryQuantitylist: v('deliveryQuantityList'),
          )
        else
          r,
    ];
  }
}
