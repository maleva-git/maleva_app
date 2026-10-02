# Design

## Context

See proposal.md - Why. Current state, code-verified on 2026-10-01:

- **One host.** `AppConfig.baseUrl` is the .NET host; every constant in `api_constants.dart` is a .NET `…App/…` path.
- **Two login paths that persist different fields:**
  - Manual: `AuthRepository` → `AuthApi.loginUserRaw` over `ApiClient`/`http`. Writes the role, permission and EmpRefId preferences.
  - Splash: `LegacyApiRepository.Login` over Dio. Does not write `role_id`, `PermissionId` or `EmpRefId`.
  - Both send `Userid`/`Pwd` in the query string.
- **Menu.** The menu is `Data3` of the login response (`MenuMasterModel` keys `FormText`, `Id`, `ParentId`, `CompanyRefid`, `PageAdd/Edit/Delete/View`). It is ignored in favour of the `loadmenu` cache whenever `OldUsername` is set. The drawer (`lib/menu/menulist.dart`) maps screens by `FormText`.
- **Tokens.** No auth token is ever written. `ApiClient` adds Bearer/`Userid`/`Profile` from `Tokenkey`; Dio adds `Token` from `Tokenkey`. Both are empty in practice, and both behaviors are pinned by `test/core/network/transport_contract_test.dart`.
- **TLS.** `MyHttpOverrides` in `main.dart` accepts every certificate for every host (Q12).
- **Dashboard routing.**
  - Manual map: `login_page.dart:40-94`.
  - Restore map: `splashscreen.dart:147-188`. It differs for role 200 and for unmapped roles (Q01).
- **Readers of session data.** About 117 files read `Comid`, about 52 read `EmpRefId`, and others read `role_id`, `PermissionId` and `RulesType` from preferences or `AppGlobals`. These keys must keep their names and meaning.
- **Backend contract:** `add-mobile-auth-api` (maleva-backend):
  - `POST /api/mobile/auth/login` (body `userName`, `password`, `driver`, `deviceToken`);
  - `POST /api/mobile/auth/refresh` and `POST /api/mobile/auth/logout` (Bearer).
  - Responses use `IsSuccess` / `StatusCode` / `Message` / `Data1`. `Data1` holds `token`, `expiresAt`, `sessionExpiresAt`, `principalKind`, `userId`, `companyId`, `mComid`, `companyName`, `rulesType`, `roleId`, `permissionId`, `truckRefId`, `truckName` and `menu`; the menu rows keep the legacy keys.

## Goals / Non-Goals

**Goals:**
- One login path used by the login page and the splash; one session writer; one dashboard map.
- No password on the device.
- Every module that reads `Comid`/`EmpRefId`/`role_id`/… keeps working untouched.
- A Java client that the next migration batches reuse.

**Non-Goals:**
- Moving any other endpoint to Java.
- Changing the .NET transports, `Tokenkey`, the Dio `Token` header, or their certificate handling.
- An auth redirect guard in GoRouter (Q03).
- UI redesign of the login page.
- Biometric unlock.

## Decisions

### 1. A separate `JavaApiClient` (Dio) for the Java host
A new Dio instance with these properties:
- `baseUrl = AppConfig.javaBaseUrl` (production `https://maleva.mydriverszone.com`, the host React uses);
- an interceptor that adds `Authorization: Bearer <token>` from `SessionTokenStore`, except on sign-in;
- on 401, one refresh-and-retry;
- registered in DI.

The existing `ApiClient` and `DioClient` are untouched, so the Java token can never reach the .NET host, and `transport_contract_test.dart` keeps passing unchanged.
*Alternative:* write the token into `Tokenkey`. Rejected: both legacy clients would then send it to the .NET host (Bearer + `Token`), and that would change their contract (Q04).

### 2. `SessionTokenStore` on `flutter_secure_storage`
It keeps the token and `sessionExpiresAt` in Keychain / Keystore-backed encrypted storage. A new dependency is needed: SharedPreferences is plain text, and storing a 30-day credential there would repeat today's problem. iOS uses `first_unlock` accessibility, so background notification handling can still read the token.
*Alternative:* keep it in SharedPreferences. Rejected for the reason above.

### 3. One `SessionService` replaces both login paths
`SessionService` has `signIn(userName, password, driver)`, `restore()` and `signOut()`.
- **`signIn`**: calls the Java login with the FCM token from `AppGlobals.getDeviceToken`, then hands the response to a single `SessionWriter`.
- **`SessionWriter`** writes:
  - the token to `SessionTokenStore`;
  - the existing preference keys: `Comid`, `MComid`, `EmpRefId`, `role_id`, `PermissionId`, `RulesType`, `DriverId`, `EnquiryOpen`;
  - `AppGlobals`: `Comid`, `EmpRefId`, `selectedCompanyName`, `DriverLogin`, `DriverTruckRefId`, `DriverTruckName`;
  - the menu: `loadmenu`, `objMenuMaster`, `parentclass`.

  `Username`, `Password` and `OldUsername` are not written. `OldUsername` was only used for the stale-menu rule, which is removed.
- **`restore()`**: deletes legacy `Username`/`Password`, refreshes, and uses the same writer.
- **`signOut()`**: best-effort Java logout, deletes the token, then the existing `AppPreferences.clearOnLogout`.

`AuthRepository`/`LoginBloc` call `SessionService`. `LegacyApiRepository.Login` and `AuthApi.loginUser*` lose their callers and are deleted along with `apiLoginSuccess`.
*Alternative:* adapt the two existing paths separately. Rejected: they already drifted (Q01, Q02).

### 4. One dashboard map, `DashboardRoutes.forSession(...)`
This is the manual map from `login_page.dart`, extracted and used by the login page and the splash. `/dashboard/subadmin` loses its only entry point (the splash, role 200). The route stays registered and unused, and is recorded in the clarification register as a follow-up instead of being deleted here.

### 5. Certificate check scoped by host
`MyHttpOverrides.badCertificateCallback` becomes `(cert, host, port) => host != Uri.parse(AppConfig.javaBaseUrl).host`. Every other host keeps the accept-all behavior (Q12 stays open for .NET).
*Alternative:* a per-client `HttpClientAdapter` for Java only. Equivalent, but the global override would still apply to it; the host check is the smaller change.

### 6. Upgrade
On the first start of the new version, any `Username`/`Password` left by older versions is deleted before restore, so the password stops existing on the device. Those users see the login page once.

## Risks / Trade-offs

- **[Backend menu not yet ported]** If the app ships before `add-mobile-auth-api` has the live menu rules, users lose drawer entries. → Hard ordering: the app release waits for backend tasks 1.x and 4.2.
- **[Everyone signs in once after the update]** Unavoidable once the password is no longer stored. → Release note; the session then lasts up to 30 days.
- **[Secure storage on old Android / restored backups]** Encrypted values can be unreadable after a backup restore. → A read failure is treated as "no session", so the user just signs in. Android backup exclusion is set in the plugin options.
- **[Two clients during migration]** .NET and Java coexist until every module moves. → Only `JavaApiClient` knows the token; later batches move modules onto it one by one.
- **[Merge with the refactor change]** Both touch `injection.dart`. → Land in sequence; registrations are additive.

## Migration Plan

1. Backend `add-mobile-auth-api` deployed and verified (menu parity).
2. Ship this app version. Older installs keep working against .NET until they update.
3. Rollback: revert the app release. The backend endpoints are additive, and the .NET login remains available.

## Open Questions

None that change scope. The production Java host (`https://maleva.mydriverszone.com`) is confirmed with the team in task 1.1.
