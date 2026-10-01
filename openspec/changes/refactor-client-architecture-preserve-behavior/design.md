# Design

## Context

See proposal.md for motivation and scope. This is source-inspected Flutter/Dart code, not a web/TypeScript project. `pubspec.yaml` declares flutter_bloc, get_it, dio, http, go_router and provider. No new state-management dependency is needed.

Verified findings:

| Evidence | Architectural consequence |
| --- | --- |
| `lib/core/di/injection.dart` centralizes many registrations, including BLoC factories taking BuildContext. | Feature wiring and UI ownership are entangled; extract registration without changing lifetimes. |
| `lib/features/ir_report/ir_report_injection.dart` already composes repositories, data sources and BLoCs. | Reuse a pattern already understood by this codebase. |
| `lib/change_status_page.dart` resolves a repository through GetIt, reads company globals, fetches and parses petty-cash data inside State. | Data access cannot be tested independently of the widget. |
| `ApiClient`, `DioClient` and `LegacyApiRepository` use different headers, timeouts and error mappings. | A wholesale client replacement would change contracts. |
| `PreferencesAppSession.employeeId` maps driver sessions to zero; legacy global reads need not do so. | A single replacement session getter could change identity and permissions. |
| Bluetooth BLoC uses plugin streams directly and already cancels subscriptions in close. | Add a fakeable platform boundary while preserving existing ownership. |
| Stock transfer dispatches first-scan load/add separately. | Changing event transformers or adding an await is a behavioral fix, not extraction. |
| `test/widget_test.dart` expects a sample counter; focused IR, truck-location and stock tests exist. | Establish actual baseline results and replace irrelevant smoke coverage. |
| iOS Podfile declares 15.0 but post-install assigns pods 13.0 and excludes arm64 simulator. | Record compatibility questions; no build failure is established by these settings alone. |

Configuration lives in `core/config/app_config.dart`; routes use GoRouter alongside imperative navigation. Startup initializes Firebase, preferences and DI and has support-upload failure handling. None of these paths may be rewritten opportunistically. No runtime profile, backend load test or physical-device validation was performed for planning.

## Goals / Non-Goals

**Goals:** Clear dependency direction for migrated flows; testable data/platform boundaries; explicit state ownership; safe incremental adoption across the existing module inventory.

**Non-Goals:** Complete folder reorganization, domain/use-case classes for every method, replacing all globals at once, combining similar screens, changing UI, native build settings, security policies or existing failure semantics. Q01–Q12 are not resolved by refactoring.

## Decisions

### 1. Feature ownership with small layers

For migrated features use `presentation` (widgets and BLoCs), `data` (repositories, mappers and remote/platform adapters), and a feature registration function. Add a `domain` interface only when it separates a real dependency or policy. Retain existing public imports and constructors through forwarding exports/wrappers when paths change; prefer no folder moves in the first batch.

Dependency direction: page → BLoC/controller → repository → existing transport/platform adapter. Composition creates these dependencies. Repository code must not acquire a new dependency on a widget or BuildContext. Simple local visual state may stay in State; moving every boolean to BLoC adds no value. Do not migrate existing domain-layer features merely for naming consistency.

Alternative rejected: whole-app clean-architecture rewrite. Its breadth increases regression risk without establishing better behavior.

### 2. Keep BLoC and GetIt, clarify ownership

GetIt remains the composition mechanism. Move registrations into feature functions called by the existing setup entry point, preserving order, lazy/singleton/factory distinctions and factory parameters. Migrate service-locator lookups out of the selected feature runtime logic through constructor injection. Route factories and legacy compatibility entry points may still resolve dependencies.

BlocProvider owns newly created route BLoCs and closes them; borrowed BLoCs retain existing owners. Keep constructor-triggered loads and route-triggered events at their current call sites so extraction does not double-fetch. Existing context-dependent registrations outside the selected cohort stay as compatibility debt.

Provider is not introduced as a second owner of BLoC state. BlocProvider/RepositoryProvider already cover feature dependencies. Preserve routing names, push/pop versus replacement, arguments, menu checks and back stack; do not migrate Navigator pushes into GoRouter in this change.

### 3. Compatibility boundaries, not transport normalization

Introduce narrow injectable facades for the existing HTTP and legacy Dio methods used by the selected cohorts. Production facades delegate to existing methods; tests use synthetic responses. Keep separate contracts for each transport. Do not change `ApiClient.getString` from POST based on its name.

Contract fixtures compare HTTP method, complete path/query, headers, body keys/casing, null versus empty object, timeout, multipart metadata where affected, parsed result and error mapping. Preserve call order and follow-up writes. Never introduce retry, caching, cancellation or deduplication as part of dependency extraction.

Session adapters delegate reads/writes to each caller's existing source at the same time. No copied session cache and no automatic use of the driver-to-zero AppSession policy for legacy features. Existing auth/session classes and preference keys remain compatible.

Alternative rejected: one universal Result type/client/session policy now; it would hide the meaningful differences documented in Q01, Q02, Q04 and Q07.

### 4. Bounded migration cohorts

