# Architecture and workflow evidence

Inspection date: 2026-10-01. Scope: the existing Flutter client in this repository.
This is a source map, not a proposed migration.

## Application organization

| Area | Observed implementation |
| --- | --- |
| App shell | `lib/main.dart` initializes services and builds `MaterialApp.router`; `MyHomePage` installs notification listeners and presents the splash flow. |
| Startup | `lib/splash/splashscreen.dart` initializes shared preferences, attempts a device token fetch, and uses a legacy login path to restore saved credentials. |
| Manual login | `features/auth` uses a login BLoC, auth repository, and auth API; it persists role and menu information. |
| Navigation | `core/router/app_router.dart` registers dashboard routes; the menu and dashboards also push `MaterialPageRoute` screens. A route registration alone is not proof of authorization or production reachability. |
| State | Most feature folders contain BLoC events/state and views; legacy globals and SharedPreferences remain in use. |
| Newer feature boundaries | IR and truck location separate domain entities, repositories, remote data sources, JSON mapping, and presentation. `AppSession` supplies company/employee/role context. |
| Networking | Both `http`-based `ApiClient` and Dio-based repositories are present, plus direct multipart calls. Headers, errors, and response shapes differ. |
| Shared UI | `core/theme`, `core/colors`, and `core/widgets` provide styles and shared controls. |
| Native configuration | Android application ID is `com.kassapos.maleva`; the checked-in build targets/compiles SDK 36. iOS and desktop/web scaffolds exist, but no supported-platform guarantee follows from their presence. |
| Tests | Existing tests concentrate on IR, truck location, and stock BLoCs; a widget-test file also exists. See the module inventory for paths. |

Evidence: [entry point](../../lib/main.dart), [router](../../lib/core/router/app_router.dart),
[DI](../../lib/core/di/injection.dart), [session](../../lib/core/session/app_session.dart),
[dependencies](../../pubspec.yaml), [Android build](../../android/app/build.gradle).

## Main flows

| Flow | Observed sequence | Boundary requiring care |
| --- | --- | --- |
| Startup/restoration | Initialize → splash → saved credential login or login screen → dashboard. | Startup login differs from manual login in persisted fields and role routing (Q01/Q02). |
| Manual login | Validate fields → login API → persist identity/company/role/menu → role dashboard. | Cached menus can be reused; no uniform route-level permission guard was found (Q03). |
| Sales/enquiry | Load master choices → compose order → validate customer/job/products → save order → confirm linked enquiry. | Confirmation is a second write, not a demonstrated transaction (Q07). |
| Transport planning | Search plans/jobs → select or add rows → assign trucks/drivers and dates → save master/details → request PDF. | Save uses an inline `/api/PLANING/InsertPLANING` path and a nonempty-result success check. |
| Vessel planning | Search by dates/ETA/ports → edit job or planning rows → save/delete → reload or request PDF. | Multiple screen implementations and optimistic error handling exist (Q06/Q07). |
| Stock intake | Select job → confirm if stock exists → enter packages/status/images → save → expose stock ID. | Barcode prefixes differ by bill type; print execution is a separate concern. |
| Stock update/transfer | Scan package → load stock/job → accumulate expected unique barcodes → update status or validate full transfer → submit. | Transfer load/add events have different sequencing from stock update (Q08). |
| Forwarding | Select SMK/job → edit three forwarding sections or SMK fields → update forwarding. | Record and status semantics depend on backend configuration. |
| Boarding | Select job → edit status/times/evidence → update → send mail when images exist. | A later mail failure can follow a successful update (Q07). |
| Air freight | Select job → resolve configured air-freight type → edit status/AWB → submit. | Exact names include `FRIEGHT`; do not normalize wire values casually. |
| RTI/PDO | Filter records → inspect selected details → attach evidence → multipart status submission or document/mail request. | Multipart success can be based only on HTTP 200. |
| Leave | Load types/requests → submit applicant/date/reason → review with status/reviewer/remark. | Review rights and entitlements need backend/product confirmation. |
| Pre-alert | Select report filters → request PreAlertReport → open the successful response URL. | Generated contents and delivery remain backend-dependent. |
| IR | Search/filter → add or open report → validate draft → save → refresh; permitted users can delete. | Menu/ownership checks are client-side and separately documented. |
| Truck location | Load week → edit cells/done ticks → Save All; reorder is a separate immediate request. | This is a planning board, not verified real-time GPS tracking. |
| Bluetooth | Discover or reconnect → persist connected device → return to caller. | `printData` selects connection mode; printing must be traced through caller/helpers. |
| Support | Collect diagnostics → build temporary log file → multipart upload → remove temporary file. | Startup also attempts this automatically after initialization failure. |

Read the individual capability specs for the tested-form scenario descriptions
and source references. The [API matrix](api-interactions.md) records request
conventions; the [inventory](module-inventory.md) includes smaller dashboard tabs.

## Baseline maintenance

When changing a capability, re-read its source references and current tests.
Requirements describe externally visible behavior; architecture details and
endpoint catalogs are supporting evidence. Update both when an approved change
alters their facts. Do not infer whole-app correctness from a structurally valid
OpenSpec document.
