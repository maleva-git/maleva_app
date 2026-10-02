# Design

## Flow

```
tab bloc -> repository -> DashboardApi -> JavaApiClient.dio (session token, refresh on 401) -> /api/dashboard/*
```

Screens read the Java fields. Where a Java key equals the .NET one (`TodaySales`, `ExpAmount`,
`BillNoDisplay`, `JobStatus`, `AccountName`, ...) the screen code is unchanged; where it differs
the screen now reads the Java key.

## Mapping

| Old .NET call | Java endpoint | Screen reads |
|---|---|---|
| LoginApp/GetSalesData?type= | GET /api/dashboard/sales/{comid}?type= | one map; `monthlySales` (newest first) in place of `Data2` |
| LoginApp/GetEmployeeSalesData?type= | GET /api/dashboard/employee-sales/{comid}?type= | `[{EmployeeName, SalesCount, Amount}]` |
| LoginApp/GetEmployeeInvData?type= | GET /api/dashboard/employee-invoice/{comid}?type= | same rows |
| LoginApp/GetExpData?startDate&endDate | GET /api/dashboard/expense/{comid}?fromDate&toDate | totals + `expenses` |
| LoginApp/GetFWData?startDate&endDate | GET /api/dashboard/forwarding/{comid}?fromDate&toDate | camelCase counts |
| DashBoardApp/LoadUnReleaseNo, LoadK8UnReleaseNo | GET /api/dashboard/unreleased/{comid}, /k8-unreleased/{comid} | `[{Id, BillNoDisplay, DayCount, Remarks}]` |
| DashBoardApp/LoadRulesType | GET /api/dashboard/employee-rules/{comid}?employeeId= | `[{Id, AccountName}]` |
| DashBoardApp/CheckSaleInvoiceCount | POST /api/dashboard/check-invoice-count/{comid} (`F5ViewModel`, camelCase) | the count only |
| DashBoardApp/SelectSalesOrderStatus | GET /api/dashboard/sales-order-status/{comid}?employeeId= | `[{Id, JobStatus, DayCount}]` |
| DashBoardApp/AirFrieghtDB | POST /api/dashboard/air-freight/{comid} (`etaType` 5) | camelCase rows; `setb`/`soetb` `yyyy-MM-dd HH:mm:ss` or '' |

`type` for the sales summary: 0 invoices, 1 all sale orders, 2 with invoice, 3 without (checked
against `DashboardRepository`: 2 = `InvoiceNo != 0`, 3 = `InvoiceNo = 0` and not status 8/12,
remarks rule before 2024-10-01). The employee rows' `type` is `block * 15 + period`.

## Findings on the Java side

Checked against `MalevaWeb-develop` (the .NET source the live server runs):

1. Employee rows for past months, and `/employee-sales` rows coming back with null fields: fixed
   in backend change `fix-dashboard-employee-sales` (ported from `LoginServices.GetEmployeeSalesData`).
2. `/employee-invoice` returned sale orders: fixed there too (ported from `GetEmployeeInvData`).
3. `/sales-order-status` rows were null: fixed there too (ported from `SelectSalesOrderStatus`).
4. `/sales` answers an all-zero summary with `success: true` when its query fails. Open.
5. `/supplier-expense` is an empty stub (blocks the maintenance widget); port
   `DashBoardServices.LoadSupplierExpenseData`. Open.
