# Spec Delta

## REMOVED Requirements

### Requirement: Restore saved credentials

**Reason**: The client no longer stores the password; replaying saved credentials at startup is replaced by refreshing a stored session token.

**Migration**: See "Restore saved session" below. On the first start after the update, saved username and password preferences are deleted and the user signs in once.

## ADDED Requirements

### Requirement: Restore saved session

The splash flow SHALL restore a session by refreshing the stored session token, route the user with the dashboard map, and otherwise open login.

#### Scenario: No stored session
- **WHEN** no session token is stored
- **THEN** the login page opens.

#### Scenario: Session restored
- **WHEN** a stored token is refreshed successfully
- **THEN** the client stores the new token, rewrites the session fields and menu from the response, and opens the dashboard chosen by the dashboard map.

#### Scenario: Session ended
- **WHEN** refresh is refused because the session expired, the token was revoked or the account was disabled
- **THEN** the client deletes the token, clears the login preference fields and opens the login page.

#### Scenario: Connection failure during restoration
- **WHEN** the refresh request fails to connect or times out
- **THEN** the splash shows a connection error popup offering retry or login, and keeps the stored token.

### Requirement: Remove saved passwords from earlier versions

On startup the client SHALL delete any username and password saved by earlier versions before restoring a session.

#### Scenario: Upgrade from a saved-password version
- **WHEN** the app starts with saved username and password preferences and no session token
- **THEN** both preferences are deleted and the login page opens.
