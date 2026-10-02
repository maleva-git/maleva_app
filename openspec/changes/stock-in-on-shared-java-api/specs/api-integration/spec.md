## ADDED Requirements

### Requirement: Stock screens on the shared stock-in API

Stock In Entry, Stock Update and Stock Transfer SHALL use the shared Java `/api/stock-ins` with the
session token and read its fields; the app SHALL NOT call a `/api/mobile/app` bridge.

#### Scenario: Scan a package label
- **WHEN** Stock Transfer scans `MY00123-2/3`
- **THEN** the app asks `/api/stock-ins/entries/by-label` and shows the stock-in's packages and warehouse.

#### Scenario: Refused arrival
- **WHEN** the server refuses a warehouse arrival
- **THEN** Stock Update shows the server's message.
