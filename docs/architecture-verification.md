# Architecture refactor verification

Change: `refactor-client-architecture-preserve-behavior`.

## Before implementation — 2026-10-01

- Flutter 3.47.5 stable; Dart 3.13.4.
- `flutter test --no-pub`: exit 1, 75 passed, one failure in `test/widget_test.dart` (`Counter increments smoke test`). The existing test expects sample-counter behavior from the real MALEVA app.
- `flutter analyze --no-pub`: exit 1, 836 existing diagnostics. These are a baseline, not introduced by this refactor.
- No production API calls or device/printer tests performed.

## Implementation checks

Transport characterization: 5 tests passed against unchanged application code. HTTP fixtures use a loopback server; Dio uses an in-memory adapter. Session/DI characterization: 3 tests passed, including construction-time company capture and driver identity differences. Task checkboxes describe verified progress, not merely files written.
