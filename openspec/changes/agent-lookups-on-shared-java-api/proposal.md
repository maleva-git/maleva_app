# Proposal

## Why

The agent and agent company pickers still posted the old .NET addresses `AgentApp/SelectAgentAll` and
`AgentCompanyApp/SelectAgentCompany`. `LegacyCallAdapter` answered them from Java in .NET row shapes,
and Sale Order details read those rows as raw maps (`a['AgentName']`). Under rule 2 they move to the
Java fields.

## What Changes

- **New** `AgentApi` (`lib/core/lookups`), registered in `auth_injection.dart`:
  - `agents(agentCompanyId)`: `POST /api/agents/select-all?companyRefId&jobId`. It reads that controller's `{ok, message, data, count}` as it is (rule 2).
  - `agentCompanies()`: `GET /api/agent-companies/company/{companyId}`, the `{success, data}` wrapper. It is kept sorted by name, as the pickers listed them.
- **`MasterResponse`** treats 204 No Content (what agent companies answer when there are none) as an empty list.
- **Model readers:** `AgentModel.fromJava` and `AgentCompanyModel.fromJava` read `name`, `cnumberDisplay`, `cnumber`, `dFlag` and so on, without case. The password and token are never read. The .NET `fromJson` readers are removed.
- **Callers moved:**
  - `LegacyApiRepository.SelectAgentCompany` / `SelectAgentAll` (the agent pickers);
  - Sales Order add;
  - Sale Order details, whose agent and agent-company names are looked up in the models.
- **Removed:**
  - the adapter entries;
  - `SharedLookups.agents` / `agentCompanies` and their tests;
  - `ApiConstants.apiSelectAgentAll` / `apiSelectAgentCompany`.
- **Adapter test:** the legacy-DioClient test now uses the address search (`KeyWord`), still on the adapter.

## Behaviour changes

None intended. A failed load now carries the server's message.

## Left on the adapter

5 lookup addresses: products, addresses (2) and drivers, plus trucks (3: list, details, save).

## Capabilities

### Modified Capabilities
- `api-integration`: the agent and agent company pickers read the shared Java APIs directly.

## Impact

`lib/core/lookups/{agent_api,master_response,shared_lookups}.dart`, `agent_model.dart`,
`agent_company_model.dart`, `legacy_api_repository.dart`, `legacy_call_adapter.dart`,
`api_constants.dart`, `auth_injection.dart`, the sales order add and sale order details features, and
the lookup and adapter tests. No backend change.
