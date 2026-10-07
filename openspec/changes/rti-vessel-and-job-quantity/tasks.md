## 1. Model and data

- [x] 1.1 `RtiJobInfo` rule, vessel choices and quantity for a vessel.
- [x] 1.2 `RtiJobRow.vesselName` / `jobQuantity` (display only); `RtiStop.vesselName` / `jobQuantity`.
- [x] 1.3 Mapper: sale-order preview, stored values on saved lines, planning fill, stop read; the save sends the stop fields.
- [x] 1.4 Bloc: `RtiStopVesselPicked`; new stop with the single vessel; planning push reads the sale orders.

## 2. Screens

- [x] 2.1 Job card and tablet job grid show Vessel Name and Job Qty.
- [x] 2.2 Stop card and tablet stop grid: Vessel Name picker and Job Qty field.

## 3. Verify

- [x] 3.1 `flutter analyze lib/features/rti`; `flutter test test/features/rti` (`rti_vessel_test.dart` added).
- [ ] 3.2 Device check by the owner after the backend script and deploy: look up a job, push from Planning, pick a vessel on a stop, save, reopen, revise.
