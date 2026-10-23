## Why

Sale order today / month / year numbers are the CEO's only (owner, 2026-10-22). Server:
`maleva-backend/openspec/changes/ceo-only-sale-order-numbers`.

## What Changes

- `signedInIsCeo()` in `auth/presentation/dashboard_routes.dart`.
- Admin dashboard: the SO tab only for the CEO (`adminTabs(ceo:)`); the Overview tab has no
  "Sale orders today" tile, SO button or Sale Order switch, and never loads them, for others.
- Sub-admin and receivable dashboards: SO tab removed (never the CEO's); maintenance: unused SO provider removed.
- Sales desks (air freight, transport, sub-admin sales): this month's Total / Billed / Unbilled cards
  for the CEO only; "Without invoice" and the status list stay.
- Tests: `admin_overview_test.dart` (CEO and non-CEO tab lists, cubit, Overview widget).
