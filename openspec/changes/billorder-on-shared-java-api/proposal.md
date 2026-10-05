# Proposal

## Why

The Bill Order, Petty Cash and Change Status screens called .NET `BIllorderAppController`. Under the
owner's rule (2026-10-02), the app uses the shared Java API and reads its fields. Java already has
both reads, so **no backend change** is needed:

| .NET (`BIllorderApp`) | Java (existing) |
|---|---|
| `SelectBillsOrderApp?Comid&Fromdate&Todate` → `BillsOrderMasterServices.SelectBillsOrderApp` | `GET /api/bills-order/select-bills-order?comid&fromdate&todate&status=Pending` |
| `SelectpetticashApp?Comid&Fromdate&Todate&...` → `PettyCashServices.SelectPettyCashMaster` | `POST /api/petty-cash-masters/search?companyId` `{fromDate, toDate}` |

- **Bills orders.** The Java "Pending" filter is .NET's app query: PStatus 0, active, company, sale date in the period, with the same columns.
- **Petty cash.** The Java search keeps .NET's filters and adds:
  - bound values;
  - the whole to-date;
  - a LEFT join to the employee, so a petty cash with no employee is still listed.

## What Changes

- **New** `BillsOrderApi` and `PettyCashApi` (`lib/core/finance`), registered in `auth_injection.dart`.
- **Bills order response.** `/select-bills-order` answers `{ok, data}` rather than `ApiResponse`. Per rule 2 the backend is not changed for the app; `BillsOrderApi` reads that shape as it is.
- **Models read the Java fields:**
  - `BillViewModel.fromJava`;
  - `PattycashMasterModel.fromJava`, which reads the date from `spettyCashDate` (dd/MM/yyyy), or `pettyCashDate` on `edit`;
  - `PattyCashDetailsModel.fromJava`.

  Lombok spells some names in lower case (`pstatus`, `cnumberDisplay`), so the readers match names without case. The .NET `fromJson` readers are removed.
- **Bill Order** and **Petty Cash** list from Java. A refused request shows the server's reason.
- **Change Status** loads its one petty cash from `GET /api/petty-cash-masters/edit?companyId&id`. The .NET call it replaced left out the dates .NET required, so it never loaded. Nothing in the app opens this page yet.
- **Removed:** `ApiConstants.apiBillorderview`, `apiGetpettycash`, and the unused .NET wrapper `PattycashView`.

## Behaviour changes

- **Petty cash late on the to-date is listed.** .NET compared against midnight on that day.
- **Petty cash with no employee is listed.** .NET's inner join dropped it.

## Capabilities

### Modified Capabilities
- `api-integration`: Bill Order, Petty Cash and Change Status use the shared Java bills order and petty cash APIs.

## Impact

`lib/core/finance/` (new), `bill_view_model.dart`, `pattycash_master_model.dart`,
`patty_cash_details_model.dart`, `model.dart`, `api_constants.dart`, `auth_injection.dart`,
`dashboard/common_tabs/{billorder,pettycash}`, `change_status_page.dart`. No backend change.
