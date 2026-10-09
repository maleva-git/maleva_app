Depends on `maleva-backend/openspec/changes/forwarding-requests` and `forwarding-request-followup` (deployed, SQL run).

## 1. Data
- [x] 1.1 `lib/core/forwarding_request/`: models (`ForwardingRequest.fromJava`, ticks with the ladder, filter) and `ForwardingRequestApi` (create, forSaleOrder, search, saveTicks, cancel). Verify: `test/core/forwarding_request/forwarding_request_api_test.dart` (model from Java JSON, ladder, bodies, URIs, a 400 as `ApiFailure`).
## 2. UI
- [x] 2.1 Cubits, list body and page, card, filter page, edit page (five ticks, references, seal pickers, Save, cancel), detail page, Request FW sheet. Verify: `test/features/forwarding_requests/forwarding_requests_test.dart` (cubits, push routing).
- [x] 2.2 Entry points: sale order "REQ FW" button, dashboard tabs (Sales / Forwarding Agent / Air Freight), drawer cases, GoRoutes, push routing. Verify: `flutter analyze`; device test by the owner (requirement "Entry points").
## 3. Verify
- [x] 3.1 `flutter analyze`, `flutter test` for the new tests and the mail monitor tests.
- [ ] 3.2 Owner: device test on a phone and a tablet; add the two server menu rows ("Forwarding Requests", "My Forwarding Requests") if the drawer entries are wanted.

## Result (2026-10-09)
- `core/forwarding_request/` (models, API), `features/forwarding_requests/` (two cubits, list body + page, card, filter page, edit page, detail page, Request FW sheet, push routing, injection). Entry points: sale order "REQ FW", dashboard tabs (Sales "MY FW REQ", Forwarding Agent and Air Freight "FW Requests"), drawer cases, GoRoutes `/forwarding_requests` and `/forwarding_requests/mine`, push taps.
- Checks: `flutter analyze` 0 errors (pre-existing warnings only); `flutter test` forwarding requests 14 passed, mail monitor 5 passed. Device test by the owner.
