# Financial and customer reports

## Purpose

Describe the existing client requests for customer balances, pending payments, bills, petty cash, invoices, and operational financial reports.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/dashboard/common_tabs/receiptview/data/receipt_repository.dart](../../../lib/features/dashboard/common_tabs/receiptview/data/receipt_repository.dart)
- [lib/features/dashboard/common_tabs/paymentview/data/paymentview_repository.dart](../../../lib/features/dashboard/common_tabs/paymentview/data/paymentview_repository.dart)
- [lib/features/dashboard/common_tabs/billorder/data/billorder_repository.dart](../../../lib/features/dashboard/common_tabs/billorder/data/billorder_repository.dart)
- [lib/features/dashboard/common_tabs/pettycash/data/pettycash_repository.dart](../../../lib/features/dashboard/common_tabs/pettycash/data/pettycash_repository.dart)
- [lib/features/dashboard/common_tabs/invoice/data/invoice_repository.dart](../../../lib/features/dashboard/common_tabs/invoice/data/invoice_repository.dart)
- [lib/features/dashboard/common_tabs/inventoryreport/data/inventoryreport_repository.dart](../../../lib/features/dashboard/common_tabs/inventoryreport/data/inventoryreport_repository.dart)
- [lib/core/network/api_services/reports_api.dart](../../../lib/core/network/api_services/reports_api.dart)
- [lib/features/transaction/prealertview/view/prealertview_tab.dart](../../../lib/features/transaction/prealertview/view/prealertview_tab.dart)

## Requirements

### Requirement: Load customer balance masters and details

The receipt-view repository SHALL request customer balances for the selected date range and company, exposing Data1 as masters and Data2 as details when present as lists.

#### Scenario: Balance response
- **WHEN** the response is nonempty and contains master/detail lists
- **THEN** the repository returns those lists to its receipt view.

### Requirement: Load payment and expense reporting

The reporting layer SHALL provide pending-payment, bill-order, petty-cash, expense, and forwarding report requests with the context constructed by their callers.

#### Scenario: Pending payments
- **WHEN** the pending-payment repository receives a filter
- **THEN** the client requests the matching pending-payment report.

### Requirement: Load customer inventory report

The customer inventory repository SHALL load customer choices and request inventory report data for its selected filters.

#### Scenario: Inventory request
- **WHEN** the user loads the customer inventory report
- **THEN** the repository posts the report body to SelectAllInventoryt, preserving the existing endpoint spelling.

### Requirement: Generate a pre-alert document

The pre-alert screen SHALL construct a report request from its selected filters and open the returned document URL when the response reports success.

#### Scenario: Pre-alert document ready
- **WHEN** the PreAlertReport request returns IsSuccess=true
- **THEN** the screen launches the URL returned in the response data.

## Clarifications

Q06 covers accounting definitions, currencies, totals, and report ownership. No payment execution, ledger calculation, or financial correctness guarantee is inferred from report screens. See [the clarification register](../../baseline/clarifications.md).
