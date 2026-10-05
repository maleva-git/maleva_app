## ADDED Requirements

### Requirement: No .NET-shaped adapter

The app SHALL read every lookup from its shared Java API through a typed client, and SHALL NOT contain
a layer that answers old .NET addresses from Java.

#### Scenario: Pick a driver
- **WHEN** the driver picker opens
- **THEN** the app lists `/api/driver-combo` through `DriverApi`

#### Scenario: An old .NET address
- **WHEN** a URL on the .NET host is posted
- **THEN** it goes to the legacy client unchanged; nothing rewrites it to Java
