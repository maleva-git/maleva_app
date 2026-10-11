## ADDED Requirements

### Requirement: A vessel change notice opens the vessel changes screen

A tapped push with data `type=VESSEL_ETA_CHANGED` SHALL open the "Vessel changes" screen: at once
when the app is open or in the background, and after the person reaches their dashboard when the
tap started the app. A foreground push of this type SHALL be shown through local notifications with
the type as payload, and tapping that SHALL open the same screen. Other push types SHALL keep their
current behaviour.

#### Scenario: Background tap
- **WHEN** the app is in the background and the user taps "MAERSK RIO NEGRO 641S: ETA moved ..."
- **THEN** the app opens the Vessel changes screen

#### Scenario: Cold start
- **WHEN** the tap starts the app and the user signs in
- **THEN** the Vessel changes screen opens once the dashboard shows

#### Scenario: Other notices unchanged
- **WHEN** a `MAIL_UNREAD` or `FORWARDING_*` notice is tapped
- **THEN** it opens the same screen as before this change
