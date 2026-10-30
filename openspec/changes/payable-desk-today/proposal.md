# Proposal

## Why

A Payable user (role 1100) cannot use the app today: the app has no dashboard for role 1100, so sign-in
opens the "unauthorized" page. The Payable dashboard that exists (opened by Accounts, role 900) starts
with fuel, speeding and engine-hour tabs; nothing on it says what must be paid today. The owner asked
(2026-10-30) for a better Payable dashboard on the phone, with what a payable person really needs.

The web already has this desk (`/dashboard/payable`, role 1100): what is overdue, what is due soon, what was
paid this month, and which payments have no document filed. The app will show the same thing, from the same
Java endpoints.

## What Changes

- Role 1100 (PAYABLE) opens the Payable dashboard after sign-in and on session restore (was: unauthorized).
  Role 900 (Accounts) keeps opening it too.
- The Payable dashboard gets a new first tab **Today**, made for the phone:
  - **Four number cards**: Overdue (count + RM, red), Due in the next 5 days (count + RM, amber),
    Paid this month (count + RM), Paid without a document (count, red).
  - **To pay**: the unpaid list, overdue first, then due soon, then the rest by due date. Each row: name,
    RM, due date, a chip. Tap opens a sheet with the bank name and account number and a Copy button
    (to pay in online banking). 10 rows first, "Show all" for the rest.
  - **Paid without a document**: this month's payments with no document filed (date, number, paid to, RM),
    so the user knows which receipts to file.
  - **Spent**: today / yesterday / this week / this month totals and the top 5 expense heads of the month.
  - **Open**: buttons that switch to the Payments, Bills, Petty Cash, Expenses and Driver Salary tabs.
  - Pull to refresh; each section loads on its own and shows Retry on its own if it fails.
- The tabs are re-ordered so payable work comes first: Today, PO & Vouchers, Payments, Bills, Petty Cash, Expenses,
  Driver Salary, IR Report, Emp Leave, then the fleet tabs (Fuel Filling, Speeding, Engine Hours, Fuel,
  Driver, Truck) unchanged at the end. **No tab is removed.**
- **PO & Vouchers tab** (added 2026-10-30, owner: "payment voucher expense and purchase order expense"): the CEO
  dashboard's Expenses screens in spend-only mode, from `/api/ceo-dashboard/analytics/spend` and its spend lists,
  which the backend change `payable-spend-access` opens to roles 900 and 1100. Views: Money flow (PO → Bill → Paid
  by voucher type / supplier payment / cash bill → Still owed, plus the "entered twice" checks), PO by supplier, PO by
  truck, 12 months, Whom we owe. Counted the owner's way (2026-10-17): each payment once, REJECTED never paid. The web
  Payment Completed list was not used because it counts REJECTED vouchers and can count a PO twice. Period: This
  month / Last month / This quarter / This year. Never asks the CEO overview.
- No database change. The only backend change is access (`maleva-backend` change `payable-spend-access`); deploy it
  before this app version. No push or alarm (the web's desktop pop-ups are not copied; the red
  cards are the reminder).

## Capabilities

### New Capabilities

- `payable-desk`: the Payable dashboard's Today tab and its tab order - what it shows, how rows are sorted
  and coloured, where its buttons go.

### Modified Capabilities

- `navigation-permissions`: the dashboard chosen after sign-in now maps role 1100 to the Payable dashboard.

## Impact

`lib/features/auth/presentation/dashboard_routes.dart` (role 1100), `lib/features/dashboard/payable_dashboard/`
(dashboard, UI, new `today/` folder with api, cubit and widgets), tests under
`test/features/dashboard/payable_dashboard/` and the dashboard-route test. Shared Java endpoints only, all
already used by the web desk: `GET /api/dashboard/pending-payment/{comId}`,
`GET /api/dashboard/completed-payment/{comId}`, `GET /api/dashboard/expense/{comId}`,
`POST /api/common/checkFiles`, and (PO & Vouchers) `GET /api/ceo-dashboard/analytics/spend` + `/details`. CEO
dashboard code reused with a `spendOnly` switch: `CeoExpensesTab`, `CeoOwedPanel`, `CeoPeriodBar`, `CeoTabScroll`,
`CeoDashboardCubit.choosePeriod` / `clearSpend`. No new package.
