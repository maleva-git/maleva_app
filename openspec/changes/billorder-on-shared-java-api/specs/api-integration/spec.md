## ADDED Requirements

### Requirement: Bills orders and petty cash on the shared API

The Bill Order, Petty Cash and Change Status screens SHALL use the shared Java bills order and petty
cash APIs with the session token and read their fields. The app SHALL NOT call .NET `BIllorderApp`.

#### Scenario: Pending bills orders
- **WHEN** the Bill Order tab lists a period
- **THEN** the app asks `/api/bills-order/select-bills-order` with `status=Pending` and shows its rows

#### Scenario: Petty cash of a period
- **WHEN** the Petty Cash tab lists a period
- **THEN** the app posts the dates to `/api/petty-cash-masters/search` and shows each petty cash with its lines

#### Scenario: Change Status of one petty cash
- **WHEN** Change Status opens for petty cash 9
- **THEN** the app loads `/api/petty-cash-masters/edit?id=9`
