## 1. Client

- [x] 1.1 `LeaveApi` and DI; repository, models and bloc on Java; the unused .NET helper removed. Verify: `test/core/employee/leave_api_test.dart`; analyzer 0 errors, no new warnings.
- [x] 1.2 Full suite. Verify: 319 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: request leave as a driver and as an employee; approve and reject from the admin and employee approval tabs; check the driver sees only their own.
