# Proposal

## Why
Scan items 8 and 9 — owner: "Add Completed" = **a Completed list**, with the **monthly report**. Plan step S4d.

## What Changes
- New Payable dashboard tab **Completed** (after Records; also on Today's Open buttons): month switcher (no future
  month), the month's total and count, approved vs waiting, **Monthly report (PDF)** (the web's printed Payment Completed
  report for the same days, opened in the phone's PDF viewer), totals per expense head with a Total row (tap a head to
  filter), search, and the list (paid to, number, date, head, status, amount); a row opens its voucher or pay bill page
  (Records detail, with files).
- Shared endpoints `POST /api/transaction-reports/payment-done` and `/payment-done/report`; REJECTED is left out by the
  server (backend change `payable-completed-list`).

## Capabilities
### New Capabilities
- `payable-completed-list`: the Completed tab and its monthly report.

## Impact
`payable_dashboard/completed/` (API, tab), `payable_tabs.dart`, dashboard UI, Today Open buttons; tests
`payable_completed_test.dart`. Existing packages (`path_provider`, `open_file`).
