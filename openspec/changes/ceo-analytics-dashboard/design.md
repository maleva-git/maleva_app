# Design

## Context

The Super Admin Overview tab (`admin_dashboard/overview/`) already has the panel, tile, switch and chart
widgets in the app's colours. Every Java client unwraps its own wrapper. The new endpoints answer
`ApiResponse` with the payload in `Data1` (`Data` null; contract changed 2026-10-16).

## Decisions

- **One overview call, sections parsed apart.** The cubit loads the overview for the chosen period in one
  call. Each section (`revenue`, `cash`, `expenses`, `operations`, `people`) is parsed on its own and is
  null when the answer lacks it, so the screen shows "did not load" with Retry on that section only; a
  failed load shows the error with Retry in every section (and the CEO-only page on 403). A failed reload
  keeps the shown numbers with a Retry line in the header.
- **Own unwrap in `CeoAnalyticsApi`:** `Data1`, else `Data`, else `data`; `IsSuccess`/`success` false or
  an HTTP error becomes `ApiFailure` with the status code (Dio errors via `JavaResponse.fromDio`).
  `JavaResponse` is left unchanged for its other callers.
- **`unavailable` parts** (e.g. `cash.payable`) come as zeros; the section shows a muted "Some figures
  are unavailable: payable" note so a 0 is not read as real.
- **Contract details followed as sent:** sale order status key `0` is ENQUIRY; unreleased forwarding shown as
  `count + k8Count` with both parts; leave rows (`LR-<id>`, EMPLOYEE/DRIVER) show no amount; incident
  rows use `IR-<id>`; a row date may be null.
- **Periods computed on the device** (`CeoPeriod.range`), sent as `fromDate`/`toDate`; the server works
  out the previous period.
- **Details on demand, cached per kind + key + period** in the cubit; Refresh clears them, a failed list
  is asked again when reopened or on Retry.
- **Tap instead of hover:** status/category rows, top customers/sales, the donut slices, Open incidents and
  On leave today open a `DraggableScrollableSheet`.
- **Reuse, no move:** `AccentPanel`, `PanelAccent`, `SegmentSwitch`, `KpiTile`, `MiniStat`, `StackedBar`,
  `LetterAvatar`, `DateBlock`, `AreaBody`/`AreaState` are imported from the Overview; CEO-only pieces
  (share bars, change chip, money split bar, grid) live in `ceo_dashboard/view/ceo_widgets.dart`, so the
  Overview tab is untouched.
- **Sale orders and customers (update 2026-10-16)** follow the web (`SaleOrdersPanel.tsx`,
  `CustomersList.tsx`, `RevenueTab.tsx`, `model/salePeriods.ts`). `CeoSalePeriod.of(today)` gives Today,
  Yesterday, the week Sunday to Saturday (`weekday % 7` days back = JS `getDay()`) and the calendar month
  to its last day; `ceoMonthRange('yyyy-MM')` gives a revenue month's whole month (the web's
  `monthRange`, not month to date). The web's fifth "Chosen period" card is left out on the phone: the
  header KPI already shows the chosen period's sale orders.
- **Details for their own days:** `loadDetails` / `detailsOf` / `showCeoDetails` take an optional range
  (default the chosen period), still cached per kind + key + range. The cards and the customers list ask
  their list after the first frame when it was never asked (so Refresh, which clears the cache, reloads
  them); a failed one shows "Could not load" / Retry and is not retried in a loop.
- **Customers rows** (`CUSTOMERS`): `reference` is the rank (shown in a badge, `#1` in the sheet),
  `title` the customer, `subtitle` "N jobs", `date` null; the list shows the first 20 and "Show all N
  customers" (up to the server's 500); "Showing N of M" when `truncated`. A row opens `TOP_CUSTOMER` with
  the row id for the same days, also from inside a month's customers sheet.
- **Sale orders by employee (update 2026-10-17):** `showCeoSaleOrders` opens `CeoSaleOrdersSheet`
  (in `ceo_details_sheet.dart`, sharing the frame, header, row tile and loading / error / empty body with
  the details sheet). The header keeps the period's count and total (`SALE_ORDERS` without key, already
  loaded by the card). By employee reads `SALE_ORDER_EMPLOYEES`; the order count is the leading number
  of `subtitle` ("40 jobs"), the bar is against the busiest employee. An employee is opened inside the
  same sheet (no second sheet) with `SALE_ORDERS` key = `id`; id 0 ("NO EMPLOYEE") is sent as `key=0`,
  which `CeoAnalyticsApi` keeps (it drops only an empty key).
- **Grid without intrinsic sizing** (charts inside), tablet two independent columns.

## Risks

- The backend is written in parallel; the app follows `contract.md` (re-read 2026-10-16). Field drift
  would show as zeros, not a crash.
- The admin dashboard opened from the CEO screen is pushed, so Back returns to the CEO dashboard.
