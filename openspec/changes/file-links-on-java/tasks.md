## 1. Client

- [x] 1.1 `fileUrl`; the 12 `ApiConstants.port` links and `AppGlobals.imagepath` (now a getter) on the Java host; `ApiConstants` and `AppGlobals.port` removed. Verify: `test/core/files/file_links_test.dart`; analyzer 0 errors, warnings equal to the baseline; a wide scan finds no other .NET-host link.
- [x] 1.2 Full suite. Verify: 319 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 Production: confirm `FILE_UPLOAD_DIR` is the IIS site's Upload folder (an image uploaded on the old .NET site opens from the Java host).
- [ ] 2.2 On a test environment: open images / documents on Spare Parts, Spot Sale, Summons, Job Orders, PDO, TransportDB, Job Status Update, RTI Status, Air Freight, Forwarding, Stock-in; check an RTI-status email's photo links open.
- [ ] 2.3 Decide whether `certificate_policy.dart` should stop accepting invalid certificates now that no .NET host is called.
