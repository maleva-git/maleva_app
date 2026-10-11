# Tasks

Depends on `maleva-backend/openspec/changes/vessel-master-and-ptp-schedule`. Needs the owner's
approval before applying. The owner does the device testing.

## 1. Data

- [ ] 1.1 `lib/core/vessel_master/`: models (`fromJava`) and `VesselMasterApi` for suggest, similar and `PUT /api/sale-orders/{id}/vessel-links` (requirements "suggests vessels", "links the vessels"). Verify: model tests with Java-shaped JSON, including a vessel without calls and a call with estimated times.
- [ ] 1.2 `lib/core/vessel_changes/`: models and `VesselChangesApi` for list and dismiss; apply through the bulk update with only one leg's dates (requirement "Apply and dismiss"). Verify: unit test that an off-leg apply body has `companyId`, `saleOrderIds`, `oeta`, `oetd` and nothing else.

## 2. Sale order add screen (`sales-enquiries`)

- [ ] 2.1 Lock today's body: extend `test/features/transaction/sale_order_save_body_test.dart` with typed loading and off vessel names, SCNs and dates. Verify: `flutter test test/features/transaction/sale_order_save_body_test.dart` passes before the view changes.
- [ ] 2.2 Suggestions overlay under `txt_loadingvessel` / `txt_offvessel`, debounced, leg and port passed, plain field on failure. Verify: widget test (typing shows rows, failure shows none and keeps text).
- [ ] 2.3 Pick fills that leg's ETA and ETD (boxes ticked) and SCN, asks first when they differ, leaves ETB and the other leg alone. Verify: bloc tests (empty leg filled, typed dates ask, ETB untouched).
- [ ] 2.4 "Did you mean" on leaving the field: same is silent, close prompts once per text. Verify: bloc test (keep my spelling not asked twice).
- [ ] 2.5 After save, send links with the saved id (or `editId`), picked ids dropped after an edit, failure logged only. Verify: bloc test (link throws, `savedMessage` is still "Created Successfully"); 2.1 still passes.

## 3. Vessel changes screen (`vessel-changes`)

- [ ] 3.1 `VesselChangesCubit` and `VesselChangesPage` at `/vessel_changes`: My jobs / My team, groups, side-by-side times, select, update, refused jobs named, dismiss, SCN copy, empty and error states. Verify: cubit and widget tests (group shown, apply reloads, refused named, error shows retry).

## 4. Notice tap (`notifications-support`)

- [ ] 4.1 `features/vessel_changes/push_route.dart` and the combiner in `mail_monitor/mine/push_route.dart`: `VESSEL_ETA_CHANGED` opens `/vessel_changes`; local notification payload too. Verify: unit tests of `routeForPush` and `routeForPayload` (new type routes, `MAIL_UNREAD` and `FORWARDING_*` unchanged).

## 5. Verify

- [ ] 5.1 `flutter analyze` and `flutter test`. Verify: no new analyzer errors; new tests pass (the known `bluetooth_page_test` failure is not this change).
- [ ] 5.2 Owner's device test: type and save a PTP vessel, pick a call, receive a vessel notice, tap it, apply. Verify: owner confirms.
