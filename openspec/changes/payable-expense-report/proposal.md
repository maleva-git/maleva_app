# Proposal

## Why
The payable team's list (scan item 4) asks for an expense report like their sheet: each expense with how many and how
much, and a Total (Fuel 1 RM 10,000 · Vendor 4 RM 5,052.91 · Total). The old Expenses tab showed whole ringgit, no
total, and a tap only reloaded. The owner chose (2026-10-30) to leave REJECTED out (backend change
`payable-expense-report` in maleva-backend). Plan step S2 (`docs/payable/payable-app-plan.md`).

## What Changes
- Payable dashboard **Expenses** tab is a new screen (`payable_dashboard/expenses/expense_report_tab.dart`):
  period chips (This month, Last month, Dates…); a total card with approved (green) and waiting (amber); a red line
  "Left out: N rejected (RM x)" when the server says so; a table **Expense · No. · Amount**, biggest first, each with
  its share and approved/waiting bar, and a **Total** row; tapping an expense opens its payment vouchers and pay bills
  of the period (rejected left out), each opening the record (Records detail page).
- Reads the new `ExpApproved`, `RejectedCount`, `RejectedAmount`; an older server reads as 0 (no note, all waiting).
- The admin dashboard keeps its own expense tab (its numbers follow the server fix).

## Capabilities
### New Capabilities
- `payable-expense-report`: the Payable dashboard's expense report.

## Impact
`payable_dashboard/expenses/`, `today/data/payable_today_models.dart` (ExpenseHead.approved, ExpenseSummary.rejected),
`records` (PayableRecord.head), `payable_dashboard_ui.dart`; test `payable_expense_report_test.dart`. Shared API
`GET /api/dashboard/expense/{comId}` and the Records lists; no new package.
