# Tasks

## 1. Routing

- [x] 1.1 `dashboardRouteFor(isDriver, roleId, permissionId)`: role 100 + permission 1 -> `/dashboard/ceo`;
      callers `login_page.dart` (AppPreferences.getPermissionId) and `splashscreen.dart`
      (MobileSession.permissionId); tests in `dashboard_routes_test.dart` and `splash_restore_test.dart`
- [x] 1.2 Route `/dashboard/ceo` in `app_router.dart`; `CeoAnalyticsApi` registered in `injection.dart`

## 2. Data

- [x] 2.1 `data/ceo_analytics_api.dart` (overview, details; Data / Data1 / data; ApiFailure with status),
      `data/ceo_analytics_models.dart` (fromJava, missing fields 0, missing sections null),
      `data/ceo_period.dart`; tests from a contract-shaped sample, missing fields, 403
- [x] 2.2 `bloc/ceo_dashboard_cubit.dart`: load per period, reload, retry, 403 flag, details cached per
      kind + key + period; tests with a mocked API

## 3. Screen

- [x] 3.1 Header with period switch and six KPI tiles; Revenue, Expenses, Cash, Operations, People panels;
      phone one column, tablet two; pull-to-refresh; per-section error with Retry
- [x] 3.2 Details bottom sheet (draggable, loading, empty, error with Retry, "Showing N of M")
- [x] 3.3 App bar: bell, admin dashboard button, logout; 403 CEO-only page
- [x] 3.4 Widget tests at 390x2400, 360x2400 and 800x2000 (no overflow, KPI numbers, category tap opens
      the sheet with PO rows, 403 state, failed load Retry, missing section, period switch)
- [x] 3.5 `flutter analyze` on the changed folders; `flutter test test/features/dashboard test/features/auth`

## 4. Sale orders and customers (update 2026-10-16)

- [x] 4.1 `CeoSalePeriod.of` and `ceoMonthRange` in `data/ceo_period.dart` (web `salePeriods.ts`);
      `CeoDetailKind.saleOrders` / `customers`; tests in `ceo_sale_periods_test.dart` (week edges, month and
      year crossings, leap February, the two kinds' rows)
- [x] 4.2 Cubit and sheet take an optional range; a customers sheet row opens `TOP_CUSTOMER` for the same days;
      cubit test for a list kept apart from the chosen period
- [x] 4.3 `view/ceo_sales_sections.dart`: Sale orders panel (four cards, tap opens `SALE_ORDERS` for that
      period) and Top 20 customers (Show all, tap opens `TOP_CUSTOMER`); placed after Revenue (tablet: left
      column)
- [x] 4.4 Revenue chart: a tap on a month bar or the month strip opens `CUSTOMERS` for that whole month
- [x] 4.5 Widget tests: cards ask their four ranges and open the sheet, Top 20 / Show all / customer tap,
      month bar tap (Nov 2025) and strip tap, 360 wide with long names and big amounts;
      `flutter analyze` and `flutter test test/features/dashboard/ceo_dashboard` pass (44 tests)

## 5. Sale orders by employee (update 2026-10-17)

- [x] 5.1 `CeoDetailKind.saleOrderEmployees`; `SALE_ORDERS` with an employee key (`0` = no employee)
- [x] 5.2 `CeoSaleOrdersSheet`: By employee (default) | All sale orders switch; employee tap shows their
      orders in the same sheet with "All employees" back; the period cards open it
- [x] 5.3 Tests: employee rows model and order count, API sends `key=7` / `key=0` and no key for
      `SALE_ORDER_EMPLOYEES`, widget tests (sheet starts on By employee, All sale orders, employee tap
      asks key 7, Back, NO EMPLOYEE asks key 0, 360 wide); analyze clean, 47 tests pass

## 6. Owner check

- [ ] 6.1 After the backend endpoints are deployed: sign in as the CEO (role 100, permission 1) on phone and
      tablet; numbers match the web CEO dashboard for the same period; taps open the right lists; another
      role 100 user still opens the admin dashboard; the Sale orders cards
      match the Super Admin Sale Order tiles; a month's customers add up to its bar;
      an employee's line equals their own sale orders list

## App tabs (2026-10-17)
- [x] Tab screen: CEO tabs, then the Super Admin tabs, side menu, All reports
- [x] Sale Orders and Invoices tabs (periods, invoice filter, by employee / customer, all, 12 months)
- [x] Expenses tab with the money flow, checks and the explanation
- [x] `invoice` / `customer` on details, `spend` in the API and cubit
- [x] Tests and analyze clean; device check by the owner
