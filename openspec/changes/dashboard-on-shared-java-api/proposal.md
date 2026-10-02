# Proposal

## Why

Owner's rule (2026-10-02): the app uses the Java APIs the web app uses and reads their answers as
they are; the backend is not reshaped for the app. The dashboard numbers still came from the old
.NET `LoginApp` and `DashBoardApp` calls, although the web's Java `/api/dashboard` (React's
dashboards) answers the same figures.

## What Changes

- **New** `DashboardApi` (`lib/core/dashboard`): the web's `/api/dashboard` endpoints, answering
  the Java `data` as it is. It reads the `{success, statusCode, message, data}` wrapper; a refusal
  is an `ApiFailure` with the server's message.
- Moved to Java, screens reading the Java fields:
  - Sale-order desk and invoice desk: summary (`/sales`, `monthlySales` in place of `Data2`) and
    employee rows (`/employee-sales`, `/employee-invoice`).
  - Expense report (`/expense`) and forwarding report (`/forwarding`, camelCase keys
    `todayCount`, `k1Count`, ...).
  - Unreleased numbers (`/unreleased`, `/k8-unreleased`).
  - The five sales desks (air-freight sales, transport sales, sub-admin sales, customer
    dashboard, legacy transport dashboard): employee switcher (`/employee-rules`), four counts
    (`/check-invoice-count`) and the open orders by status (`/sales-order-status`), through one
    `salesDesk` call.
  - Air freight dashboard (`/air-freight`, camelCase rows `jobNo`, `awbNo`, `port`, ...).
- Dead .NET helpers removed: `SalesApi`, the dashboard methods of `ReportsApi` and `AuthApi`, and
  their constants.
- No backend change.

## Not in this change (still .NET)

| Screen part | .NET call | Why it waits |
|---|---|---|
| Invoice desk waiting bills | MasterReportApp/SelectChecksalesinvoice | its Java counterpart is not confirmed; rows differ |
| Vessel report | DashBoardApp/VESSELPLANINGDB | the Java rows lack the loading/off-vessel boarding officer fields the screen edits |
| Transport report, planning views | DashBoardApp/PLANINGSearchDB, PlanningApp/PLANINGSearch | tomorrow's list (`/api/planing/search`) not compared yet |
| Maintenance widget | DashboardApp/SelectStatusBO, LoadSupplierExpenseData, LoadExpenseData | no Java SelectStatusBO; Java `/supplier-expense` is an empty stub |
| Payment pending | DashBoardApp/SelectPendingPayment | different filter and row shape |
| Top customers | DashBoardApp/SelectTopCustomers | Java has `/api/ceo-dashboard/top-20/*`, not compared yet |

These need the latest .NET source (`DashBoardAppController` and its service) to port or confirm.

## Capabilities

### Modified Capabilities
- `api-integration`: the dashboard numbers use the shared Java `/api/dashboard`.

## Impact

`lib/core/dashboard`, `lib/features/auth/auth_injection.dart`, nine dashboard tabs' data code and
two views. The Java `/api/dashboard` endpoints need an employee session (they are not open to
driver tokens); none of these tabs is on the driver dashboard.
