# Design

## Context

- `dashboard_routes.dart` maps roles to dashboards; 900 goes to `/dashboard/payable`, 1100 is missing
  (falls to `/unauthorized`). Web maps 1100 to `/dashboard/payable` (`maleva-front-end/src/config/dashboardRoutes.ts`).
- `payable_dashboard.dart` / `payable_dashboard_ui.dart` hold a 10-tab controller with fleet tabs first and a
  `PayableTabBloc` that only tracks the index.
- The web desk (`maleva-front-end/src/features/payable-dashboard/`) reads pending, completed, expense and
  `checkFiles`; its rules (due state from `DueReportId`, document check by `DetailedId` folder) are copied.
- Payable tabs already in the app: `PaymentPendingPage` (pending payments board), `BillOrderScreen`,
  `PettyCashPage`, `ExpenseReportPage`, `DriverSalaryWidget`.

## Goals / Non-Goals

**Goals:** role 1100 can sign in to a useful desk; one phone-first Today tab; reuse existing tabs and colours.

**Non-Goals:** no backend change (the endpoints' `@PermitAll` + company-in-URL access is a backend item for
later, noted below); no paying or uploading from the Today tab (the existing tabs do that); no push, alarm or
notification; no tab removed.

## Decisions

- **Own small API class** `today/data/payable_today_api.dart` over `JavaApiClient.dio`, reading the Java fields as
  they arrive (PascalCase from the DTOs' `@JsonProperty`), payload from `data`/`Data1`/`Data` like `DashboardApi`.
  `DashboardApi.expenses` is reused for the expense call. `checkFiles` answers `{ok, data:[ids]}`.
- **Company from the session** (`AppPreferences` company id), same as the other dashboard calls.
- **One `PayableTodayCubit`** with a section-per-area state (loading / data / error), `Future.wait` over guarded
  calls, so one failure never blocks the rest (same pattern as the admin Overview tab).
- **Pure rules in one file** (`payable_today_rules.dart`): sort order, card totals, has-document — unit tested
  without Flutter.
- **Tab order from one list** of tab ids in the UI, so the Open buttons find their index without hard-coded
  numbers. Fleet tabs stay, moved to the end, so Accounts (900) users lose nothing.
- **Bank account** shown only in the row's sheet, not in the list (less on screen, still one tap away).

## Risks / Trade-offs

- The dashboard endpoints are `@PermitAll` and take the company from the URL. The app sends the signed-in
  company; the server does not check it. This is an existing backend gap (web has it too), out of scope here;
  to raise as a backend item (CompanyScope like fleet D0).
- `checkFiles` lists files in a folder; a large folder is one call per refresh, as on the web.
