import 'package:dio/dio.dart';
import 'package:maleva/core/lookups/master_response.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Agent pickers, from the shared Java agent and agent company masters (change
/// `agent-lookups-on-shared-java-api`):
/// - agents, `POST /api/agents/select-all?companyRefId&jobId` (the port of .NET
///   AgentApp/SelectAgentAll; `jobId` is the agent company, 0 = all): not
///   deleted, by name, answered as `{ok, message, data, count}`; an agent is
///   `{id, companyRefId, agentCompanyRefId, name, cnumberDisplay, cnumber,
///   address1, email, mobileNo, userName, active, ...}`;
/// - agent companies, `GET /api/agent-companies/company/{companyId}` (the port
///   of .NET AgentCompanyApp/SelectAgentCompany): `{id, name, dFlag, active}`,
///   none answered as 204.
class AgentApi {
  AgentApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  /// The agents of [agentCompanyId] (0 = every agent company).
  Future<List<Map<String, dynamic>>> agents({int agentCompanyId = 0}) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>('/api/agents/select-all',
          queryParameters: {'companyRefId': _companyId(), 'jobId': agentCompanyId});
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final body = response.data;
    if (body is! Map || !JsonRead.boolean(body['ok'])) {
      throw ApiFailure(body is Map ? JsonRead.string(body['message']) : 'Unexpected response from server');
    }
    return JsonRead.listOfMaps(body['data']);
  }

  /// The agent companies, by name (as the pickers have always listed them).
  Future<List<Map<String, dynamic>>> agentCompanies() async {
    final rows = JsonRead.listOfMaps(await MasterResponse.data(
        () => _dio.get<dynamic>('/api/agent-companies/company/${_companyId()}')));
    rows.sort((a, b) => JsonRead.string(a['name']).toLowerCase().compareTo(JsonRead.string(b['name']).toLowerCase()));
    return rows;
  }
}
