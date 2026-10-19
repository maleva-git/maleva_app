# Proposal

## Why

The owner runs the whole company and asked (2026-10-16) for one analytical CEO dashboard on web and app:
revenue, expenses, cash, operations and people for a period, where each number with a list behind it opens
that list (the web shows it on hover; a phone has no hover, so a tap). Only the CEO, role 100 with
permission id 1, may open it.

## What Changes

- New screen `/dashboard/ceo` (`features/dashboard/ceo_dashboard/`): gradient header with greeting,
  period switch (This month / Last month / This quarter / This year), range, update time, Refresh and six
  KPI tiles (Revenue with change against the previous period, Invoiced, Expenses, Receivable, Payable,
  Open jobs); Revenue (12-month sale order and invoice bars, top 5 customers), Expenses (purchase order
  categories as a donut and ranked list, running costs), Cash (receivable and payable ageing, paid out),
  Operations (open sale orders and job orders by status, open incidents, unreleased forwarding, trucks)
  and People (active staff, on leave today, top 5 sales). Phone one column, tablet (>= 600) two.
- A tap on a category, status, customer, sales employee, open incidents or on-leave-today opens a
  draggable bottom sheet with the rows behind it.
- `dashboardRouteFor` takes the permission id: role 100 with permission 1 opens `/dashboard/ceo`; other
  role 100 users keep `/dashboard/admin`. Manual login (`login_page.dart`) and session restore
  (`splashscreen.dart`) pass it (`AppPreferences.getPermissionId()`, `MobileSession.permissionId`).
- The CEO keeps the admin dashboard: a button in the CEO app bar opens it; bell and logout as there.
- A server 403 shows "This dashboard is for the CEO only" with a button to the admin dashboard.
- Update 2026-10-16 (owner, as the web CEO page): a **Sale orders** panel with Today, Yesterday, This week
  (Sunday to Saturday) and This month cards (count and amount, tap for the sale orders); a **Top 20
  customers** list for the chosen period with "Show all" (tap a customer for their sale orders); a tap on
  a **revenue month bar** (or the month strip under it) opens every customer of that whole month. They
  read the backend's new details kinds `SALE_ORDERS` and `CUSTOMERS`; period rules copied from the web
  `model/salePeriods.ts`.
- Update 2026-10-17 (owner: "today 66 — how many each employee opened"): a period card opens a sale orders
  sheet with a "By employee | All sale orders" switch, starting on By employee (rank, name, bar, order
  count, amount, from `SALE_ORDER_EMPLOYEES`); a tap on an employee shows only their orders
  (`SALE_ORDERS` with key = employee id, `0` = no employee) in the same sheet with Back. As the web
  `SaleOrderLists.tsx` / `SaleOrdersPanel.tsx`.

## API

The shared Java endpoints written in parallel in `maleva-backend` (change `ceo-analytics-dashboard`,
`contract.md`): `GET /api/ceo-dashboard/analytics/overview` and `/details`. The app reads the contract's
JSON as it is (`{IsSuccess, StatusCode, Message, Data1}`, camelCase fields, `unavailable` parts). No mobile-only endpoint, no
backend change for the app. Those endpoints are new aggregates for this request (no .NET source); their
migration notes live in the backend change.

## Capabilities

### New Capabilities

- `ceo-dashboard`: the CEO analytics dashboard in the app - who opens it, what it shows, the lists behind
  the numbers, the 403 state.

### Modified Capabilities

None (the dashboard routing rule is recorded in the new capability).

## Impact

`features/auth/presentation/dashboard_routes.dart` and its two callers, `core/router/app_router.dart`,
`core/di/injection.dart`, new `features/dashboard/ceo_dashboard/`; reuses the Overview tab's widgets
(`overview_widgets.dart`) unchanged. Tests under `test/features/dashboard/ceo_dashboard/` and
`test/features/auth/`. No new package (fl_chart ^0.66 already used).

