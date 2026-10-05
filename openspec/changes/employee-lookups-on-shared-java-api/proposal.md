# Proposal

## Why

The employee pickers called .NET `EmployeeApp/GetEmployee` from about 20 screens, and the port
picker called `GetEmployeeport`. The owner's rule (2026-10-02) says the app uses the shared Java
APIs React uses, and reads their fields.

## What Changes

- **New** `EmployeeApi` (`lib/core/employee`), registered in `auth_injection.dart`:
  - `dropdown(type, type1)` reads `GET /api/employees/company/{id}/all?type=`, the endpoint React's
    dropdowns use. It takes one type, so two types are two calls, merged by id and sorted by name.
    A blank type or `ALL` means every employee.
  - `portNames(employeeId)` reads `GET /api/employee-ports/company/{c}/employee/{e}` (active
    assignments) and names the ports from `GET /api/port-masters`.
- `EmployeeModel.fromJava` builds the picker's `AccountName` as `employeeName-employeeType`, as
  .NET did. The Java list never sends passwords, so `Password` is blank. The .NET `fromJson` is
  removed.
- **Callers moved:**
  - `LegacyApiRepository.SelectEmployee` and `GetEmployeeport`
  - the Enquiry TR, Sales Order add/view, Email Inbox, Google Review, TransportDB, FW Break Seal
    and Sale Order Details repositories
  - `MasterApi.getEmployees`, which had no callers, is removed, along with
    `ApiConstants.apiSelectEmployee`
- **Employee Master** (list, add, edit, delete) moves to the endpoints React uses:
  `POST /api/employees/search`, `POST /api/employees/bulk/{companyId}`, and
  `DELETE /api/employees/{id}?companyRefId=` (company-scoped, backend change
  `scope-employee-delete-to-company`). `EmployeeDetailsModel.fromJava` / `toJava` read and write
  the Java fields.
- **New required Role picker** in the Employee Master form, filled from `GET /api/employees/types`
  (owner decision 2026-10-05). Java's save makes a new employee with no role SUPERADMIN, so the app
  refuses to save without a role. An edit starts from the employee's current role.
- FW Break Seal and Sale Order Details sent `&AccountName=&Type=Operation` without `type1`; .NET
  probably did not match that call. They now ask for the Operation employees, which was clearly
  intended.

## Kept as .NET

- Only active employees (`active = 1`) are offered; the Java list also carries inactive ones.
- Employee Master lists up to 100 employees, all columns, as before.
- `Sales` does not add TRANSPORTATION. .NET's rule was case-sensitive, and the app's lower-case
  values never triggered it.

## Not in this change

- **Email Inbox** (`SelectEmailData`, `InsertMailMaster`) and **Google Review** need Java ports of
  `SP_EmailInbox` and `SP_GoogleReview`, whose sources are not in the repositories.

## Behaviour changes (Employee Master)

- The Password field starts blank on an edit, because Java never sends passwords. Leaving it blank
  keeps the current password; typing one replaces it.
- The Account Code is shown but not saved; it is the employee's ledger code.
- A delete shows the app's own message, because Java answers 204.

## Capabilities

### Modified Capabilities
- `api-integration`: employee and port pickers and Employee Master use the shared Java employee APIs.

## Impact

`lib/core/employee/employee_api.dart` (new), `lib/core/models/shared/employee_model.dart`,
`lib/core/models/shared/employee_details_model.dart`, `dashboard/common_tabs/employeemaster`,
`legacy_api_repository.dart`, `master_api.dart`, `api_constants.dart`, `auth_injection.dart`, and the
repositories and blocs listed above. Ships with backend change `scope-employee-delete-to-company`.
