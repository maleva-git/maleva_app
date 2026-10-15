Depends on `maleva-backend/openspec/changes/forwarding-request-date-per-form`.

## 1. Data
- [x] 1.1 `ForwardingRequestItem` and the form-estimate helpers in `forwarding_request_models.dart`; `ForwardingRequestApi.create(items:)` sends `items`. Verify: `test/core/forwarding_request/forwarding_request_api_test.dart` (body shape, defaults, carry-over, ready, order).
## 2. UI
- [x] 2.1 `RequestForwardingCubit.create(items:)`; Request FW sheet: one date-time picker per ticked form, Request disabled until all have a date. Verify: `test/features/forwarding_requests/forwarding_requests_test.dart`.
## 3. Verify
- [x] 3.1 `flutter analyze` (no errors, nothing in the changed files), `flutter test` (forwarding tests pass).
- [ ] 3.2 Owner: device test on a phone and a tablet against a backend with `items` support.
