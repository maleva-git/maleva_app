## ADDED Requirements

### Requirement: No .NET leftovers in the app

The app SHALL hold no .NET address, session token, response wrapper or certificate exception, and SHALL
accept only valid TLS certificates. Firebase, notifications and Bluetooth printing SHALL remain, because
the Java implementation uses them.

#### Scenario: An invalid certificate
- **WHEN** a host presents an invalid TLS certificate
- **THEN** the app refuses the connection

#### Scenario: A push notification
- **WHEN** the Java backend sends a push to the signed-in phone
- **THEN** the app receives it as before
