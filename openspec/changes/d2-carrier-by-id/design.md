## Context

Backend rules (CarrierResolver): the server decides the carrier kind from the truck's `unitKind`; a truck number must
belong to the picked subcontractor row; a driver id must be the company's; the billing company is the truck master's
supplier; a save that sends no ids keeps the row's ids. So the app only needs to send the two ids it picked.

## Decisions

1. **One sheet for all layouts.** `OutsideCarrierSheet` (bottom sheet) is opened from `AssignPicker.driver` when the row's
   truck `unitKind` is SUBCONTRACTOR / HIRED_TRUCK. It uses `showPickerSheet` for the lists and two small add forms.
   Phone, tablet portrait and the tablet board all go through `AssignPicker`, so one change covers them.
2. **Cubit op** `assignOutsideCarrier(uids, vehicleId, plateNo, driverId, driverName)` in `plan_row_ops.dart`: sets the
   ids on the `PlanLine`s and the driver name (`driverRefid` = the outside-driver placeholder the app already uses).
3. **Models:** `PlanLine` gains `outsideVehicleRefId`, `outsidePlateNo`, `outsideDriverRefId`, `carrierKind`
   (`fromEdit` reads them; `copyWith`); `TruckOption` gains getters `unitKind`, `supplierRefId` from `raw`.
4. **Payloads:** `planning_save_payload.dart` adds the two ids only when > 0 (old payloads unchanged — test);
   `planning_transfer.dart`, `rti_from_planning_service.dart`, `planning_rti_batch.dart` carry them; `rti_form.dart`
   / `rti_mapper.dart` / `rti_save_payload.dart` keep and send them when > 0.
5. **API client** `OutsideCarrierApi(dio, companyId)`: `vehicles(truckRefId)`, `addVehicle(truckRefId, plateNo, sizeClass)`,
   `drivers()`, `addDriver(name, mobile, idType, idNo)`; registered in `auth_injection.dart` like `TruckApi`.
   Sizes: the existing truck-order size list (1TON … 40FT, SPECIAL).

## Risks

- Personal data (driver mobile / IC): shown in the sheet only, never logged (no `debugPrint` of the rows).
- A row planned on the web and saved from an old app version keeps its ids (server rule), so mixed versions are safe.
