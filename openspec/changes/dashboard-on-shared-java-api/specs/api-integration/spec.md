## ADDED Requirements

### Requirement: Dashboard numbers from the shared Java API

The app SHALL read the sales, invoice, expense, forwarding, unreleased-number, sales-desk and air
freight dashboard figures from the web's Java `/api/dashboard` endpoints with the session token,
and the screens SHALL read the Java field names.

#### Scenario: Sale-order desk
- **WHEN** the sale-order desk opens on "With invoice"
- **THEN** the app calls `GET /api/dashboard/sales/{comid}?type=2` and shows `TodaySales`,
  `TodayAmount`, ... and the month bars from `monthlySales`.

#### Scenario: Sales desk counts
- **WHEN** a sales desk loads for an employee
- **THEN** the app shows the number of rows of four `POST /api/dashboard/check-invoice-count`
  calls (without invoice since 2024-10-01; this month total, billed, unbilled) and the
  `GET /api/dashboard/sales-order-status` rows.

#### Scenario: Forwarding report
- **WHEN** the forwarding report loads a date range
- **THEN** the period block reads `todayCount` / `todayRelease` / `todayWithRelease` (and
  yesterday, week, month) and the K block reads `k1Count` ... `k8WithRelease` from one answer.

#### Scenario: Refusal
- **WHEN** an endpoint answers `success: false`
- **THEN** the tab shows its error state with the server's message.
