## 1. Client

- [x] 1.1 `DashboardApi` (wrapper, refusals, each endpoint, `salesDesk`), registered in DI. Verify: `test/core/dashboard/dashboard_api_test.dart`.
- [x] 1.2 Sale-order and invoice desks (summary, employee rows), expense and forwarding reports, unreleased numbers. Verify: `test/features/dashboard/dashboard_repositories_test.dart`.
- [x] 1.3 The five sales desks on `salesDesk` and `employeeRules`; air freight dashboard on `/air-freight` with camelCase keys. Verify: analyzer, `dashboard_api_test.dart` (desk counts).
- [x] 1.4 Remove `SalesApi`, the dashboard methods of `ReportsApi` / `AuthApi` and their constants. Verify: analyzer 0 errors, no new warnings (208).
- [x] 1.5 Full test suite. Verify: only the inherited Bluetooth failure.

## 2. Open

- [ ] 2.1 On a test environment as an employee: sale-order desk (All / With / Without, month bars, employee dialog), invoice desk, expense and forwarding reports, unreleased (both), each sales desk with the employee switcher, air freight dashboard (dates, port and status filters, expired colouring).
- [x] 2.2 Backend findings 1-3 ported from `MalevaWeb-develop` (backend change `fix-dashboard-employee-sales`).
- [ ] 2.3 From `MalevaWeb-develop` `DashBoardServices`, port or confirm SelectStatusBO, LoadSupplierExpenseData, LoadExpenseData, SelectPendingPayment, SelectTopCustomers, VESSELPLANINGDB, PLANINGSearchDB in the backend, then move the remaining tabs listed in the proposal.
