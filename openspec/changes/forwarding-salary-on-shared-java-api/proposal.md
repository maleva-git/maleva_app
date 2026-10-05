# Proposal

## Why

The Forwarding Salary screen called .NET `ForwardingSalaryApp`: `SelectForwardingSalary` and
`InsertForwardingSalary` (`SP_ForwardingSalary`). Backend change `share-forwarding-salary-api` ports
both as Java.

## What Changes

| Action | Before (.NET) | Now (shared Java) |
|---|---|---|
| Load an RTI's forwarding salary | `SelectForwardingSalary` `{Comid, RTIMasterRefId}` | `GET /api/forwarding-salaries/entries?companyId&rtiId` |
| Save | `InsertForwardingSalary` `[{Id, CompanyRefId, ...}]` | `POST /api/forwarding-salaries/entries?companyId` |

- **New** `ForwardingSalaryApi` (`lib/core/employee`), registered in `auth_injection.dart`.
- **The bloc reads the Java fields:** `id`, `employeeMasterRefId`, `employeeMasterRefId1`, `salary1`, `salary2`.
- **The save sends the Java fields**, with "no employee" as null. The company is the session's, sent as a parameter.
- **Removed:** `ApiConstants.apiInsertForwarding` and `apiSelectForwarding`. The network tests now use `apiSelectBoardingSalaryByEmpId` as their example of a call still on .NET.

## Behaviour changes

- **A refused save shows the server's reason** (for example "Select the RTI"), and the form stays as it was. It used to fail silently.
- **The company fallback is gone.** A session without a company no longer falls back to company 6, as the old load did.

## Capabilities

### Modified Capabilities
- `api-integration`: Forwarding Salary uses the shared Java forwarding salary API.

## Impact

`lib/core/employee/forwarding_salary_api.dart` (new), `operations/forwardingsalary/{data,bloc}`,
`api_constants.dart`, `auth_injection.dart` and the network tests. Ships with backend change
`share-forwarding-salary-api`.
