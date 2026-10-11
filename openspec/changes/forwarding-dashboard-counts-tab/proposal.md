# Proposal

## Why

The web Forwarding dashboard (`/dashboard/forwarding`) shows the forwarding counters (Today / Yesterday /
Week / Month and K1/K2/K3/K8 in a date range) beside the two unreleased grids, all counted over
`SaleOrderForwarding` since 2026-10-09. The app's Forwarding dashboard had only the two unreleased tabs,
VSL, IR Report and leave; the counters tab existed but sat on the admin dashboard alone. The owner asked
(2026-10-09) for the app's Forwarding dashboard, tablet and phone, to show the same.

## What Changes

- The Forwarding dashboard gets a first tab **FW Report**, the shared `ForwardingReportPage`
  (tablet: two columns, phone: one column), reading the same Java `GET /api/dashboard/forwarding/{comId}`
  as the web. Tab count 5 to 6.
- No API, model or backend change: the three dashboard endpoints already answer from the forwarding rows
  (backend change `forwarding-dashboard-from-forwarding-rows`), so the existing K-1,2,3 and K8 tabs show
  the row-based lists without a change.

## Impact

`forwarding_dashboard_ui.dart`, `forwarding_dashboard.dart`. Shared Java API, no mobile-only endpoint.
