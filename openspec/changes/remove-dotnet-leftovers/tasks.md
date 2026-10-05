## 1. Client

- [x] 1.1 Remove the certificate override, the .NET address, token, wrapper, marker and duplicate push-token code, the commented credentials, and five unused packages; keep Firebase, notifications and Bluetooth printing (used by the Java app). Verify: analyzer 0 errors, warnings equal to the baseline; the lock file only loses packages.
- [x] 1.2 Full suite. Verify: 316 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 Build and install a release on Android and iOS (dependency change): sign in, receive a push, print a test page, open an image.
- [ ] 2.2 Rotate the Razorpay live key that was in source history, if it is still active.
