## ADDED Requirements

### Requirement: Job Orders tab on the shared job order API

The Job Orders tab SHALL use the shared Java `/api/job-orders` (list, statuses, status update) with
the session token and read its fields. The app SHALL NOT call .NET `JobOrderMasterApp`.

#### Scenario: Open the tab
- **WHEN** the Job Orders tab opens
- **THEN** the app lists the company's active job orders with status 1 from `POST /api/job-orders/list`, and shows the status chips from `GET /api/job-orders/statuses`

#### Scenario: Job details
- **WHEN** a job order is tapped
- **THEN** its active detail lines are shown with the product name from the company's products

#### Scenario: Change status
- **WHEN** a job order is long-pressed and given another status
- **THEN** the app calls `PUT /api/job-orders/{id}/status` and lists again with the same filter
