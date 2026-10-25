## Context

Backend rules (`PlanRowTrip`, `PlanTrips`): a save that sends no `tripSource` keeps the row's trip; `NONE` clears it;
1–20 only; no truck = no trip; the TRIP column wins over Remarks. The web's pure helper is
`maleva-front-end/src/features/Planning/utils/planTrips.ts` (`applyTripEdit`, `tripInRemarks`, `tripCell`,
`tripForSave`) with its tests; the app ports it 1:1 so both screens behave the same.

## Decisions

1. **Pure Dart port** `lib/features/planning/data/plan_trips.dart`: `parseTrip`, `tripInRemarks` (same regex as the
   backend's `TripMarkers`), `applyTripEdit(List<PlanLine>, uid, value)`, `tripCell(PlanLine)` (value + kind
   typed / filled / remarks / none), `tripForSave(PlanLine)`. Rows are in the plan's order (`state.rows`); "same truck"
   = the same `truckRefid` > 0.
2. **Model** `PlanLine`: `tripNo` (int?, null = none), `tripSource` (String?); `fromEdit` reads `TripNo` / `TripSource`;
   `fromSearch` leaves them null; `copyWith` / `plan_line_copy.dart` carry them. Clearing the truck clears the trip
   (`plan_row_ops.dart` truck ops).
3. **Cubit op** `editTrip(uid, String value)` in `plan_row_ops.dart` → `applyTripEdit`, guarded by `guardWrite()`.
4. **Save payload** `planning_save_payload.dart`: `...tripForSave(row)` → `tripNo`, `tripSource` on every row (test:
   old fields unchanged, the two new keys present).
5. **Layouts:** board column `'trip': BoardColumn('trip', 'TRIP', 56)` placed first in the presets that show the driver
   (All, Assign), editable like SORT (a small numeric field); job card shows a "Trip n" chip; job detail gets a TRIP
   number field beside Remarks.
6. **Regular drivers:** `PlanningRepository.regularDrivers()` (`GET /api/planning/regular-drivers?companyId`, read
   `Data1` as it is) loaded with the plan's lookups; `AssignPicker.driver` orders the options (regular first, most
   reasons first) and sets the subtitle "regular · assigned · last RTI · 63 RTIs"; the expiry subtitle stays when present.

## Risks

- Mixed versions: an old app save keeps the trips (server rule); a new app save sends them. Safe both ways.
- Driver names are company staff, shown as today; nothing logged.
