## ADDED Requirements

### Requirement: License tab on the shared driver search

The License tab SHALL list the company's first 100 drivers from `/api/driver-masters/search` and read
its fields. The app SHALL NOT call .NET `DriverApp/SelectDriver`.

#### Scenario: List the licences
- **WHEN** HR Admin opens the License tab
- **THEN** the app asks `/api/driver-masters/search` with `pageCount=100` and shows each driver's licence

#### Scenario: A licence about to expire
- **WHEN** a driver's `licenseExp` is within 30 days
- **THEN** the card shows the expiring-soon warning
