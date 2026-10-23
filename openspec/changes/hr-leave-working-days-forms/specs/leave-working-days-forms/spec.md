## ADDED Requirements

### Requirement: Leave form kinds and working days

When the server counts working days, the leave form SHALL offer whole days, half day morning, half day afternoon
and (office staff only) hours, show the working days it will count, and send the kind.

#### Scenario: Staff Friday to Monday
- **WHEN** a staff leave is chosen as whole days Friday to Monday
- **THEN** the form shows 2½ working days

#### Scenario: Driver form
- **WHEN** a driver opens the form
- **THEN** Hours is not offered

#### Scenario: Server switch off
- **WHEN** the server does not count working days
- **THEN** the form shows Whole days and Hours as before and sends no kind

### Requirement: Lists show working days

The leave lists SHALL show the server's working days when it sends them.

#### Scenario: Half day row
- **WHEN** a request has part AM and 0.5 working days
- **THEN** the list shows "½ Day (morning)"
