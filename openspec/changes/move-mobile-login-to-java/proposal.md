# Proposal

## Why

The app signs in through the .NET `LoginApp/LoginAppSuccess` endpoint:
- It sends the password in the URL query.
- It keeps the plain-text password in SharedPreferences.
- It replays that password on every app start, because no session token exists.

Moving the remaining mobile features to the Java backend requires a Java session, so login goes first. The owner also asked for login and the post-login menu load to be done "in the correct manner": no stored password, one consistent session, one routing rule.

## What Changes

- **Sign-in moves to Java.**
  - Manual login calls `POST /api/mobile/auth/login` on the Java host (backend change `add-mobile-auth-api`), with the user name, password, driver flag and the FCM push token in a JSON body. Nothing goes in the URL.
  - Session fields are written to the same preference keys every other module reads (`Comid`, `MComid`, `EmpRefId`, `role_id`, `PermissionId`, `RulesType`, `DriverId`, truck), so the rest of the app keeps working against .NET unchanged.
- **BREAKING (stored data): no stored password.**
  - The app stores only the Java session token, in encrypted platform storage.
  - Existing saved `Username`/`Password` preferences are deleted on first start after the update. Those users sign in once more.
- **Session restore by token.** The splash flow refreshes the stored token (`/api/mobile/auth/refresh`) instead of replaying a password. When the 30-day session ends or the account is disabled, the user signs in again.
- **Menu from the server, every time.**
  - The drawer menu is replaced by the rows returned on each sign-in or refresh, and cached only to draw the drawer.
  - The rule that reused a stale cached menu whenever an old user name was stored is removed.
  - The menu rows keep their wire keys, so the drawer is unchanged.
- **One dashboard routing table** for login and restore. The login screen's map wins (owner decision, resolves Q01):
  - role 200 opens the admin dashboard after a restart too;
  - an unmapped role opens the unauthorized page instead of the admin dashboard.
- **Logout** calls Java sign-out (best effort), then clears the token and the existing preference fields.
- **Java requests carry the session token; .NET requests never do.**
  - Java requests require a valid TLS certificate.
  - The existing .NET transports, their `Tokenkey`/`Token` headers and their accept-all certificate behavior are unchanged (Q04 and Q12 otherwise stay open).

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `authentication`: login request shape and endpoint, what is persisted (no password; encrypted token), menu replacement rule, logout clearing the token. Sends the push token at sign-in.
- `app-startup`: restore by token refresh instead of replaying saved credentials; removal of saved passwords on upgrade.
- `navigation-permissions`: one dashboard map for manual login and restore (Q01 decided by the owner).
- `api-integration`: bearer session token on Java-host requests only, valid certificates for the Java host, one refresh-and-retry on a Java 401.

## Impact

- **Code:**
  - `lib/core/config/app_config.dart`: new Java base URL.
  - `lib/core/network`: a Java client.
  - `lib/features/auth`: data, bloc and login page.
  - `lib/splash/splashscreen.dart`.
  - `lib/core/utils/app_preferences.dart`, `auth_helper.dart`.
  - `lib/core/network/legacy_api_repository.dart`: the old `Login` path is removed from use.
  - `lib/core/di/injection.dart`.
  - `main.dart`: certificate callback scoped by host.
- **Dependency:** adds `flutter_secure_storage`, a new dependency, for the token.
- **Backend:** depends on `add-mobile-auth-api` being deployed. That change is blocked on the latest .NET `LoginServices.cs` for the menu rules.
- **Clarifications:**
  - Q01 resolved (owner chose the manual-login map).
  - Q02 resolved for login (no stored password; token in encrypted storage; session up to 30 days).
  - Q04 narrowed (the Java token is separate; legacy headers untouched).
  - Q03 and Q12 remain open for .NET traffic.
- **Coordination:** the in-progress change `refactor-client-architecture-preserve-behavior` names this as a separate proposal. Its task 2.1 (DI split) touches `injection.dart`; land one before the other and rebase.
- **Out of scope:**
  - Dashboard data endpoints (`GetSalesData`, `GetEmployeeSalesData`, `GetEmployeeInvData`, `GetFWData`, `GetExpData`): next batch.
  - The unused `SelectLoginUser` / `EditPassword` constants.
  - The uncalled `AuthHelper.EmployeeLogin`.
  - Password hashing on the server.
  - Changes to any other module's .NET calls.
