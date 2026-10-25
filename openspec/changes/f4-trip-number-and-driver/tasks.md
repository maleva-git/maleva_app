## F4 app — trip number and regular drivers (follows the web)

- [x] 1 `data/plan_trips.dart` (pure port of the web's `planTrips.ts`) + `test/features/planning/plan_trips_test.dart`
      (the web's cases).
- [x] 2 `PlanLine.tripNo` (0 = none) / `tripSource` ('' = none) — `fromEdit` reads `TripNo` / `TripSource`, `copyWith`;
      clearing the truck clears the trip (`clearTruck`).
- [x] 3 `PlanCubit.editTrip(uid, value)` (`plan_row_ops.dart`, `guardWrite`, changed rows marked edited); cubit test.
- [x] 4 `planning_save_payload.dart`: `tripNo` + `tripSource` on every row (`NONE` without a trip); payload test updated.
- [x] 5 Tablet board: TRIP column first after the frozen TRUCK (All, Assign presets) — `widgets/trip_picker.dart`
      (tap → Trip 1 … 12 / No trip; a menu, not a text box, so the filled rows refresh while the planner edits).
- [x] 6 Phone / portrait: "Trip n" chip on the job card (`+ Trip` when none); Trip beside Remarks in the job detail.
- [x] 7 Regular drivers: `RegularDriver` model, `PlanningRepository.regularDrivers()` (`GET /api/planning/regular-drivers`,
      `Data1` as it is), loaded with the lookups (failure = plain list); `AssignPicker.driver` puts them first with
      "regular · assigned · last RTI · n RTIs"; `regular_driver_test.dart`.
- [x] 8 Create All RTI hint: "This trip comes from the TRIP column (or REMARKS)".
- [x] 9 `flutter analyze` planning clean (the 666 project issues are older files, none in planning); `flutter test`
      1,101 / 1,101 pass. Owner tests on the simulator / device.
