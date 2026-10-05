## 1. Cleanup

- [x] 1.1 Remove the 15 unused models and their exports, `MasterApi.getWarehouses`, and stale comments. Verify: analyzer 0 errors, no new warnings; no `/api/*App/` path or old client left in `lib` or `test`.
- [x] 1.2 Full suite. Verify: 316 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).
