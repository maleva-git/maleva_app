import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Enquiries, from the shared Java `/api/enquiry-masters` (ported from .NET
/// EnquiryMasterApp, change `enquiry-on-shared-java-api`). A row is the Java
/// enquiry (`id`, `customerRefId`, `jobMasterRefId`, `loadingvesselname`,
/// `offvesselname`, `sport`, `oport`, `forwardingDate`, `eta`, `oeta`,
/// `pickupDate`, `deliveryDate`, ... every column) with `customerName` and
/// `jobType`; it has the Java sale order's field names, so it opens the sale
/// order form as it is. A refusal is an [ApiFailure] with the server's message.
class EnquiryApi {
  EnquiryApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  /// The open enquiries (not cancelled or confirmed), by forwarding date.
  /// [team]: the employee's and the employees they lead (.NET DashboardStatus 2).
  /// [billType]: MY (forwarding) or TR (transport); null for both. The dates
  /// filter the forwarding date ([invoice]: the sale date), both included.
  Future<List<Map<String, dynamic>>> search({
    int employeeId = 0,
    bool team = false,
    String? billType,
    int customerId = 0,
    int jobTypeId = 0,
    bool invoice = false,
    DateTime? fromDate,
    DateTime? toDate,
  }) async =>
      JsonRead.listOfMaps(await _send(() => _dio.post<dynamic>('/api/enquiry-masters/search',
          queryParameters: {'companyId': companyId},
          data: {
            'customerId': customerId,
            'jobTypeId': jobTypeId,
            'employeeId': employeeId,
            'team': team,
            'invoice': invoice,
            if (fromDate != null && toDate != null) 'fromDate': _day.format(fromDate),
            if (fromDate != null && toDate != null) 'toDate': _day.format(toDate),
            if (billType != null) 'billType': billType,
          })));

  /// CANCEL (from the lists) or CONFIRMED (once it became a sale order).
  Future<void> setStatus(int id, String status) async {
    await _send(() => _dio.put<dynamic>('/api/enquiry-masters/$id/status',
        queryParameters: {'companyId': companyId, 'status': status}));
  }

  static final DateFormat _time = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Adds ([id] 0) or updates an enquiry from the Enquiry (MY, forwarding) or
  /// Enquiry TR (transport) form: `POST /api/enquiry-masters/entries`, the Java
  /// port of .NET `InsertEnquiryMaster` / `SP_EnquiryMaster`. An update changes
  /// only these fields. Answers the enquiry id; a refusal (no customer or job
  /// type, an unknown employee, ...) is an [ApiFailure] with the reason.
  Future<int> save({
    required int id,
    required String billType,
    required int customerId,
    required int jobTypeId,
    required DateTime forwardingDate,
    int? employeeId,
    String? loadingVessel,
    String? offVessel,
    String? loadingPort,
    String? offPort,
    DateTime? eta,
    DateTime? oeta,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    String? quantity,
    String? totalWeight,
    int? originId,
    String? origin,
    int? destinationId,
    String? destination,
  }) async {
    String? at(DateTime? d) => d == null ? null : _time.format(d);
    final saved = await _send(() => _dio.post<dynamic>('/api/enquiry-masters/entries',
        queryParameters: {'companyId': companyId},
        data: {
          'id': id,
          'billType': billType,
          'customerRefId': customerId,
          'jobTypeId': jobTypeId,
          'employeeRefId': employeeId == null || employeeId == 0 ? null : employeeId,
          'forwardingDate': at(forwardingDate),
          'loadingVessel': loadingVessel,
          'offVessel': offVessel,
          'loadingPort': loadingPort,
          'offPort': offPort,
          'eta': at(eta),
          'oeta': at(oeta),
          'pickupDate': at(pickupDate),
          'deliveryDate': at(deliveryDate),
          'quantity': quantity,
          'totalWeight': totalWeight,
          'originRefId': originId,
          'origin': origin,
          'destinationRefId': destinationId,
          'destination': destination,
        }));
    return JsonRead.number(saved).toInt();
  }

  /// An enquiry date as the lists show it, `dd-MM-yyyy HH:mm`; none is blank.
  static String display(dynamic value) {
    final d = JsonRead.date(value);
    return d == null ? '' : DateFormat('dd-MM-yyyy HH:mm').format(d);
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The enquiry as the sale order form reads a Java sale order. Both are Java
  /// rows; only the names Lombok spells differently in the two DTOs change.
  static Map<String, dynamic> asSaleOrder(Map<dynamic, dynamic> enquiry) {
    const renames = {
      'sport': 'sPort',
      'oport': 'oPort',
      'ovessel': 'oVessel',
      'jstatus': 'jStatus',
      'oagentCompanyRefId': 'oAgentCompanyRefId',
      'oagentMasterRefId': 'oAgentMasterRefId',
    };
    return {for (final e in enquiry.entries) renames[e.key.toString()] ?? e.key.toString(): e.value};
  }
}
