# Spec Delta

## MODIFIED Requirements

### Requirement: Validate login input

Manual login SHALL require a nonblank username and password and submit them with the selected employee or driver login mode to the Java mobile sign-in endpoint in the request body.

#### Scenario: Missing credentials
- **WHEN** either field is blank after trimming
- **THEN** the client reports that username and password cannot be empty without submitting login.

#### Scenario: Driver selection
- **WHEN** driver login is enabled
- **THEN** the sign-in request marks the login as a driver login; employee mode marks it as an employee login.

#### Scenario: Credentials stay out of the URL
- **WHEN** the client submits login
- **THEN** the username and password are sent only in the request body, never in the URL or query string.

### Requirement: Persist successful manual login

On a successful sign-in, the client SHALL store the session token in encrypted platform storage and write the returned company IDs, employee reference, role ID, permission ID, rules type, driver mode and truck to the preference fields read by the session flow. It SHALL NOT store the password.

#### Scenario: Successful response
- **WHEN** the sign-in response reports success with a session
- **THEN** the client stores the token in encrypted storage, writes the returned session fields, does not write a password anywhere, and emits login success.

#### Scenario: Rejected response
- **WHEN** the sign-in response has HTTP status 401
- **THEN** the client reports invalid username and password and stores nothing.

#### Scenario: Server unreachable
- **WHEN** the sign-in request fails to connect or times out
- **THEN** the client reports a connection problem, not invalid credentials, and stores nothing.

### Requirement: Restore server menu data

The client SHALL replace its menu with the menu rows returned by each successful sign-in or session refresh, build menu entries and root entries from them, and keep a cached copy only for drawing the drawer.

#### Scenario: Returning login
- **WHEN** a user signs in, or the session is refreshed, and the response carries menu rows
- **THEN** the drawer is built from those rows, even if an older cached menu exists.

#### Scenario: Rows without a label
- **WHEN** a returned menu row has no label
- **THEN** it is left out of the menu, as before.

### Requirement: Clear login on confirmed logout

The logout flow SHALL request confirmation; when confirmed it SHALL ask the server to end the session, delete the stored session token, clear its configured login preference fields, and navigate to login.

#### Scenario: Confirmed logout
- **WHEN** the user confirms logout
- **THEN** the client requests sign-out with its token, deletes the token, resets the menu cache, role, permission and company fields listed in clearOnLogout, and opens the login page.

#### Scenario: Logout while offline
- **WHEN** the user confirms logout and the sign-out request fails
- **THEN** the client still deletes the token, clears those fields and opens the login page.

#### Scenario: Cancelled logout
- **WHEN** the user declines logout
- **THEN** the logout flow returns without clearing those fields.

## ADDED Requirements

### Requirement: Send the device push token at sign-in

Manual sign-in SHALL include the device's push token when one is available, so the server can address notifications to the signed-in employee or driver.

#### Scenario: Push token available
- **WHEN** the device has a push token at sign-in
- **THEN** the sign-in request includes it.

#### Scenario: Push token unavailable
- **WHEN** no push token could be obtained
- **THEN** sign-in proceeds without it.

#### Scenario: Push token obtained after sign-in
- **WHEN** the push token becomes available only after sign-in or after a restored session
- **THEN** the app sends it to `POST /api/mobile/auth/device-token` once.

#### Scenario: Push token replaced
- **WHEN** Firebase replaces the device's push token while a session is signed in
- **THEN** the app saves it and sends it to the server once; a failed send is retried on the next start or token change and never interrupts the user.
