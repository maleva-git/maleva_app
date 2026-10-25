## Why

Fleet sprint F4 is built on the backend and the web (2026-10-24; backend change
`maleva-backend/openspec/changes/f4-trip-number-and-driver`, web change
`maleva-front-end/openspec/changes/f4-trip-number-and-driver`). Plan rows now carry a **trip number** (`TripNo` 1–20,
same number = same truckload of that truck, "COMBINE" = the same number) and **how it was set** (`TripSource`: TYPED,
FILLED, REMARKS, AI, BACKFILL — kept for ML). Create All RTI and the truck-load chips group by it; a row without one
still reads "1ST TRIP" from Remarks. The driver is saved by id (typed names that match exactly one driver are linked
by the server), and `GET /api/planning/regular-drivers` gives each truck's regular drivers.

The owner wants the app to follow the same logic (2026-10-24). Today the app sends no trip fields, so the server keeps
a row's trip (safe), but planners cannot see or set trips in the app and the driver picker does not show the truck's
regular drivers.

## What Changes

- **Read** `TripNo` / `TripSource` from `/api/planing/edit` into `PlanLine` (`tripNo`, `tripSource`).
- **Set the trip** in all three layouts (phone, tablet portrait, tablet board), the web's rule exactly:
  typing a trip on a row fills the **blank** rows under it **on the same truck** (shown grey, FILLED) until the next
  row the planner wrote; clearing it refills those rows from the trip above; a row with no truck has no trip; a row
  with no number but "2ND TRIP" in Remarks shows that number in grey italic (shown, not saved — the server reads Remarks).
  - Tablet board: a narrow **TRIP** column right after the truck (the web: REMARKS · TRIP · TRUCK).
  - Phone / portrait: the trip on the job card ("Trip 2", grey when filled) and a TRIP field next to Remarks in the
    job detail.
- **Plan save** always sends `tripNo` and `tripSource` (`NONE` when the row has no trip), as the web does — the server
  then knows the app keeps trips.
- **Driver picker:** the row's truck's regular drivers first (Driver Master's assigned driver, last RTI driver, most
  used), with a "regular · last RTI" subtitle; the list below unchanged. Shared endpoint, no mobile-only API.
- **Create All RTI** in the app already shows the server's groups ("Trip 2" pill); its hint text changes from
  "written in REMARKS" to "the TRIP column or REMARKS".

## Not changed

- Push RTI / Create RTI (ticked rows → one RTI; owner 2026-10-24: no notice), the RTI form, outside carriers (D2),
  the truck-load chips (the app has none yet).
- No backend change (rule: the app reads the Java API as it is).
