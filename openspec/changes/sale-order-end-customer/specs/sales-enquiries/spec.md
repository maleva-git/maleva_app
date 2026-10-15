## ADDED Requirements

### Requirement: The sales order form carries an end customer

The sales order form SHALL show an End Customer field under Customer Name, enabled once a customer
is chosen. Tapping it SHALL open a sheet with the customer's end customers from
`GET /api/end-customers/customer/{customerId}` and a box to add a new name through
`POST /api/end-customers/customer/{customerId}/quick-add`; the chosen or added one SHALL fill the
field. Choosing another customer or clearing the customer SHALL clear the end customer. Editing an
order SHALL show its stored end customer (`endCustomerName`). The save body SHALL carry
`endCustomerRefId`: the chosen id, or 0 when the field is empty.

#### Scenario: Daikin added under CIVA
- **WHEN** the customer is CIVA and the user types "Daikin" in the sheet and taps Add
- **THEN** the field shows Daikin and the save body carries Daikin's id as `endCustomerRefId`

#### Scenario: Customer changed
- **WHEN** an order shows end customer Daikin and the user picks customer ABC
- **THEN** the End Customer field is empty and the save body carries `endCustomerRefId` 0

#### Scenario: Server not ready
- **WHEN** the end customer request fails
- **THEN** the sheet shows the server's message and the form keeps working

### Requirement: The sales order list shows the end customer

A sales order row SHALL show its end customer under the customer name when `EndCustomerName` is
not empty, and nothing extra when it is empty.

#### Scenario: CIVA job for Daikin
- **WHEN** a row has CustomerName "CIVA" and EndCustomerName "Daikin"
- **THEN** the row shows CIVA with "for Daikin" under it
