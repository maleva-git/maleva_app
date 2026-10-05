## 1. Client

- [x] 1.1 Delete the legacy .NET client, `ApiClient`, `JavaRoute`, the JSON transports and `LegacyApiException`; reduce `LegacyApiRepository` to its picker helpers; drop the unused stock-update transport; DI and tests updated. Verify: analyzer 0 errors, one warning fewer than the baseline.
- [x] 1.2 Full suite. Verify: 315 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 Run the app against a server with the .NET API switched off; open each screen once.
- [ ] 2.2 Decide where `/Upload/...` file links point once .NET is retired.
