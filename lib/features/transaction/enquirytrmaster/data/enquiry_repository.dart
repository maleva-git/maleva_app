import 'package:maleva/core/enquiry/enquiry_api.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

class EnquiryTrRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;

  EnquiryTrRepository(this._dioClient, this._sessionManager);

  int get _comId => _sessionManager.companyId;

  /// The customer's currency rate (shared Java `/api/currency-value/get`, as the sale order form).
  Future<double> loadCustomerCurrency(int customerId) => sl<SaleOrderApi>().currencyValue(customerId);

  /// Fetch all job statuses based on JobId
  Future<List<dynamic>> selectAllJobStatus(int jobId) async {
    try {
      final endpoint = "${ApiConstants.apiSelectAllJobStatus}$_comId&Jobid=$jobId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null) {
        if (response.data is List && response.data.isNotEmpty) {
           final firstItem = response.data[0];
           if (firstItem != null && firstItem['JobStatusDetails'] != null) {
              return firstItem['JobStatusDetails'];
           }
        }
      }
    } catch (e) {
      print("Error selecting all job status: $e");
    }
    return [];
  }

  /// Adds or updates a transport enquiry (shared Java `/api/enquiry-masters/entries`,
  /// the port of .NET InsertEnquiryMaster). The enquiry id.
  Future<int> saveEnquiry({
    required int id,
    required String billType,
    required int customerId,
    required int jobTypeId,
    required DateTime forwardingDate,
    int? employeeId,
    String? loadingPort,
    String? offPort,
    String? quantity,
    String? totalWeight,
    int? originId,
    String? origin,
    int? destinationId,
    String? destination,
    DateTime? pickupDate,
    DateTime? deliveryDate,
  }) =>
      GetIt.instance<EnquiryApi>().save(
        id: id,
        billType: billType,
        customerId: customerId,
        jobTypeId: jobTypeId,
        forwardingDate: forwardingDate,
        employeeId: employeeId,
        loadingPort: loadingPort,
        offPort: offPort,
        quantity: quantity,
        totalWeight: totalWeight,
        originId: originId,
        origin: origin,
        destinationId: destinationId,
        destination: destination,
        pickupDate: pickupDate,
        deliveryDate: deliveryDate,
      );

  /// The open enquiries (shared Java enquiry API): the employee's own, by
  /// customer, job type and an optional date range ([invoice]: the sale date).
  Future<List<Map<String, dynamic>>> fetchEnquiryMaster({
    required int employeeId,
    required int customerId,
    required int jobTypeId,
    required bool invoice,
    String? fromDate,
    String? toDate,
  }) =>
      GetIt.instance<EnquiryApi>().search(
        employeeId: employeeId,
        customerId: customerId,
        jobTypeId: jobTypeId,
        invoice: invoice,
        fromDate: fromDate == null ? null : DateTime.tryParse(fromDate),
        toDate: toDate == null ? null : DateTime.tryParse(toDate),
      );

  /// Cancel Enquiry (shared Java enquiry API)
  Future<bool> cancelEnquiry(int id) async {
    await GetIt.instance<EnquiryApi>().setStatus(id, 'CANCEL');
    return true;
  }


  /// Select Employee list (the shared Java employee list)
  Future<List<EmployeeModel>> selectEmployee(String type, String type1) =>
      GetIt.instance<EmployeeApi>().dropdown(type: type, type1: type1);

}
