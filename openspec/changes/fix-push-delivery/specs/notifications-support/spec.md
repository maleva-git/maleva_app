## ADDED Requirements

### Requirement: Push notices pop up

The app SHALL show every push as an alert with a sound, whether the app is open, in the background or closed.

#### Scenario: Android, app closed
- **WHEN** a push arrives while the app is in the background or closed on Android
- **THEN** it is shown on the high-importance "Maleva alerts" channel, which the app created at start-up.

#### Scenario: iOS, app open
- **WHEN** a push arrives while the app is open on iOS
- **THEN** it is shown once.
