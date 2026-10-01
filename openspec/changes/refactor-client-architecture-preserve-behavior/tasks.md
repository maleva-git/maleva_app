# Tasks

## 1. Baseline and regression harness

- [x] 1.1 Record installed Flutter/Dart versions, run analyzer and existing tests before runtime edits, and save a sanitized verification record with inherited failures distinguished from new failures; verify command exit codes and affected test names are recorded.
- [x] 1.2 Add synthetic fixtures and characterization coverage for HTTP/Dio method, URL, headers, null/body and error semantics under `test/core/network`; verify against unchanged production paths with intercepted transport, including API-integration empty-success, 401 and 406 scenarios.
- [x] 1.3 Characterize DI factory/singleton lifetimes and session read timing, including stock repository construction-time company capture, legacy identity and AppSession driver identity; verify independent resolutions and changed preferences produce the original outcomes.
- [x] 1.4 Replace `test/widget_test.dart` counter expectations with an isolated shell/route smoke test and fake platform/startup dependencies; verify no live network calls, existing login route output and back-stack behavior. Record any minimal test seam introduced.
- [x] 1.5 Add a repeatable verification script using existing dependencies and document its invocation in `docs/architecture.md`; verify it runs the intended analyzer/tests and propagates failure exit codes.

## 2. Composition and compatibility boundaries

- [ ] 2.1 Extract feature registration functions from `lib/core/di/injection.dart` while retaining setup entry point, keys, ordering, parameters and lifetimes; verify registration inventory parity and DI characterization tests, and document composition ownership.
- [ ] 2.2 Add narrow injectable facades around selected existing HTTP and legacy Dio methods without changing their implementation policies; verify request/response characterization tests and document the distinct contracts in `docs/architecture.md`.
- [ ] 2.3 Add context/session adapters for selected features that delegate to their original sources at original read points; verify no preference-key changes, no new cache, no identity normalization and construction-time versus request-time parity.

## 3. Change Status and payment reporting

- [ ] 3.1 Characterize `lib/change_status_page.dart` with zero/nonzero master IDs, one company request, empty/missing/valid result lists and parse errors; verify title, selected ID, unchanged loading display and existing error presentation before extraction (finance-reports boundary).
- [ ] 3.2 Extract Change Status retrieval/parsing into an injected repository/loader, retaining constructor and caller compatibility; verify task 3.1 tests and exact legacy request/header/null semantics, and document the new ownership.
- [ ] 3.3 Add `paymentview` BLoC/repository characterization tests for initial auto-load, date/filter payloads, supported response shapes, empty results and exceptions; verify one initial request and existing state sequences under finance-reports scenarios.
- [ ] 3.4 Inject payment transport/context dependencies without changing filters, dates, models or display behavior; verify task 3.3 tests and representative widget output, and document the migrated boundary.

## 4. Stock update and transfer

- [ ] 4.1 Extend existing stock tests with invalid/duplicate scans, cancelled scanner, missing warehouse, full transfer, status-save/follow-up failure and controlled first-scan completion orders; verify current outcomes and the stock-management scenarios before extraction.
- [ ] 4.2 Inject scanner and transport adapters in stock repositories without changing BLoC event scheduling, company capture, URLs or messages; verify task 4.1 tests, API call order and null versus empty-body contracts, and document retained Q07/Q08 behavior.
- [ ] 4.3 Verify stock route ownership and repeated open/close behavior with fake scanner dependencies; confirm no additional subscriptions, loads or navigation effects and record the results with this cohort.

## 5. Bluetooth boundary

- [ ] 5.1 Characterize Bluetooth scan/connect streams, ten-second timeout, missing/remembered device, failure, persistence, page return and close cancellation using fake plugin streams; verify bluetooth-printing scenarios and preserve printer byte fixtures if the helper boundary is touched.
- [ ] 5.2 Inject plugin and remembered-device access into Bluetooth BLoC while retaining stream ownership, state order and caller printing responsibility; verify task 5.1 tests and document the adapter in `docs/architecture.md`.
- [ ] 5.3 Exercise scanner and Bluetooth connect/reconnect/print behavior on available target Android/iOS devices with a test printer; record actual device/plugin versions and results. Keep this task open if required hardware coverage cannot be executed.

## 6. Architecture adoption map and integration verification

- [ ] 6.1 Complete `docs/architecture.md` with dependency direction, state/lifecycle ownership and a migration matrix covering every family/common tab in the baseline module inventory; verify each entry is explicitly migrated, already suitable or retained with named debt, and no unimplemented cohort is described as complete.
- [ ] 6.2 Run the analyzer, selected regression tests and full suite after all batches; verify no newly introduced failures and record inherited failures separately. Recheck authentication, startup and navigation-permission constraints where shared wiring changed.
- [ ] 6.3 Build Android and iOS using existing configuration and execute representative route/UI checks; record actual successes and toolchain/device limitations, leaving unavailable required verification open rather than claiming platform parity.
- [ ] 6.4 Compare pre/post profile measurements for the selected screens on identical devices/workloads, including frames, memory, requests and subscription counts; record inconclusive or unavailable measurements honestly and investigate introduced regressions before completion.
- [ ] 6.5 Review the final diff for business-rule, permission, wire-contract, UI, native configuration, dependency and generated-file changes; verify scope parity, update the evidence record and rerun strict OpenSpec validation. Keep Q01–Q12 and 50,000-DAU backend capacity explicitly unresolved.
