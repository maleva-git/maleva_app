## ADDED Requirements

### Requirement: IR on the shared Java API

The IR screens SHALL read and write incident reports through the Java `/api/ir` endpoints with the session token, and SHALL show the server's message when a call fails.

#### Scenario: List
- **WHEN** the IR list loads with a date range, a status and a search text
- **THEN** the app calls `GET /api/ir` with `companyRefId`, `fromDate`, `toDate`, `irStatusRefId`, `openOnly` and `search`, and shows the items, count and total amount it answers.

#### Scenario: Save
- **WHEN** a report is saved
- **THEN** the app posts it to `/api/ir` without a user id, and the server records the signed-in user as author on a new report.

#### Scenario: Refused save
- **WHEN** the server refuses a save (for example an unknown status)
- **THEN** the form shows the server's message.

### Requirement: Truck Location on the shared Java API

The Truck Location Board SHALL read the week, save cells and Done ticks, and save the row order through `/api/truck-locations` with the session token.

#### Scenario: Save the week
- **WHEN** the board's changes are saved
- **THEN** the app posts the changed cells and Done ticks to `/api/truck-locations/week` and shows the week it answers.
