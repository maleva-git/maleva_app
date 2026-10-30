## Purpose

The Payable dashboard in the app: a first tab, Today, that shows what must be paid, what was paid and what
still needs its document, from the same Java endpoints as the web payable desk.

## ADDED Requirements

### Requirement: Today is the first tab
The Payable dashboard SHALL show a Today tab first, then PO & Vouchers, Payments, Bills, Petty Cash, Expenses, Driver Salary,
IR Report, Emp Leave, then Fuel Filling, Speeding, Engine Hours, Fuel, Driver and Truck. No earlier tab SHALL be
removed.

#### Scenario: Payable user opens the app
- **WHEN** a role 1100 user opens the Payable dashboard
- **THEN** the Today tab is shown first

### Requirement: Number cards
The Today tab SHALL show four cards: Overdue (rows of `/api/dashboard/pending-payment` with `DueReportId` 2),
Due soon (`DueReportId` 1), both with count and total `Amount`, asked with `dueDate` = today + 5 days and
`toDate` = today; Paid this month (rows and total `Amount` of `/api/dashboard/completed-payment` from the 1st
of the month to today); and Paid without a document (those completed rows with no document filed). Overdue and
Paid without a document SHALL be red when above zero.

#### Scenario: Two payments past due
- **WHEN** the pending list has two rows with `DueReportId` 2 of RM 100 and RM 250
- **THEN** the Overdue card shows 2 and RM 350, in red

### Requirement: To pay list
The Today tab SHALL list the pending rows sorted overdue first, then due soon, then the rest, each group by due
date (earliest first, no date last). A row SHALL show the sub-expense name, else the expense name, the amount,
the due date and a chip (Overdue, Due soon, Scheduled). Tapping a row SHALL open a sheet with the bank name,
account number and a Copy button for the account number. The list SHALL show 10 rows until the user taps
Show all.

#### Scenario: Copy the account number
- **WHEN** the user taps a vendor row and then Copy
- **THEN** the account number is on the clipboard and a short "Copied" message shows

### Requirement: Paid without a document
A completed row SHALL count as having a document when its `Id` is in the list `/api/common/checkFiles` answers
for `/{company}/PayBills` (row `DetailedId` 1, supplier payment) or `/{company}/PaymentVoucher` (`DetailedId` 0,
payment voucher). The Today tab SHALL list the rows without one (date, number, paid to, amount). If the file
check fails, no row SHALL be marked as missing a document and the card SHALL say the check is unavailable.

#### Scenario: Voucher with no file
- **WHEN** a completed voucher row has `Id` 41 and 41 is not in the PaymentVoucher list
- **THEN** it is listed under Paid without a document and counted on the card

### Requirement: Spent this period
The Today tab SHALL show the today, yesterday, week and month count and amount of `/api/dashboard/expense`
(`TodaySales`/`TodayAmount` … `MonthSales`/`MonthAmount`) and the five expense heads with the largest
`ExpAmount` from the 1st of the month to today.

#### Scenario: Month totals
- **WHEN** the expense answer has `MonthSales` 40 and `MonthAmount` 12,500
- **THEN** the Spent section shows 40 and RM 12,500.00 for This month

### Requirement: Sections load on their own
Each section (pending, completed, documents, expense) SHALL load in parallel and SHALL show its own Retry when it
fails, without hiding the others. Pull to refresh SHALL reload all sections.

#### Scenario: Expense call fails
- **WHEN** the expense endpoint fails and the others succeed
- **THEN** the cards and lists show, and only the Spent section shows Retry

### Requirement: Open buttons
The Today tab SHALL offer buttons Payments, Bills, Petty Cash, Expenses and Driver Salary that switch the
dashboard to that tab.

#### Scenario: Open bills
- **WHEN** the user taps Bills on the Today tab
- **THEN** the dashboard switches to the Bills tab

### Requirement: PO and voucher expense
The PO & Vouchers tab SHALL show the spend flow of the chosen period (This month, Last month, This quarter, This year)
from `/api/ceo-dashboard/analytics/spend`, with purchase orders (count and amount) as the headline, and the views
Money flow, By supplier, By truck, 12 months and Whom we owe, each from the spend lists of `/details`. It SHALL NOT
show the Fuel or By category views and SHALL NOT ask the CEO overview, on load, on a period change or on refresh.
A refusal SHALL show the server's message with Retry.

#### Scenario: Payable user changes the period
- **WHEN** the user picks Last month on 16 Oct 2026
- **THEN** the spend flow of 1 Sep to 30 Sep is asked and the overview is not

#### Scenario: Whom we owe
- **WHEN** the user picks Whom we owe
- **THEN** the suppliers and payees owed today are listed, with no customer side
