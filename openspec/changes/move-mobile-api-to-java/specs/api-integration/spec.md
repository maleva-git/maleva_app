## ADDED Requirements

### Requirement: Moved calls go to Java

A call to a .NET app controller or action listed as moved SHALL be sent to the same path under `/api/mobile/app` on the Java host, with the request body, query and the caller's headers unchanged, and its answer SHALL be handled as the .NET answer was.

#### Scenario: Moved controller
- **WHEN** the app calls `FuelEntryApp/SelectFuelEntry` and `FuelEntryApp` is moved
- **THEN** the request goes to `<java host>/api/mobile/app/FuelEntryApp/SelectFuelEntry` and the screen receives the same rows.

#### Scenario: Not moved
- **WHEN** the app calls a controller that is not moved
- **THEN** the request goes to the .NET host exactly as before.

### Requirement: Session token only to Java

Calls to the Java host SHALL carry the session token and SHALL NOT carry the legacy auth headers; calls to .NET SHALL NOT carry the session token.

#### Scenario: Expired access token
- **WHEN** a moved call is answered 401
- **THEN** the session is refreshed once and the call retried; if the refresh is refused the session ends and the login page opens.

#### Scenario: Server error
- **WHEN** a moved call is answered 500 with the .NET envelope
- **THEN** the caller sees the same message it saw from .NET.
