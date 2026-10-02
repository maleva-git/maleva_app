## ADDED Requirements

### Requirement: Sale orders on the shared Java API

The sale order screens SHALL use the shared Java sale order, vessel planning, planning, sequence,
currency and bills order APIs that React uses, with the session token, and read their fields as
they answer; the app SHALL NOT call the .NET `SaleOrderApp` API for them.

#### Scenario: Edit a sale order
- **WHEN** an operator opens job 40 from the sale order list and saves a new remark
- **THEN** the app reads `/api/sale-orders/edit?id=40` and PUTs the loaded order with the new remark, keeping the boarding officers and dates the form does not show.

#### Scenario: Raise a sale order from an enquiry
- **WHEN** an enquiry is pushed to a sale order
- **THEN** the one Sale Order form opens filled from the enquiry and creates the order with POST `/api/sale-orders/save`.

#### Scenario: Pick a job
- **WHEN** a job number is typed in a job picker
- **THEN** the suggestions come from `/api/sale-orders/job-numbers` of the screen's bill type.

#### Scenario: Update boarding officers without clearing the other side
- **WHEN** Stock Update makes the employee the loading boarding officer
- **THEN** the vessel planning update carries the job's off-vessel officers unchanged.

#### Scenario: Refused update
- **WHEN** the server refuses a sale order update
- **THEN** the screen shows the server's message.
