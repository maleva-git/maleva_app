## 1. Core
- [x] 1.1 `core/fleet/outside_carrier_api.dart` + registration in `auth_injection.dart`; test with the QueueAdapter (URI, query, body).
- [x] 1.2 `TruckOption.unitKind` / `isSubcontractor` / `takesOutsideCarrier` getters from `raw` (no `supplierRefId`: the server takes the billing company from the truck master); `PlanLine` carrier fields (`fromEdit`, `copyWith`).

## 2. Planning
- [x] 2.1 `OutsideCarrierSheet` + add truck number / add driver forms.
- [x] 2.2 `AssignPicker.driver` opens the sheet for SUBCONTRACTOR / HIRED_TRUCK rows; cubit `assignOutsideCarrier`.
- [x] 2.3 Row shows "truck number · driver" (phone, tablet portrait, board).
- [x] 2.4 `planning_save_payload.dart` sends the ids only when > 0; tests (own row unchanged; outside row sends ids).

## 3. RTI
- [x] 3.1 `planning_transfer.dart`, `rti_from_planning_service.dart`, `planning_rti_batch.dart` carry the ids. (Batch: no app change — the server copies the plan row's carrier, `PlanningRtiBatchServiceImpl.copyPlanCarrier`.)
- [x] 3.2 `rti_form.dart` / `rti_mapper.dart` / `rti_save_payload.dart` keep and send them when > 0; tests.

## 4. Checks
- [ ] 4.1 `flutter analyze --no-pub` (no new issues) and `flutter test --no-pub` green; owner tests on device.
- [x] 4.2 Record the outside-driver id 36 vs 22 in `openspec/baseline/clarifications.md`.
