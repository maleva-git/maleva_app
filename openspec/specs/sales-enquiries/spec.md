# Sales orders and enquiries

## Purpose

Describe the existing sales-order entry and list workflows and the connection between enquiries and confirmed orders.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart](../../../lib/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart)
- [lib/features/transaction/salesorder/view/bloc/salesorderview_bloc.dart](../../../lib/features/transaction/salesorder/view/bloc/salesorderview_bloc.dart)
- [lib/features/dashboard/common_tabs/enquiry/view/data/enquiry_repository.dart](../../../lib/features/dashboard/common_tabs/enquiry/view/data/enquiry_repository.dart)
- [lib/features/dashboard/common_tabs/spotsaleorder/data/spotsale_repository.dart](../../../lib/features/dashboard/common_tabs/spotsaleorder/data/spotsale_repository.dart)
- [lib/features/dashboard/common_tabs/sale_update/data/sale_update_repository.dart](../../../lib/features/dashboard/common_tabs/sale_update/data/sale_update_repository.dart)

## Requirements

### Requirement: Require core sales entry fields

The transaction sales form SHALL reject save when customer, job type, or product details are missing.

#### Scenario: No products
- **WHEN** customer and job type are filled but the product list is empty
- **THEN** the client reports Add Product Details and does not submit that save.

### Requirement: Save order and confirm originating enquiry

The transaction sales form SHALL submit order details with company context and request confirmation of a linked enquiry after a successful order response.

#### Scenario: Order from enquiry
- **WHEN** the order save returns IsSuccess=true and enquiry ID is nonzero
- **THEN** the client makes a follow-up enquiry update with StatusName=CONFIRMED; this is a separate request.

### Requirement: Maintain pickup and delivery rows

The transaction sales form SHALL support multiple pickup and delivery addresses with their corresponding quantities and weights.

#### Scenario: Pending address at save
- **WHEN** a pickup or delivery address is still entered in its editor when save is requested
- **THEN** the save flow merges that editor value into the corresponding address, quantity, and weight lists.

### Requirement: Filter sales orders

The sales-order list SHALL send its selected date, customer, employee, status, and text filters when loading orders.

#### Scenario: Filtered reload
- **WHEN** a user loads the list after selecting filters
- **THEN** the request goes to SelectSaleOrder with the constructed filter body.

### Requirement: Update enquiry status

The enquiry repository SHALL submit the selected enquiry ID, company, and requested status for an enquiry status update.

#### Scenario: Cancel action
- **WHEN** the enquiry cancellation flow calls its repository
- **THEN** the repository posts to UpdateEnquiryMaster with the provided status value.

## Clarifications

Q05 covers field restrictions; Q06 covers duplicate sales/enquiry implementations; Q07 covers multi-request partial success and order/enquiry consistency. See [the clarification register](../../baseline/clarifications.md).
