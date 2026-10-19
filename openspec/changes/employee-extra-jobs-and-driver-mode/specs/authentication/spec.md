## ADDED Requirements

### Requirement: A linked person switches between office and driver mode

When the session has a linked driver, the dashboard SHALL show "Driver mode"; when a driver session
has a linked employee, the driver dashboard SHALL show "Office mode". Switching SHALL ask for
confirmation, call `POST /api/mobile/auth/switch`, save the new session and open its home dashboard.
The mode SHALL be kept after the app restarts.

#### Scenario: Switch to driver
- **WHEN** Kabilan taps "Driver mode" and confirms
- **THEN** the driver dashboard opens with his own transport, fuel and leave, without asking for a password

#### Scenario: Back to office
- **WHEN** he taps "Office mode" on the driver dashboard and confirms
- **THEN** his boarding dashboard opens with all his tabs

#### Scenario: Refused
- **WHEN** the server answers 403 "No linked driver"
- **THEN** a toast shows the message and the user stays signed in where he was

#### Scenario: Office alert tapped in Driver mode
- **WHEN** Kabilan is in Driver mode and taps a push with `forKind: EMPLOYEE`
- **THEN** the app asks to switch to office mode; Yes switches and opens the alert, No leaves him in Driver mode

#### Scenario: Alert of the current mode
- **WHEN** he taps a push with `forKind` equal to his current mode, or with no `forKind`
- **THEN** it opens as before this change

#### Scenario: No link
- **WHEN** the session has no `linkedDriverId`
- **THEN** no "Driver mode" button is shown
