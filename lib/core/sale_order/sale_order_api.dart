import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_report.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// A sale order as the Java edit read answers it (`GET /api/sale-orders/edit`).
///
/// [master] is `SaleOrderMasterDto` with the Java field names (`id`, `customerRefId`,
/// `jobMasterRefId`, `jStatus`, `offvesselname`, `loadingvesselname`, `sPort`, `oPort`,
/// `eta` ... as ISO date-times, `lBoardingOfficerRefid`, `forwardingSMKNo2`, ...).
class SaleOrderEdit {
  const SaleOrderEdit({
    required this.master,
    required this.details,
    required this.pickups,
    required this.deliveries,
    required this.forwarding,
  });

  factory SaleOrderEdit.fromJava(Map<String, dynamic> data) => SaleOrderEdit(
        master: JsonRead.map(data['saleOrderMaster']),
        details: JsonRead.listOfMaps(data['saleOrderDetails']),
        pickups: JsonRead.listOfMaps(data['pickupDetails']),
        deliveries: JsonRead.listOfMaps(data['deliveryDetails']),
        forwarding: JsonRead.listOfMaps(data['forwardingDetails']),
      );

  final Map<String, dynamic> master;

  /// Item lines: `itemMasterRefId`, `productCode`, `productName`, `uom`, `mrp`, `itemQty`,
  /// `salesRate`, `amount`, `taxPercent`, `taxAmount`, `currencyValue`, `actualAmount`, ...
  final List<Map<String, dynamic>> details;

  /// `pickupAddress`, `pickupQuantity`, `pickupWeight`, `pickupTime`.
  final List<Map<String, dynamic>> pickups;

  /// `deliveryAddress`, `deliveryQuantity`, `deliveryWeight`, `deliveryTime`.
  final List<Map<String, dynamic>> deliveries;

  /// The React form's forwarding legs (`SaleOrderForwarding`); the screens use the master columns.
  final List<Map<String, dynamic>> forwarding;

  int get id => JsonRead.integer(master['id']);
  int get jobMasterRefId => JsonRead.integer(master['jobMasterRefId']);
  int get jStatus => JsonRead.integer(master['jStatus']);
}

/// The sale order list (`{salemaster, saledetails}`); rows keep the .NET names
/// (`Id`, `BillNoDisplay`, `CustomerName`, `SETA`, `NetAmt`, ...).
class SaleOrderList {
  const SaleOrderList(this.masters, this.details);

  factory SaleOrderList.fromJava(dynamic data) {
    final m = JsonRead.map(data);
    return SaleOrderList(JsonRead.listOfMaps(m['salemaster']), JsonRead.listOfMaps(m['saledetails']));
  }

  final List<Map<String, dynamic>> masters;
  final List<Map<String, dynamic>> details;
}

/// Sale orders, from the shared Java APIs the web uses (`/api/sale-orders`, the
/// sequence, currency, vessel planning and planning endpoints; change
/// `sale-order-on-shared-java-api`). Answers the Java data as it is; a refusal is an
/// [ApiFailure] with the server's message.
class SaleOrderApi {
  SaleOrderApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  // ------------------------------------------------------------------ lists

  /// `POST /api/sale-orders/search`. [filter] uses the search names (`Id` customer,
  /// `Employeeid`, `Statusid`, `Search`, `ETA`, `ETAType`, `Pickup`, ...); dates as
  /// [DateTime] are sent as `yyyy/MM/dd`.
  Future<SaleOrderList> search(Map<String, dynamic> filter, {DateTime? from, DateTime? to}) async =>
      SaleOrderList.fromJava(await _send(() => _dio.post<dynamic>('/api/sale-orders/search',
          data: _filter(filter, from, to))));

  /// `POST /api/sale-orders/tv-search`: today/tomorrow by ETA or ETB unless a search,
  /// ETA or pickup filter is given; [westport] limits to WESTPORT-B18.
  Future<SaleOrderList> tvSearch(Map<String, dynamic> filter, {DateTime? from, DateTime? to, bool westport = false}) async =>
      SaleOrderList.fromJava(await _send(() => _dio.post<dynamic>('/api/sale-orders/tv-search',
          queryParameters: {'westport': westport}, data: _filter(filter, from, to))));