## Update 2026-10-17: the app CEO screen as tabs, with the Super Admin tabs

Owner: "in app this dashboard same as web, more reports, better design, and all the Super Admin navigation".

- `/dashboard/ceo` is now a tab screen. CEO tabs as the web CEO page: Overview (the old page), Sale Orders,
  Invoices, Expenses, Revenue, Customers, Cash, Operations, People. Then every Super Admin tab
  (`adminTabs(superAdmin: true)`, the Super Admin Overview shown as "Admin Overview"), the Super Admin side
  menu (`Menulist`), the ship button, and More (Admin dashboard, Bluetooth printer, Test print, Log out).
  "All reports" (grid button) lists every tab with a search.
- Sale Orders / Invoices (`CeoDocTab`): Today / Yesterday / This week / This month cards (choose the days),
  the With / Without invoice filter (sale orders), By employee, By customer, All, 12 months; a row opens its
  own list (an employee's or customer's documents, a month's customers).
- Expenses (`CeoExpensesTab`): Money flow from `/spend` (Purchase Order → Bill → Paid out → Still owed today,
  paid grouped by Payment (pay bill) / Payment Voucher / Cash bill, the checks, "How is this counted?"),
  By category, By supplier, By truck, 12 months.
- Shared Java API only (no backend change): `/details` with `invoice` and `customer`, and `/spend`; the app reads
  the Java fields as they are. `AdminTabProviders` (the admin tabs' blocs) is shared by both dashboards; each
  bloc is still created only when its tab first reads it.
- Tests: `ceo_tabs_test.dart` (tabs, filter and customer parameters, money flow, All reports, 360 wide), the API
  test for `invoice` / `customer` / `spend`; the admin button test opens More first.

## Update 2026-10-17: Cash tab lists who owes us and whom we owe
`CeoOwedPanel` under the cash panel: "Customers who owe us" / "Whom we owe" (as of today), most owed first with the
age in colour; a tap opens the invoices or bills (`CeoDrill` with `byTitle` for a payable party). Test in
`ceo_tabs_test.dart`.

## Update 2026-10-17: Money Received tab
`CeoReceivedTab` after Cash: This month / Last month / Chosen period, the hero (total, receipts, customers, change
against the same days before), How it came in (Payment By, tap to filter), Day by day bars (tap a day), Who paid
(tap for the receipts) and All receipts. `CeoAnalyticsApi.received`, `CeoDashboardCubit.loadReceived`. Test in
`ceo_tabs_test.dart`.

## Update 2026-10-17: Money Received in RM with each currency
Totals, Payment By and Who paid are in RM (foreign receipts at their own rate, from the backend). A "By currency" card
(shown when money came in another currency) lists each currency in its own money with its RM value, as on the
receipts and the customer statement. Foreign customers and receipts show their own amount in the subtitle.

## Update 2026-10-17: Cash tab receivable in RM with each currency
Receivable figures (box, ageing, "Customers who owe us") are RM from the backend. When some receivable is foreign, the
cash card lists "Receivable by currency": each currency in its own money, customers and invoices, today's rate and the
RM value. Foreign customers and invoices show their own amount in the subtitle.

## Update 2026-10-17: Expenses Fuel view
A "Fuel" view in the Expenses tab: fuel from the fuel entries only, amount = PAmount (litres × pump price). It shows
the total, fills and trucks, litres, the average pump price, the period before, and a note on how it is counted;
per truck (tap or click for its entries) and every fuel entry (`100.00 L x RM 3.3500 · driver`).

## Update 2026-10-17: foreign amount under the RM amount
Detail rows read `foreignAmount`; Who paid, Customers who owe us, a customer's invoices and the receipt lists show it in
blue under the RM amount (web `RmAmount`, app `CeoForeignAmount`).

## Update 2026-10-17 (later): Fuel shows the saved PAmount only
Litres, the average pump price and the "litres × price" text are removed; the Fuel view shows each Fuel Entry's
PAmount as saved, fills, trucks and the period before.

## Update 2026-10-17: fewer tabs
Owner: no Revenue, Customers, Operations, People, Payments or Top 20 customers. CEO tabs: Overview, Sale Orders,
Invoices, Expenses, Cash, Money Received; the Overview keeps the header figures, Sale orders, Expenses and Cash. The
Super Admin tabs `PaymentView` and `TopCustomers` are left out of the CEO screen (`ceoHiddenAdminTabs`); the admin
dashboard keeps them. Unused sections and the revenue chart are removed.

## Update 2026-10-17: no figure tiles
The six KPI tiles under the Overview header are removed (the header keeps the title, period switch, days and Refresh).

## Update 2026-10-19: the app CEO screen as the web CEO page
Owner: the same tabs as the web, a good design, and no today pickups or vessel planning in the app. Tabs: Sale Orders,
Invoices, Expenses, Cash, Money Received, then the web's Super Admin reports Forwarding, Performance, Driver Salary.
The Overview tab and the long list of admin tabs are removed (the side menu stays). The three reports read the same
shared Java endpoints the web calls (`CeoSuperReportsApi`), as they answer:
- Forwarding: `GET /api/dashboard/forwarding/{comId}?fromDate&toDate` for the CEO period; per K1/K2/K3/K8 `kNCount`;
  released = `kNWithRelease` (an exit reference is set), not released = `kNRelease` (none yet), as the SQL counts them.
  Note: the web Super Admin Forwarding tab shows `kNRelease` as "Released", the other way round (a web defect, not
  changed here).
- Performance: `GET /api/dashboard/employee-sales-current-month/{comId}?baseDate` (this month / last month).
- Driver Salary: `POST /api/rti/driver-report` `{comid, driverId: 0, truckId: 0, fromDate, toDate}` (`Data1`); a 404
  "No records found" is an empty list; grouped per driver as the web.
Removed as unused: the Overview (`CeoDashboardView`, header), `ceo_sales_sections.dart`, `CeoSaleOrdersSheet` (its row
count helper is `ceoJobsOf`). Tests: `ceo_tabs_test.dart`, `ceo_dashboard_page_test.dart`, API tests.

## Update 2026-10-19: Go to, and Mail Monitor in one screen
Owner: navigation from the CEO screen to Truck Planning, Truck Location, Vessel Planning, the Incident Report and the
Mail Monitor, with the mailboxes and the response report (and its AI auto summary) in one screen. A "Go to" button
in the app bar opens a sheet with the five places (the web Super Admin quick access); each opens the app's own
screen as the side menu does (`PlansPage`, `TruckLocationRoutes.board`, `VesselPlanningWebTab` with the menu rights,
`IrReportTab`). Mail Monitor opens `CeoMailScreen`: two tabs, Mailboxes (`MailMonitorTab`, `/mail-monitor`) and
Response report (`MailResponseTab`, `/mail-monitor/response-report`, with the AI summary). No API change. Tests:
`ceo_go_to_test.dart`, the page test.

## Update 2026-10-19 (later): quick access buttons as on the web
Owner: the buttons should be on the screen, as the web shows them. The "Go to" sheet is replaced by `CeoQuickAccess`, a
row of rounded buttons under the app bar (coloured icon, name, red LIVE badge on Truck Location and Mail Monitor),
scrolling sideways on a narrow phone; each opens the same screen as before.

## Update 2026-10-19: Home dashboard on the Super Admin screen
The Super Admin (admin) dashboard keeps everything it has. For the CEO only (role 100 with permission 1, `isCeo`), its
app bar adds a Home dashboard button (`CeoHomeButton`) that opens `/dashboard/ceo`. Other role 100 users see no change.

## Update 2026-10-19 (later): no Home dashboard button in the app
Owner: the Home dashboard button belongs on the web Super Admin dashboard only. The app's Super Admin screen is back
as it was (`CeoHomeButton` removed).
