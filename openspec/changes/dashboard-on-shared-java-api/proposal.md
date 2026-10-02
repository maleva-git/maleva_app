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

## Also moved (second step, same day)

After the .NET source (`MalevaWeb-develop`) was found, the remaining tabs were moved; backend
change `port-dashboard-widgets` added or corrected their APIs:

| Screen part | Was (.NET) | Now (Java) |
|---|---|---|
| Maintenance widget | DashboardApp/SelectStatusBO, LoadSupplierExpenseData, LoadExpenseData | /api/dashboard/maintenance-status, /supplier-expense, /running-expenses |
| Vessel report, customer dashboard vessels | DashBoardApp/VESSELPLANINGDB | /api/dashboard/vessel-planning (camelCase; screens read the Java fields) |
| Transport list (three screens) | DashBoardApp/PLANINGSearchDB, PlanningApp/PLANINGSearch | /api/dashboard/planing-search, /api/planing/search |
| Payment pending (tab and customer dashboard) | DashBoardApp/SelectPendingPayment | /api/pending-payments/board (model factories read the Java bill and vendor fields) |
| Top customers | DashBoardApp/SelectTopCustomers (raw http) | /api/dashboard/top-customers |
| Invoice waiting bills | MasterReportApp/SelectChecksalesinvoice | /api/sale-orders/check-invoice (screen reads the Java fields) |

Still .NET on these screens: the vessel report's date and boarding officer saves (sale order
update), and `vesselplanningdetails`' network read (it expected a `Data2` this endpoint never
answered, so it always came back empty; left as it was).

## Capabilities

### Modified Capabilities
- `api-integration`: the dashboard numbers use the shared Java `/api/dashboard`.

## Impact

`lib/core/dashboard`, `lib/features/auth/auth_injection.dart`, nine dashboard tabs' data code and
two views. The Java `/api/dashboard` endpoints need an employee session (they are not open to
driver tokens); none of these tabs is on the driver dashboard.
