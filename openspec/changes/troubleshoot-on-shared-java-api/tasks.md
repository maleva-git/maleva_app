## 1. Client

- [x] 1.1 Report a Problem on `AttachmentsApi`; startup crash kept on the phone and sent after sign-in / restore / the next report; the .NET constant removed. Verify: `test/features/troubleshoot/applog_api_test.dart`, network tests; analyzer 0 errors, no new warnings.
- [x] 1.2 Full suite. Verify: 310 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: send Report a Problem as an employee and as a driver (check `Upload/<company>/Troubleshoot/<id>/`); force a startup crash, then sign in and check the kept log arrives once.
