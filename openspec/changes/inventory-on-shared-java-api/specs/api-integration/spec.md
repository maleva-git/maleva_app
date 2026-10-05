## ADDED Requirements

### Requirement: Inventory report on the shared API

The Inventory report SHALL list `/api/sale-orders/inventory` for the chosen port chip, customer and
pending tick or dates, and read its fields. The app SHALL NOT call .NET `CustomerApp/SelectAllInventoryt`.

#### Scenario: Pending at a port
- **WHEN** the PTP chip is chosen with the pending tick
- **THEN** the app asks with `portType=1&pending=true` and lists the lines

#### Scenario: Refused period
- **WHEN** the server refuses the dates
- **THEN** the app shows its message
