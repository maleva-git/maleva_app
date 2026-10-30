# Tasks

## 1. Sign-in

- [x] 1.1 `dashboard_routes.dart`: role 1100 → `/dashboard/payable`; test in the dashboard-route test

## 2. Data

- [x] 2.1 `payable_dashboard/today/data/payable_today_api.dart` (pending, completed, checkFiles; expense via `DashboardApi`)
      and row models reading the Java fields; unit tests with a fake Dio for both answer shapes
- [x] 2.2 `payable_today_rules.dart`: sort, card totals, has-document; unit tests
- [x] 2.3 `payable_today_cubit.dart`: parallel load, per-section error, retry one, refresh all; cubit tests

## 3. Screen

- [x] 3.1 `today/view/payable_today_tab.dart` + widgets (cards, To pay list with Show all and bank sheet with
      Copy, Paid without a document, Spent, Open buttons) in existing colours; phone one column, tablet two;
      widget tests for a failing section and for Copy (`test/features/dashboard/payable_dashboard/payable_today_test.dart`, 21 tests with the route test)
- [x] 3.2 Dashboard: Today first, new tab order from one id list, Open buttons switch tabs; widget test

## 3b. PO & Vouchers

- [x] 3b.1 `PayableTab.spend` second; `view/payable_spend_tab.dart` over `CeoDashboardCubit` + `CeoExpensesTab(spendOnly)`
- [x] 3b.2 CEO code: `spendOnly` on `CeoExpensesTab`, `CeoPeriodBar`, `CeoTabScroll`; `payableOnly` on `CeoOwedPanel`;
      `CeoDashboardCubit.choosePeriod` / `clearSpend`; CEO screens unchanged when the switch is off (CEO tests pass)
- [x] 3b.3 `test/features/dashboard/payable_dashboard/payable_spend_tab_test.dart` (no overview call, views, period, refusal)

## 4. Check

- [x] 4.1 `flutter analyze lib/features/dashboard/payable_dashboard lib/features/auth`;
      `flutter test test/features/dashboard/payable_dashboard`
- [ ] 4.2 Owner on phone as role 1100: sign-in opens Payable; numbers match the web payable desk for the same day
