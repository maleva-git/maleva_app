# Proposal

## Why

MALEVA already uses Flutter, BLoC, GetIt and feature folders, but dependencies cross UI, global state and network boundaries. Improve testability and ownership incrementally while preserving the working app, starting with shared composition and representative finance, stock and Bluetooth flows.

## What Changes

- Split dependency registration into feature modules while retaining registration types, initialization order and lifetimes.
- Introduce injectable compatibility boundaries for existing HTTP/Dio calls, session reads and Bluetooth access; preserve their distinct behavior.
- Extract data loading/parsing from `lib/change_status_page.dart`, retaining its constructor, screen, request trigger and response/error behavior.
- Use payment reporting, stock update/transfer and Bluetooth as bounded migration batches; add regression coverage before moving their logic.
- Document the target structure and a module migration inventory for the remaining app. Existing well-separated IR and truck-location implementations provide local examples.
- Replace the unrelated counter widget test with meaningful isolated app coverage and establish repeatable checks.

There is no intended user-visible change. This is a foundation refactor, not a claim that every legacy module has been migrated. Wider sales/planning/dashboard migrations require separately reviewed batches using the same architecture.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. `skip_specs: true` explicitly applies because observable requirements remain unchanged. Existing scenarios are regression constraints, not requirement deltas.

## Impact

Implementation touches composition in `lib/core/di`, adapter boundaries in `lib/core/network` and session utilities, route construction where needed for the selected pages, `lib/change_status_page.dart`, payment reporting, stock update/transfer, Bluetooth, tests, and architecture documentation. Existing capabilities affected internally: `api-integration`, `finance-reports`, `stock-management`, `bluetooth-printing`; `authentication`, `app-startup` and `navigation-permissions` constrain shared compatibility checks.

No dependency upgrades, new state-management package, native configuration change, generated output edit or backend change is proposed. Keep BLoC; Provider is already declared but no additional Provider-based state owner is justified.

Clarifications Q01–Q12 remain open. In particular, do not unify manual/startup roles, token headers, preference keys, error-to-empty/success outcomes, scanner event sequencing or printer responsibilities. TLS policy, credential storage, authorization fixes, notification behavior, UI redesign, retries, pagination and offline/cache behavior are separate behavior changes requiring their own proposals.

50,000 daily active users is a planning target, not concurrent load. Client profiling can identify regressions; backend capacity, peak concurrency and server authorization remain unverified and cannot be certified by this refactor.
