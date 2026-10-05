# Proposal

## Why

Three app screens still called .NET `TransactionReportApp`. The owner's rule (2026-10-02) says the
app uses the shared Java API and reads its fields. Backend change `share-transaction-report-api`
adds the two reads Java lacked. The Pre Alert PDF was already in Java.

## What Changes

| Screen | Before (.NET) | Now (shared Java) |
|---|---|---|
| Driver dashboard: Driver Salary | `DriverRTIDetailedReport` | `GET /api/rti-masters/driver-report/detailed/rows` |
| Receipt view (customer balances) | `SelectCustomerBalance` | `GET /api/customer-reports/period-balance/rows` |
| Pre Alert report: PDF | `PreAlertReport?PreAlertName=PreAlertReport` | `GET /api/transaction/pre-alert-report/ticket`, then the answered link on the Java host |

- **New** `TransactionReportApi` (`lib/core/reports`), registered in `auth_injection.dart`.
- **The screens read the Java fields.**
  - Driver Salary: `rtiNo`, `rtiDate`, `jobNo`, `driverName`, `truckName`, `truckType`, `customerName`, `origin`, `destination`, `place`, `quantity`, `pickupDate`, `deliveryDate`, `enterLink`, `exitLink`, `remarks`, `comments`, `salary`, the allowances and `amount`.
  - Receipt view: `customerName`, `balance`, `billAmount`.
- **Removed:**
  - the static .NET `ReportsApi` (`core/network/api_services/reports_api.dart`);
  - the three `ApiConstants`;
  - the Receipt card's bill-number line. Neither API ever sent a bill number, so the card always showed "Customer Summary".

## Behaviour changes

- **The driver's own salary only.** Driver Salary shows only the driver's own lines, and the server enforces it. It used to trust the `DriverId` the app sent.
- **Pre Alert ETA choice is fixed.** OETA, LETA and All now send 1, 2 and 3. OETA and LETA both used to send the same radio code, and "None" sent the letter "O".
- **Pre Alert port is fixed.** The port filter sends the port name, which is what the jobs store. It used to send the port id, which was matched as text.
- **Pre Alert shows refusals.** A refused report, for example "No Record Found !!!", now shows the server's message. It used to do nothing.
- **Sales late on the last day count.** Balances and salary lines include the whole to-date.

## Capabilities

### Modified Capabilities
- `api-integration`: Driver Salary, the Receipt view and the Pre Alert PDF use the shared Java reports.

## Impact

`lib/core/reports/transaction_report_api.dart` (new), `auth_injection.dart`, `api_constants.dart`,
`dashboard/common_tabs/{driversalary,receiptview}`, `transaction/prealertview/view`. Ships with
backend change `share-transaction-report-api`.
