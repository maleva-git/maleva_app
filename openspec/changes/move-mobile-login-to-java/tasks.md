# Tasks

## 1. Prerequisites and foundation

- [ ] 1.1 Confirm the backend change `add-mobile-auth-api` is deployed to the target environment with its menu parity check (its task 4.2) recorded, and confirm the Java host URL per environment with the team. Verify: a recorded note in this change; do not start group 3 without it.
- [x] 1.2 Add `AppConfig.javaBaseUrl` (production `https://maleva.mydriverszone.com`, with the local/demo alternatives commented like `baseUrl`). Verify: analyzer passes; no `baseUrl` usage changes.
- [x] 1.3 Add `flutter_secure_storage` and implement `SessionTokenStore` (token and `sessionExpiresAt`; read failure means no session; Android backup exclusion). Verify: unit tests with a fake platform store for save, read, delete and read failure (api-integration, authentication).
- [x] 1.4 Implement `JavaApiClient` (Dio on `javaBaseUrl`): Bearer from `SessionTokenStore` except on sign-in, one refresh-and-retry on 401, then a session-ended callback. Verify: tests with an intercepted transport for header present on Java, absent on sign-in, 401 → refresh → retry once, refresh refused → session-ended (requirement "Authenticate Java backend requests with the session token"); `test/core/network/transport_contract_test.dart` still passes unchanged (legacy clients send no Java token).
- [x] 1.5 Scope `MyHttpOverrides.badCertificateCallback` so the Java host requires a valid certificate. Verify: unit test of the callback for the Java host (false) and the .NET host (true) (requirement "Verify the Java host certificate").

## 2. Session service and writer

- [x] 2.1 Implement the Java mobile-auth data source and the session model for the `Data1` contract; menu rows parse with `MenuMasterModel`. Verify: parsing tests with synthetic employee, driver, no-truck and empty-menu fixtures; a 401 maps to invalid credentials and connect/timeout errors map to a connection error (authentication "Persist successful manual login").
- [x] 2.2 Implement `SessionWriter`: token to `SessionTokenStore`; `Comid`, `MComid`, `EmpRefId`, `role_id`, `PermissionId`, `RulesType`, `DriverId`, `EnquiryOpen` preferences; the `AppGlobals` session and driver-truck fields; the menu (`loadmenu`, `objMenuMaster`, `parentclass`, rows without a label skipped). It never writes `Username`/`Password`/`OldUsername`. Verify: tests assert every key and global for employee and driver sessions, assert no password key is written, and assert the drawer roots built from the rows (authentication "Restore server menu data").
- [x] 2.3 Implement `SessionService.signIn/restore/signOut`. signIn sends the body (`userName`, `password`, `driver`, `deviceToken` when available). restore deletes legacy `Username`/`Password` and then refreshes. signOut makes a best-effort logout, deletes the token, then calls `clearOnLogout`. Verify: tests for the body (no credentials in the URL), push token present/absent, restore without a token, restore success, restore refused (fields cleared), restore connection failure (token kept), upgrade with saved credentials (deleted), logout online and offline (app-startup and authentication requirements).

## 3. Wire the screens

- [x] 3.1 Extract `DashboardRoutes.forSession` from the `login_page.dart` map and use it in the login page and the splash; record in `openspec/baseline/clarifications.md` that Q01 is resolved by this change and that `/dashboard/subadmin` no longer has an entry point. Verify: table test for every mapped role, the driver, and an unmapped role, plus a test that role 200 restore opens the admin dashboard (navigation-permissions "Choose dashboard after manual login").
- [x] 3.2 `AuthRepository`/`LoginBloc` use `SessionService.signIn`; the login page keeps its validation and messages and shows a connection message on network failure. Verify: bloc tests for blank input (no request), success (navigates by map), 401 and network error; the existing `test/widget_test.dart` login smoke test passes.
- [x] 3.3 The splash uses `SessionService.restore`, with the existing connection popup (retry / go to login) on network failure. Verify: widget tests with a fake `SessionService` for no session → login, restored → dashboard, refused → login, network failure → popup with the token kept.
- [x] 3.4 `AuthHelper.logout` uses `SessionService.signOut`. Verify: test that confirm clears and navigates even when sign-out fails, and that cancel does nothing.
- [x] 3.5 Remove the unused old login paths (`LegacyApiRepository.Login`, `AuthApi.loginUser`/`loginUserRaw`, `apiLoginSuccess`) and update `openspec/baseline/endpoint-inventory.md` and `api-interactions.md`. Verify: `grep` shows no reference to `LoginAppSuccess` in `lib/`; analyzer clean.

- [x] 3.6 Keep the server's push token current: `SessionService.syncDeviceToken` sends a token the server does not have yet (late token after sign-in or restore, Firebase `onTokenRefresh`), once per session, never throwing. Verify: API, service, listener, splash and login tests.

## 4. Integration checks

- [x] 4.1 Run the analyzer and the full test suite. Verify: no new failures compared with the inherited baseline record; refactor-change tests still pass.
- [ ] 4.2 On a test environment, run employee login for one account per RulesType and one driver: check the dashboard, drawer entries against the .NET app, a restart restore, logout, and a disabled account being refused on restore. Record the results without credentials or personal data. Keep this open if test accounts or devices are unavailable.
- [ ] 4.3 Build Android and iOS release configurations and confirm secure storage works after an app restart on each. Record the device and OS versions. Keep this open if a platform is unavailable.