  /// Jobs for the job pickers: `[{id, cNumber, cNumberDisplay, forwardingEnterRef..3, forwardingSMKNo..3}]`.
  /// [jobType] 0 forwarding (MY), 1 transport (TR), 3 every bill type.
  Future<List<Map<String, dynamic>>> jobNumbers(int jobType) async => JsonRead.listOfMaps(await _send(() =>
      _dio.get<dynamic>('/api/sale-orders/job-numbers', queryParameters: {'companyId': companyId, 'jobType': jobType})));

  /// Sale update rows: `[{id, cNumberDisplay, saleDate (dd/MM/yyyy), remarks1, origin, destination, customerName}]`.
  Future<List<Map<String, dynamic>>> trips({required DateTime from, required DateTime to, int customerId = 0}) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/sale-orders/trips', queryParameters: {
            'companyId': companyId, 'fromDate': _iso(from), 'toDate': _iso(to), 'customerId': customerId,
          })));

  // ------------------------------------------------------------- one order

  /// `GET /api/sale-orders/edit`: by [id], or by job number [saleOrderNo].
  Future<SaleOrderEdit> edit({int id = 0, int saleOrderNo = 0}) async =>
      SaleOrderEdit.fromJava(JsonRead.map(await _send(() => _dio.get<dynamic>('/api/sale-orders/edit',
          queryParameters: {'companyId': companyId, if (id > 0) 'id': id, if (saleOrderNo > 0) 'saleOrderNo': saleOrderNo}))));

  /// Creates (`id` 0) or updates the order. [order] is the Java `SaleOrderDTO`; answers the saved master.
  Future<Map<String, dynamic>> save(Map<String, dynamic> order) async {
    final id = JsonRead.integer(order['id']);
    final data = await _send(() => id > 0
        ? _dio.put<dynamic>('/api/sale-orders/$id', data: order)
        : _dio.post<dynamic>('/api/sale-orders/save', data: order,
            options: Options(receiveTimeout: const Duration(seconds: 180))));
    return JsonRead.map(data);
  }

  Future<void> updateForwarding(int id, Map<String, dynamic> fields) async {
    await _send(() => _dio.put<dynamic>('/api/sale-orders/$id/forwarding',
        queryParameters: {'companyId': companyId}, data: fields));
  }

  /// Status (over 0), boarding start and end (`yyyy-MM-ddTHH:mm:ss`).
  Future<void> updateBoarding(int id, {int statusId = 0, DateTime? start, DateTime? end}) async {
    await _send(() => _dio.put<dynamic>('/api/sale-orders/$id/boarding', queryParameters: {'companyId': companyId}, data: {
          'statusId': statusId,
          if (start != null) 'boardingStartTime': _isoTime(start),
          if (end != null) 'boardingEndTime': _isoTime(end),
        }));
  }

  /// "Boarding Status Updated" email and WhatsApp with the photos.
  Future<void> sendBoardingMail(int id, {required String statusName, List<String> imageUrls = const []}) async {
    await _send(() => _dio.post<dynamic>('/api/sale-orders/$id/boarding-mail',
        queryParameters: {'companyId': companyId}, data: {'statusName': statusName, 'imageUrls': imageUrls}));
  }

  Future<void> updateAirFreight(int id, {int statusId = 0, String awbNo = ''}) async {
    await _send(() => _dio.put<dynamic>('/api/sale-orders/$id/air-freight',
        queryParameters: {'companyId': companyId}, data: {'statusId': statusId, 'awbNo': awbNo}));
  }

  Future<void> updateTrip(int id, {required String remarks1, required String origin, required String destination}) async {
    await _send(() => _dio.put<dynamic>('/api/sale-orders/$id/trip',
        queryParameters: {'companyId': companyId},
        data: {'remarks1': remarks1, 'origin': origin, 'destination': destination}));
  }

  /// The Vessel Planning update (`POST /api/vessel-plannings/sale-order-update`).
  ///
  /// Status, cargo and dates: null keeps, a blank date clears (`yyyy-MM-dd HH:mm:ss`); a
  /// blank [ptw] clears it, a blank [cargo] keeps it. The
  /// officers are always the whole picture: the server compares the three loading and
  /// three off-vessel slots with the job and treats a missing one as removed, so both
  /// sides are required (send the job's current ones for a side not being changed).
  /// When a side changes the server sets its amounts (50, 30 each, 20 each).
  Future<Map<String, dynamic>> vesselUpdate(int id,
      {int? jobStatusId,
      String? cargo,
      String? ptw,
      String? eta,
      String? etb,
      String? etd,
      String? oeta,
      String? oetb,
      String? oetd,
      required List<int> loadingOfficers,
      required List<int> offOfficers}) async {
    int slot(List<int> l, int i) => i < l.length ? l[i] : 0;
    try {
      final response = await _dio.post<dynamic>('/api/vessel-plannings/sale-order-update', data: {
        'saleOrderId': id,
        'companyId': companyId,
        if (jobStatusId != null) 'jobStatusId': jobStatusId,
        if (cargo != null) 'cargo': cargo,
        if (ptw != null) 'ptw': ptw,
        if (eta != null) 'eta': eta,
        if (etb != null) 'etb': etb,
        if (etd != null) 'etd': etd,
        if (oeta != null) 'oeta': oeta,
        if (oetb != null) 'oetb': oetb,
        if (oetd != null) 'oetd': oetd,
        'loadingOfficer1': slot(loadingOfficers, 0),
        'loadingOfficer2': slot(loadingOfficers, 1),
        'loadingOfficer3': slot(loadingOfficers, 2),
        'offOfficer1': slot(offOfficers, 0),
        'offOfficer2': slot(offOfficers, 1),
        'offOfficer3': slot(offOfficers, 2),
      });
      final body = JsonRead.map(response.data);
      if (body['ok'] == false) {
        throw ApiFailure(JsonRead.stringOrNull(body['message']) ?? 'Update failed');
      }
      return body;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  // ---------------------------------------------------------------- lookups

  /// The job number the next order of [billType] would take (a preview), e.g. `MY000001234`.
  Future<String> nextJobNo(String billType) async {
    try {
      final response = await _dio.get<dynamic>('/api/sequence-masters/company/$companyId/max-sequence',
          queryParameters: {'billType': billType});
      return JsonRead.string(JsonRead.map(response.data)['No']);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The customer's currency rate (1 when none is set).
  Future<double> currencyValue(int customerId) async {
    try {
      final response = await _dio.get<dynamic>('/api/currency-value/get',
          queryParameters: {'companyId': companyId, 'customerId': customerId});
      final data = JsonRead.map(JsonRead.map(response.data)['data']);
      return (data['currencyValue'] as num?)?.toDouble() ?? 1;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return 1;
      throw JavaResponse.fromDio(e);
    }
  }

  /// `{saleOrderId, jobNo, invoiced, invoiceId, invoiceNo, qneCode, ...}`.
  Future<Map<String, dynamic>> invoiceLink(int id) async => JsonRead.map(await _send(() =>
      _dio.get<dynamic>('/api/sale-orders/$id/invoice-link', queryParameters: {'companyId': companyId})));

  /// The Vessel Planning update on several jobs (`POST /api/vessel-plannings/sale-order-update-many`):
  /// what is given is written on every job, the rest stays as each job has it (dates
  /// `yyyy-MM-dd HH:mm:ss`). Answers `{requested, updated, skipped, results: [{saleOrderId,
  /// jobNo, ok, message}]}`; a job the rules refuse is named in its result.
  Future<Map<String, dynamic>> vesselUpdateMany(List<int> ids,
      {int? jobStatusId, String? eta, String? etb, String? oeta, String? oetb}) async {
    try {
      final response = await _dio.post<dynamic>('/api/vessel-plannings/sale-order-update-many', data: {
        'companyId': companyId,
        'saleOrderIds': ids,
        if (jobStatusId != null) 'jobStatusId': jobStatusId,
        if (eta != null) 'eta': eta,
        if (etb != null) 'etb': etb,
        if (oeta != null) 'oeta': oeta,
        if (oetb != null) 'oetb': oetb,
      });
      return JsonRead.map(response.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The Planning Update window (`POST /api/planing/update-dates`, the successor of .NET
  /// `SaleOrder/UpdateSaleorder`): the pickup/delivery/warehouse dates (`yyyy-MM-dd'T'HH:mm:ss`,
  /// null or blank clears, as the window's unticked box), the warehouse address and, when
  /// given, the stops (`{id, address, time, weight, quantity}`; an id 0 is a new stop) with
  /// the ids of the stops removed. The server also writes origin, destination, quantity and
  /// total weight, so the job's current ones are read first and sent back unchanged.
  Future<Map<String, dynamic>> planningUpdate(int id,
      {String? pickupDate,
      String? deliveryDate,
      String? wareHouseEnterDate,
      String? wareHouseExitDate,
      required String wareHouseAddress,
      int? employeeId,
      List<Map<String, dynamic>>? pickups,
      List<Map<String, dynamic>>? deliveries,
      List<int> removedPickupIds = const [],
      List<int> removedDeliveryIds = const []}) async {
    final job = (await edit(id: id)).master;
    try {
      final response = await _dio.post<dynamic>('/api/planing/update-dates', data: {
        'saleOrderId': id,
        'companyId': companyId,
        'employeeId': employeeId,
        'pickupDate': pickupDate,
        'deliveryDate': deliveryDate,
        'wareHouseEnterDate': wareHouseEnterDate,
        'wareHouseExitDate': wareHouseExitDate,
        'wareHouseAddress': wareHouseAddress,
        'origin': job['origin'],
        'destination': job['destination'],
        'originRefId': job['originRefId'],
        'destinationRefId': job['destinationRefId'],
        'quantity': job['quantity'],
        'totalWeight': job['totalWeight'],
        if (pickups != null) 'pickups': pickups,
        if (deliveries != null) 'deliveries': deliveries,
        if (pickups != null) 'removedPickupIds': removedPickupIds,
        if (deliveries != null) 'removedDeliveryIds': removedDeliveryIds,
      });
      final body = JsonRead.map(response.data);
      if (body['ok'] == false) {
        throw ApiFailure(JsonRead.stringOrNull(body['message']) ?? 'Update failed');
      }
      return body;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The job's loading (`L`) or off-vessel (`O`) boarding officers as read by [edit], 0 for none.
  static List<int> officers(Map<String, dynamic> master, String side) => [
        for (final k in ['${side}BoardingOfficerRefid', '${side}BoardingOfficer1Refid', '${side}BoardingOfficer2Refid'])
          JsonRead.integer(master[k[0].toLowerCase() + k.substring(1)]),
      ];

  // ------------------------------------------------------------------ print

  /// The full link of a report path the print endpoints answer (they need no sign-in).
  static String reportUrl(String path) => javaReportUrl(path);

  /// Converts the job to a DO (if not yet) and answers the report's path (`/api/v1/sale-invoices/print/...`).
  Future<String> doPrintPath(int id) async => JsonRead.string(JsonRead.map(await _send(() =>
      _dio.post<dynamic>('/api/sale-orders/$id/do-convert/print-ticket', queryParameters: {'companyId': companyId})))['Url']);

  /// The job's invoice report path; an [ApiFailure] when the job has no invoice yet.
  Future<String> invoicePrintPath(int id) async {
    final link = await invoiceLink(id);
    final invoiceId = JsonRead.integer(link['invoiceId']);
    if (link['invoiced'] != true || invoiceId <= 0) {
      throw const ApiFailure('This job has no invoice yet');
    }
    return JsonRead.string(JsonRead.map(await _send(() => _dio.get<dynamic>(
        '/api/v1/sale-invoices/$invoiceId/print-ticket', queryParameters: {'companyId': companyId})))['Url']);
  }

  // ---------------------------------------------------------------- helpers

  Map<String, dynamic> _filter(Map<String, dynamic> filter, DateTime? from, DateTime? to) => {
        ...filter,
        'Comid': companyId,
        if (from != null) 'Fromdate': _slash(from),
        if (to != null) 'Todate': _slash(to),
      };

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _slash(DateTime d) => '${d.year}/${_two(d.month)}/${_two(d.day)}';
  static String _iso(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String _isoTime(DateTime d) => '${_iso(d)}T${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
