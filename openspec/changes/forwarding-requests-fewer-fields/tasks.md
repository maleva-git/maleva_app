## 1. UI
- [x] 1.1 Edit page: keep Documents received, Draft created, C Number; remove the later steps, their references, the Seal section and the employee lookup. Verify: widget test in `test/features/forwarding_requests/forwarding_requests_test.dart`.
- [x] 1.2 Detail page and card: remove the Submitted / Approved / Released / release number / seal rows.
## 2. Verify
- [x] 2.1 Pass-through and ladder tests in `test/core/forwarding_request/forwarding_request_api_test.dart`.
- [x] 2.2 `flutter analyze` clean on the changed files; `flutter test`.
- [ ] 2.3 Owner: device test on a phone and a tablet.
