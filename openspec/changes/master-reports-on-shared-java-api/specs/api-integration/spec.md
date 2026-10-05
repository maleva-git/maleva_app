## ADDED Requirements

### Requirement: Fleet report screens on the shared Java APIs

The Engine Hours, Fuel Fillings, Speeding, Truck Details, transport Maintenance, Driver Details,
driver truck-maintenance and driver licence screens SHALL read the shared Java `/api/gps/*` and
`/api/master-reports/{trucks,drivers}/rows` with the session token. The app SHALL NOT call .NET
`MasterReportApp`.

#### Scenario: Engine hours for a week
- **WHEN** engine hours are listed from 2026-10-01 to 2026-10-05
- **THEN** the app asks from 2026-10-01T00:00:00 to 2026-10-05T23:59:59, and shows the begin time as 05/10/2026 08:30:00

#### Scenario: Driver opens the licence tab
- **WHEN** a driver opens the licence expiry tab
- **THEN** only their own licence and port passes are shown