| Cohort | Implementation and preservation boundary |
| --- | --- |
| Change Status | Extract petty-cash retrieval/parsing into an injected loader/repository. Retain public `ChangeStatusPage(masterId:)`. Nonzero masterId triggers the existing company-wide request once; zero triggers none. Do not change the request to filter by masterId. Preserve the first-element parsing, model key spellings, null/missing-list handling and existing error presentation. The UI still only displays its title and selected ID; do not add an editor or loading indicator. |
| Payment reporting | `common_tabs/paymentview` retains its BLoC, initial loading, filters, sorting and repository outcomes. Inject the current context and transport boundaries, without substituting new financial rules. |
| Stock update/transfer | Retain events, states, validation messages, scanner return handling and existing scan scheduling. Inject scanner/transport dependencies at the repository boundary. Preserve status-save then boarding-officer update ordering and transfer preconditions. |
| Bluetooth | Inject plugin operations/streams and remembered-device access. Retain BLoC subscription ownership, ten-second scan, auto-connect rules, BlueTooth persistence, messages, page return and printer bytes. Do not make connection automatically send a print job. |

Retain all other feature implementations. Produce `docs/architecture.md` with a migration matrix referencing every family/common tab in `openspec/baseline/module-inventory.md`: migrated, existing suitable boundary, or retained with named debt. Sales/enquiry, planning/vessel, forwarding/boarding/airfreight, RTI/PDO, fleet, people, master data and remaining reports are follow-up batches, not silently marked complete. IR/truck-location serve as examples and regression checks, not targets for redesign.

### 5. Behavior evidence and quality checks

Before editing runtime code, run the existing analyzer/tests and record actual failures separately from new regressions. Add characterization tests while the old implementation still runs, using fakes and synthetic identities. Capture request traces, state/event sequences, preference effects and route outcomes for changed boundaries. Tests documenting inconsistent behavior are temporary compatibility evidence, not an endorsement of that behavior.

For Change Status cover zero/nonzero IDs, successful/missing/empty data and thrown parse errors; retain the difference between errors swallowed by the legacy transport and errors reaching the widget. For payment cover construction, filter reload and failure results. For stock cover duplicate/invalid scans, missing destination, full transfer and partial follow-up failure; control both completion orders of the existing first-scan race without redefining which should win. For Bluetooth cover streams, connection failures, persistence, one-time page effects and subscription disposal.

Replace the counter test with an isolated shell/route smoke test using fake startup dependencies; it must not contact Firebase or production services. Compare representative widgets at fixed sizes and locally available fonts. No UI extraction may alter text, spacing, loading state or accessibility semantics. New failures after disposal must not be introduced; any pre-existing lifecycle bug needing observable cancellation/behavior changes is separately reported.

Use existing flutter_test, bloc_test and mocktail. Add a repeatable Flutter verification script or CI job using the established project SDK, without dependency upgrades. Analyze changed files and the full app, run relevant tests then the suite once; distinguish inherited failures from refactor regressions. Android/iOS build and device checks must report actual availability, not assumed success.

### 6. Performance and platform evidence

Measure selected screens in profile mode before/after on the same device and synthetic workload: frame timings, memory, request count and subscription count across repeated open/close. No performance bottleneck is proven by file length or DAU. Any statistically unclear difference is inconclusive. Fix regressions introduced by this change; propose further optimizations separately if they affect request/loading behavior.

50,000 DAU requires a separate backend workload model (peak active sessions, per-session requests, payloads, slow endpoints and database limits). No backend source or load-test environment is available in this review. Android/iOS parity requires target hardware, scanner and printer checks; preserve native manifests, permissions and build settings now.

## Risks / Trade-offs

- Global/session reads may be time-sensitive → delegate at original read points; test preference changes between calls.
- Moving initialization can duplicate requests → compare exact call counts and route lifecycle traces.
- Legacy context/error behavior can leak across layers → isolate a narrow compatibility wrapper; do not redesign messages or failure handling.
- Async extraction can alter scanner races or Bluetooth stream ordering → retain scheduling and test controlled completion orders; defer behavioral corrections.
- Broader DI edits affect unmigrated features → preserve all registration keys and verify representative resolution plus existing suite.
- Hardware/build tooling may be unavailable → record unverified checks and keep related verification tasks open; do not claim device compatibility.
- Keeping distinct adapters retains technical debt → name it in the migration matrix and remove only through separately reviewed changes.

## Migration Plan

After explicit apply authorization: establish baseline and characterization fixtures; extract composition and compatibility adapters; migrate Change Status/payment, then stock, then Bluetooth; verify each batch before the next. Keep each batch independently reviewable with no storage migration or API deployment dependency. Roll back only the relevant refactor batch if parity fails; preserve unrelated user work. Document actual evidence and outstanding checks before calling implementation complete.

## Open Questions

Target device/printer models and a backend load-test environment remain needed for hardware/capacity verification. They do not change this refactor's behavior contract; unavailable evidence must remain explicitly unverified. Baseline Q01–Q12 require separate product/backend decisions before any behavior-changing follow-up.
