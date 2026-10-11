# Design

## Context

`admin_dashboard.dart` builds the tab controller (32 tabs, plus Mailbox Monitor for role 100) and
`admin_dashboard_ui.dart` lists the tabs and pages. The data each area needs already has a client:
`DashboardApi.sales` / `planningJobs` / `vesselPlanning`, `JobOrderApi.list`, `MailMonitorApi.mailboxes`,
`IrRepository.search`, `TruckLocationRepository.week`, all registered in `sl`. The side menu opens
`PlansPage`, `VesselPlanningWebTab(page* flags)` and `TruckLocationRoutes.board()` from
`AppGlobals.objMenuMaster` entries.

## Goals / Non-Goals

**Goals:** one glanceable first tab for role 100; reuse existing clients and screens; existing colours.

**Non-Goals:** no new endpoint or aggregate API; no change to the other tabs, their data or the menu; no
charts library; no auto-refresh timer (the Mailbox Monitor tab keeps its own).

## Decisions

- **Role gate reuses `mailMonitorAllowed(roleId)`** (role 100), so Overview and Mailbox Monitor appear
  together. Alternative: show to Admin too, hiding the mail card - rejected, the owner asked for the Super
  Admin.
- **Tab index shift.** Overview is index 0 when shown; the SO/JO/Invoice/Mail/IR indexes move by one. The
  Overview's buttons find their target index from the same tab list the UI builds (a small `AdminTabs`
  list of IDs), so no number is hard-coded twice. No other code opens these tabs by number (checked).
- **One `AdminOverviewCubit` with a section-per-area state** (`OverviewSection<T>{loading, data, error}`),
  loading the seven areas in parallel with `Future.wait` over guarded calls, so one failure never blocks the
  rest. Alternative: read the existing `SalesOrderBloc` / `JobOrdersBloc` from the dashboard - rejected,
  their state follows the SO/JO tabs' own filters and would change the Overview's numbers.
- **`AdminOverviewRepository`** wraps the existing clients and turns their answers into small summary
  values (`SalesSummary`, `JobOrderSummary`, `MailSummary`, `IrSummary`, `PlanningSummary`,
  `VesselSummary`, `TruckLocationSummary`), reading Java fields as they are. Counting rules: JO "open" =
  status name not Completed/Cancelled (as the JO tab colours them); IR = `openOnly` filter, last 30 days;
  vessel = `vesselPlanning(today .. today+7, etaType 0)` row count; truck planning = `planningJobs(today)`;
  truck location = rows not SOLD, today's cell non-empty, status WORKSHOP.
- **Screen buttons from the menu**: look the entry up in `AppGlobals.objMenuMaster` by `FormText`
  ("Vessel Planning", "Planning", "Truck Location"); hidden when absent; Vessel Planning gets the entry's
  PageView/Add/Edit/Delete flags as the menu does.
- **Look: the colours the dashboard tabs already use, no new colour.** Header card: gradient
  `AppTokens.brandGradientStart` to `brandGradientEnd` (as `AppColors.primaryGradient`) with white text and
  the four number tiles on it (white at 15%). Quick buttons and section cards: white on `surfacePage`,
  border `surfaceBorder`, icon circle `brandLight` with `brandGradientStart` icon, titles `brandDark`.
  Planning cards: `brandLight` with a `brandMid` 30% border (as the Petty Cash tab). Status pills:
  `statusSuccess` (OK), `statusWarning` (warning / open), `Palette.rose` (overdue / workshop) on their
  light tints. `AppTypography` for text; radius 14-16 as the other tabs. Mirrors the reference mock-ups'
  structure (header, KPI row, sections, status pills) without their colours.

## Risks / Trade-offs

- [Seven requests when the tab opens] → only when role 100 opens the dashboard; each is an endpoint the
  app already calls; no timer.
- [JO "open" rule is by status name] → names come from `/api/job-orders/statuses`; the card lists every
  status count so nothing is hidden.
- [Tab index shift for role 100] → indexes come from one list; widget test checks the order.

## Migration Plan

App-only. Roll back by removing the Overview tab entry and the controller's +1.
