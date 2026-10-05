# Proposal

## Why

The leave screens called .NET `/api/LeaveRequestApp/*`. The URL was built from the host directly, so
earlier counts missed it:
- Driver Leave Request and Employee Leave Request;
- the Admin and Employee Leave Approval tabs.

Backend change `share-leave-api` ports them, including `SP_LeaveRequestMaster`.

## What Changes

| Action | Before (.NET) | Now (shared Java) |
|---|---|---|
| Leave types | `GetLeaveTypes?comid` | `GET /api/leave/types` |
| List | `GetLeaveRequests?comid&applicantType&...` | `POST /api/leave/search` `{companyRefId, applicantType, applicantRefId, fromDate, toDate}` |
| Request leave | `SaveLeaveRequest` | `POST /api/leave/save?companyId` |
| Approve / reject | `UpdateLeaveStatus` | `PUT /api/leave/{id}/status?companyId` |

- **New** `LeaveApi` (`lib/core/employee`), registered in `auth_injection.dart`. `LeaveRepository` uses it, and now takes only the session (DI updated).
- **The models read the Java fields:** `LeaveRequestModel.fromJava` and `LeaveTypeModel.fromJava`. The .NET `fromJson` is removed. `createdDate` falls back to the from-date, because the Java row has none (it is listed newest first).
- **Errors show the server's reason.** A refusal used to return `false`, which showed a generic "Failed".
- **Removed:** the unused static `leave_request_api.dart`, the last .NET address in the app that was built from the host.

## Behaviour changes

- **A driver lists and requests only their own leave.** The server enforces it.
- **Reasons are upper-cased**, as the procedure stored them. The "reviewed by" name is the reviewing employee.
- **Bad input is refused with a message:** a missing leave type, a from-date after the to-date, or another company's request.

## Capabilities

### Modified Capabilities
- `api-integration`: the leave screens use the shared Java leave API.

## Impact

`lib/core/employee/leave_api.dart` (new), `dashboard/common_tabs/driverleave/{data,bloc}`,
`core/di/injection.dart`, `auth_injection.dart`. Ships with backend change `share-leave-api`.
