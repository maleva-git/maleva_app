# Authentication and local session

## Purpose

Describe employee and driver login, local session persistence, and user-initiated logout in the existing client.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/auth/presentation/bloc/auth_bloc.dart](../../../lib/features/auth/presentation/bloc/auth_bloc.dart)
- [lib/features/auth/data/repositories/auth_repository.dart](../../../lib/features/auth/data/repositories/auth_repository.dart)
- [lib/core/network/api_services/auth_api.dart](../../../lib/core/network/api_services/auth_api.dart)
- [lib/core/utils/app_preferences.dart](../../../lib/core/utils/app_preferences.dart)
- [lib/core/utils/auth_helper.dart](../../../lib/core/utils/auth_helper.dart)
- [lib/core/session/app_session.dart](../../../lib/core/session/app_session.dart)

## Requirements

### Requirement: Validate login input

Manual login SHALL require a nonblank username and password and submit the selected employee or driver login mode.

#### Scenario: Missing credentials
- **WHEN** either field is blank after trimming
- **THEN** the client reports that username and password cannot be empty without submitting login.

#### Scenario: Driver selection
- **WHEN** driver login is enabled
- **THEN** the login request sends DriverId=1; employee mode sends 0.

### Requirement: Persist successful manual login

On a successful manual login response, the client SHALL persist the username, password, company IDs, employee reference, role ID, permission ID, and rules type read by the session flow.

#### Scenario: Successful response
- **WHEN** the login response reports IsSuccess=true with its expected data
- **THEN** the client stores the returned session fields and emits login success.

#### Scenario: Rejected response
- **WHEN** the login response does not report success
- **THEN** the client reports invalid credentials; some non-network errors are normalized to that same message.

### Requirement: Restore server menu data

The manual login flow SHALL cache returned menu rows for an empty old username and reuse cached rows for a nonempty old username.

#### Scenario: Returning login
- **WHEN** old username is present and cached menu JSON is nonempty
- **THEN** the client reconstructs menu entries and root entries from the cache.

### Requirement: Clear login on confirmed logout

The logout flow SHALL request confirmation, clear its configured login preference fields, and navigate to login when confirmed.

#### Scenario: Confirmed logout
- **WHEN** the user confirms logout
- **THEN** credentials, menu cache, role, permission, and company fields listed in clearOnLogout are reset and the login page opens.

#### Scenario: Cancelled logout
- **WHEN** the user declines logout
- **THEN** the logout flow returns without clearing those fields.

## Clarifications

Q02, Q03 and Q04 cover credential storage, token lifetime, and differing session stores; clearing every stored token is not verified. See [the clarification register](../../baseline/clarifications.md).
