## 1. Client

- [x] 1.1 `DashboardApi` (wrapper, refusals, each endpoint, `salesDesk`), registered in DI. Verify: `test/core/dashboard/dashboard_api_test.dart`.
- [x] 1.2 Sale-order and invoice desks (summary, employee rows), expense and forwarding reports, unreleased numbers. Verify: `test/features/dashboard/dashboard_repositories_test.dart`.
- [x] 1.3 The five sales desks on `salesDesk` and `employeeRules`; air freight dashboard on `/air-freight` with camelCase keys. Verify: analyzer, `dashboard_api_test.dart` (desk counts).
- [x] 1.4 Remove `SalesApi`, the dashboard methods of `ReportsApi` / `AuthApi` and their constants. Verify: analyzer 0 errors, no new warnings (208).
- [x] 1.5 Full test suite. Verify: only the inherited Bluetooth failure.

## 2. Open

- [ ] 2.1 On a test environment as an employee: sale-order desk (All / With / Without, month bars, employee dialog), invoice desk, expense and forwarding reports, unreleased (both), each sales desk with the employee switcher, air freight dashboard (dates, port and status filters, expired colouring).
- [x] 2.2 Backend findings 1-3 ported from `MalevaWeb-develop` (backend change `fix-dashboard-employee-sales`).
- [x] 2.3 Remaining tabs moved (maintenance, vessel report and customer dashboard vessels, transport lists, payment pending, top customers, invoice waiting bills) on backend change `port-dashboard-widgets`. Verify: `dashboard_api_test.dart`, `paymentview_repository_test.dart`, `payment_contract_test.dart`, analyzer 0 errors.
- [ ] 2.4 On a test environment: the tabs of 2.3, including the vessel report's boarding officer pickers and the payment pending filters.
