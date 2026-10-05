# Proposal

## Why

The Salary tab (boarding, operation and admin dashboards) called .NET
`BoardingSalaryApp/SelectBoardingSalaryByEmpId`. The owner chose (2026-10-05) the shared Java
Boarding Salary API that React uses, `/api/boarding-settlement/monthly-salary`, so the app and React
show the same salaries.

## What Changes

| Before (.NET) | Now (shared Java) |
|---|---|
| `POST SelectBoardingSalaryByEmpId {Comid, Employeeid, FromDate, ToDate}` | `GET /api/boarding-settlement/monthly-salary?fromDate&toDate&employeeId&companyId` |

- **New** `BoardingSalaryApi` (`lib/core/employee`), registered in `auth_injection.dart`.
- **The tab reads the Java row:** `boardingDate`, `vesselName`, `employeeName`, `calculatedRate`. The total is the sum of `calculatedRate`.
- **Who sees what is unchanged.** An admin asks for every officer; anyone else asks for their own employee id.
- **The company is sent** (backend change `share-boarding-salary-api`), so only the company's officers are listed.
- **Removed:** `ApiConstants.apiSelectBoardingSalaryNew` and `apiSelectBoardingSalaryByEmpId`. The network tests now use `apiSelectAllInventory` as their example of a call still on .NET.

## Behaviour changes

- **The figures follow the shared rate rule**, not the amount stored on the job: per vessel per day, RM50 for one officer, RM30 each for two, RM20 each for three or more. They now match React's Boarding Salary page.
- **Only the session company's officers are listed.** .NET listed every company's.
- **One row per officer, vessel and day, per load type** (LOADING / OFFLOADING), as React shows.

## Capabilities

### Modified Capabilities
- `api-integration`: the Salary tab uses the shared Java boarding salary API.

## Impact

`lib/core/employee/boarding_salary_api.dart` (new), `dashboard/common_tabs/salary/{data,view}`,
`api_constants.dart`, `auth_injection.dart` and the network tests. Ships with backend change
`share-boarding-salary-api`.
