## ADDED Requirements

### Requirement: Only the CEO opens the CEO dashboard
After sign-in or session restore, the app SHALL open `/dashboard/ceo` for a non-driver user with role 100
and permission id 1, and SHALL keep opening `/dashboard/admin` for every other role 100 user. Drivers SHALL
keep the driver dashboard. When the server answers 403, the screen SHALL show "This dashboard is for the CEO
only" with a button to the admin dashboard instead of an error.

#### Scenario: The CEO signs in
- **WHEN** a user with role 100 and permission id 1 signs in or the session is restored
- **THEN** the CEO dashboard opens

#### Scenario: Another Super Admin signs in
- **WHEN** a user with role 100 and permission id 0 signs in
- **THEN** the admin dashboard opens, as before

#### Scenario: The server refuses
- **WHEN** the overview call answers 403
- **THEN** the screen shows "This dashboard is for the CEO only" and a button to the admin dashboard

### Requirement: The CEO keeps the admin dashboard
The CEO dashboard's app bar SHALL show the notification bell, a button that opens the admin dashboard, and
logout.

#### Scenario: Open the admin dashboard
- **WHEN** the CEO taps the admin dashboard button
- **THEN** the admin dashboard opens and Back returns to the CEO dashboard

### Requirement: Company numbers for a period
The CEO dashboard SHALL read the shared Java endpoint `GET /api/ceo-dashboard/analytics/overview` with the
chosen period's `fromDate` and `toDate` (This month, Last month, This quarter, This year; default This
month) and SHALL show, from its fields as sent: revenue (sale orders, change against the previous period),
invoiced, expenses (purchase orders), receivable, payable, open jobs (the sum of the open sale order status
counts); the 12 months of sale order and invoice amounts; the top 5 customers with their share; expense
categories as a donut and ranked list with count, share and change, and running costs; receivable and
payable ageing (Current, 1-30, 31-60, 61-90, 90+) and paid out; open sale orders and job orders by status,
open incidents, unreleased forwarding and trucks; active staff, staff on leave today and the top 5 sales
employees. A field the answer lacks SHALL show as 0. A part the server lists in `unavailable` SHALL show a
note on its section that those figures are unavailable.

#### Scenario: Switch the period
- **WHEN** the CEO chooses This year on 16 Oct 2026
- **THEN** the overview is asked for 2026-01-01 to 2026-10-16 and the numbers change to it

#### Scenario: A month on the chart
- **WHEN** the CEO taps a month on the revenue chart
- **THEN** that month's sale order count and amount and invoiced amount are shown, and a sheet lists every
  customer of that whole month

### Requirement: The list behind a number
A tap on an expense category, a sale order status, a job order status, a top customer, a top sales
employee, open incidents or on leave today SHALL open a draggable bottom sheet with the rows of
`GET /api/ceo-dashboard/analytics/details` for that kind, key and period: reference, date, title, line
under it, amount and status, with the count and total in its header and "Showing N of M" when the server
sent fewer rows than the count. The sheet SHALL show a loading state, an empty state, and the server's
message with Retry. A list already loaded for the same kind, key and period SHALL open without asking again
until the dashboard is refreshed.

#### Scenario: Fuel purchase orders
- **WHEN** the CEO taps "FUEL · 5 POs"
- **THEN** a sheet lists those purchase orders with PO number, date, supplier, truck and invoice, amount and
  status

#### Scenario: More rows than shown
- **WHEN** the details answer has 100 rows and a count of 240
- **THEN** the sheet ends with "Showing 100 of 240"

### Requirement: Sale orders by period
The CEO dashboard SHALL show a Sale orders panel with four cards - Today, Yesterday, This week (Sunday to
Saturday) and This month (the first to the last day of the calendar month), computed from the device's
day exactly as the web CEO page - each with the count and total of
`GET /api/ceo-dashboard/analytics/details?kind=SALE_ORDERS` for its days. A tap on a card SHALL open the
sale orders sheet for that period: its count and total, and a "By employee | All sale orders" switch
that starts on By employee. By employee SHALL list how many sale orders each employee opened in the period
(`kind=SALE_ORDER_EMPLOYEES`: rank, name, a bar against the busiest, order count, amount, most first,
"NO EMPLOYEE" for orders without one); a tap on an employee SHALL show only that employee's sale orders
(`kind=SALE_ORDERS&key=<employee id>`, `key=0` for no employee) in the same sheet with a way back to all
employees. All sale orders SHALL list the period's sale orders. A card whose list could not be loaded
SHALL say so, and its sheet SHALL offer Retry.

#### Scenario: This week on a Friday
- **WHEN** the dashboard opens on Friday 16 Oct 2026
- **THEN** This week asks 2026-10-11 to 2026-10-17 and This month asks 2026-10-01 to 2026-10-31

#### Scenario: Open today's sale orders
- **WHEN** the CEO taps the Today card
- **THEN** a sheet shows how many sale orders each employee opened today, and All sale orders lists them
  with job no, customer, employee, vessel, port, amount and status

#### Scenario: One employee's orders
- **WHEN** the CEO taps an employee with id 7 in the sheet
- **THEN** only that employee's sale orders of the period are listed (key 7), with a way back

#### Scenario: Orders without an employee
- **WHEN** the CEO taps "NO EMPLOYEE"
- **THEN** the sale orders without an employee are asked with key 0

### Requirement: Customers by amount
The CEO dashboard SHALL show a Top 20 customers list for the chosen period from `kind=CUSTOMERS`: rank
(`reference`), customer (`title`), jobs (`subtitle`), amount and share, with "Show all" for every customer
the server sent (up to 500). A tap on a customer SHALL open `kind=TOP_CUSTOMER` with the row id for the same
days. A tap on a month of the revenue chart SHALL open a sheet with `kind=CUSTOMERS` for that month's first
to last day, whose rows open that customer's sale orders of that month.

#### Scenario: Show all customers
- **WHEN** the period has 25 customers and the CEO taps "Show all 25 customers"
- **THEN** all 25 are listed

#### Scenario: A customer of a month
- **WHEN** the CEO taps the November 2025 bar and then a customer in the sheet
- **THEN** customers of 2025-11-01 to 2025-11-30 are listed, then that customer's sale orders of those days

### Requirement: Loading, errors and layout
The dashboard SHALL show a loading state, reload on pull-to-refresh and Refresh, and when the overview
cannot be loaded or lacks a section SHALL show the message with Retry on each affected section, keeping the
numbers already shown after a failed reload. It SHALL lay out in one column on a phone (down to 360 pt wide)
and two columns from 600 pt, without overflow.

#### Scenario: Server error
- **WHEN** the overview call fails with a server error
- **THEN** each section shows the message and Retry, and Retry loads the dashboard again
