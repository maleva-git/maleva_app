# Stock entry, update, and transfer

## Purpose

Describe warehouse stock creation, package barcode scanning, status updates, and transfer validation in MALEVA.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/dashboard/common_tabs/stockinentry/bloc/stock_in_entry_bloc.dart](../../../lib/features/dashboard/common_tabs/stockinentry/bloc/stock_in_entry_bloc.dart)
- [lib/features/dashboard/common_tabs/stockupdate/bloc/stock_update_bloc.dart](../../../lib/features/dashboard/common_tabs/stockupdate/bloc/stock_update_bloc.dart)
- [lib/features/dashboard/common_tabs/stocktransfer/bloc/stock_transfer_bloc.dart](../../../lib/features/dashboard/common_tabs/stocktransfer/bloc/stock_transfer_bloc.dart)
- [lib/features/dashboard/common_tabs/stocktransfer/data/stock_transfer_repository.dart](../../../lib/features/dashboard/common_tabs/stocktransfer/data/stock_transfer_repository.dart)
- [test/stock_transfer_bloc_test.dart](../../../test/stock_transfer_bloc_test.dart)
- [test/stock_update_bloc_test.dart](../../../test/stock_update_bloc_test.dart)

## Requirements

### Requirement: Create stock for a selected job

Stock entry SHALL load job data, request confirmation for a job found in the existing-stock lookup, and submit package, status, date, and image references when saving.

#### Scenario: Existing stock
- **WHEN** a selected job is in the cached stock-job list and confirmation has not been supplied
- **THEN** the client emits a stock-exists confirmation state before loading it.

#### Scenario: New stock response
- **WHEN** stock insert returns IsSuccess=true
- **THEN** the client exposes the returned stock ID for its success flow.

### Requirement: Validate package barcodes

After stock details are loaded, stock update and transfer SHALL accept only expected, previously unscanned package barcodes.

#### Scenario: Duplicate package
- **WHEN** a scanned barcode is already in the scanned list
- **THEN** the barcode is not added a second time.

#### Scenario: Expected package format
- **WHEN** a stock record has N packages
- **THEN** expected labels are built as label-1/N through label-N/N.

### Requirement: Require a complete transfer

Stock transfer SHALL require a destination warehouse, a nonzero package total equal to the scanned count, and a nonzero stock ID before requesting an update.

#### Scenario: Missing destination
- **WHEN** transfer is requested with no warehouse selected
- **THEN** the client reports Select WareHouse without calling the transfer endpoint.

#### Scenario: All packages scanned
- **WHEN** all transfer preconditions pass and the server reports IsSuccess=true
- **THEN** the form resets and reports Updated Successfully.

### Requirement: Follow stock status save with boarding officer update

Stock update SHALL request its boarding-officer update after a successful stock-status save.

#### Scenario: Successful first step
- **WHEN** the stock update response reports IsSuccess=true
- **THEN** the client awaits the separate boarding-officer request before emitting save success.

## Clarifications

Q07 covers non-atomic follow-up writes; Q08 covers transfer first-scan event ordering. Existing test files are evidence of intended checks, not test-pass claims. See [the clarification register](../../baseline/clarifications.md).
