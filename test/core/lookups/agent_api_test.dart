import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/lookups/agent_api.dart';
import 'package:maleva/core/models/shared/agent_company_model.dart';
import 'package:maleva/core/models/shared/agent_model.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Agent and agent company pickers read the shared Java APIs directly
/// (agent-lookups-on-shared-java-api), not through the old .NET-shaped adapter (now removed).
void main() {
  late QueueAdapter adapter;
  late AgentApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = AgentApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  test("an agent company's agents read the Java fields", () async {
    adapter.replies.add((200, jsonEncode({'ok': true, 'message': 'ok', 'count': 1, 'data': [
      {'id': 5, 'companyRefId': 6, 'agentCompanyRefId': 2, 'name': 'SEA AGENT', 'cnumberDisplay': 'AG005', 'cnumber': 5,
        'mobileNo': '012', 'active': 1},
    ]})));

    final rows = await api.agents(agentCompanyId: 2);

    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/agents/select-all?companyRefId=6&jobId=2');
    final agent = AgentModel.fromJava(rows.single);
    expect([agent.Id, agent.AgentName, agent.CNumberDisplay, agent.CNumber, agent.AgentCompanyRefId, agent.MobileNo],
        [5, 'SEA AGENT', 'AG005', 5, 2, '012']);
    expect(agent.Password, '');
  });

  test('agent companies come by name; none (204) is an empty list', () async {
    adapter.replies
      ..add((200, jsonEncode({'success': true, 'statusCode': 200, 'message': 'ok', 'data': [
        {'id': 3, 'name': 'zeta shipping', 'dflag': 0, 'active': 1},
        {'id': 2, 'name': 'Alpha Agencies', 'dflag': 1, 'active': 1},
      ]})))
      ..add((204, ''));

    final companies = (await api.agentCompanies()).map(AgentCompanyModel.fromJava).toList();
    expect(adapter.requests.first.uri.toString(), 'https://java.test/api/agent-companies/company/6');
    expect(companies.map((c) => c.Name), ['Alpha Agencies', 'zeta shipping']);
    expect(companies.first.DFlag, 1);
    expect(await api.agentCompanies(), isEmpty);
  });

  test('a refused agent list is the server message', () async {
    adapter.replies.add((400, jsonEncode({'ok': false, 'message': 'CompanyRefId must be a valid positive integer'})));

    expect(() => api.agents(), throwsA(isA<ApiFailure>()
        .having((f) => f.message, 'message', 'CompanyRefId must be a valid positive integer')));
  });
}
