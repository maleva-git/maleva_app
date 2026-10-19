## ADDED Requirements

### Requirement: The work dashboard shows the tabs of every job

The boarding and forwarding agent dashboards SHALL show the tabs of every job in the session, each
tab once. With no jobs in the session they SHALL show the same tabs as before this change.

#### Scenario: Boarding admin with the forwarding job
- **WHEN** Kabilan (role 600, jobs boarding admin + forwarding agent) opens the app
- **THEN** the boarding dashboard shows VSL, Salary, SpotsSaleOrder, IR Report, InventoryReport, EmpLeave, RTI Activities, FW Requests, Seal / Break Seal

#### Scenario: Forwarding agent with the boarding job
- **WHEN** a role 1400 user with job `BOARDINGOFFICER` opens the app
- **THEN** the forwarding agent dashboard also shows VSL, and the vessel report loads only his ports

#### Scenario: Old backend
- **WHEN** the session has no `jobs` field
- **THEN** a role 500 user sees VSL, Salary, EmpLeave, IR Report, as before

### Requirement: Boarding limits follow the boarding job

The limits for role 500 (statuses 28, 5, 29; ETB/ETD) SHALL apply to a user with
`BOARDINGOFFICER` but not `BOARDINGOFFICERADMIN`.

#### Scenario: Officer job only
- **WHEN** a 1400 user with only the `BOARDINGOFFICER` job opens a vessel report row
- **THEN** he cannot set status 28 or edit ETB/ETD
