## Why
Owner 2026-10-28: the driver must see today's jobs; two trips a day and tomorrow's RTI already made must be clear. Uses the
new shared Java API `GET /api/rti-masters/trips` (backend change `driver-today-trips`), read as it is.

## What Changes
- New first driver tab **Today** (`features/today_trips`): chips Yesterday · Today · Tomorrow with counts; trips on their
  real day (first stop's date), in time order, "Trip 1 of 2"; each stop: time, Pickup / Delivery / seal… , place, job,
  customer, quantity, PIC or agent with **Call** (phone numbers read from the PIC text) and **Map** (Google Maps search);
  buttons **Photos / status** (the existing RTIStatusPage, per job), **RTI PDF** (report ticket), **Time on site**
  (RtiStopTimes). Pull to refresh.
- Driver tabs: Today, Fuel, Maintenance, Truck License, Salary, Driver Leave.
- `RtiApi.trips(from, to)`; models `DriverTrip`, `TripStop`, `TripJob` (`fromJava`).
- The backend's new pushes (DRIVER_RTI_NEW / CHANGED / REMOVED) show as normal notifications; opening the app lands on the
  driver dashboard, whose first tab is Today.

## Clear totals (owner 2026-10-28: "clearly show the correct total pick places and delivery, neat")
59 of 415 RTIs (Sept 2026) list the same pickup place on several rows (one per job), up to 15 rows. The card now groups:
- a day summary under the chips: trips, "Pick up N jobs at M places", "Deliver N jobs at M places", forwarding stops;
- on each trip three boxes (PICK UP / FORWARDING / DELIVER) and three sections, each place ONCE (same place = same letters
  and digits, case / spaces ignored), numbered, earliest time first, with its jobs, customers, quantities, PIC (Call), Map;
- the route line "WESTPORT (+1) → KLANG" shows how many more places there are.
Helpers `groupStops`, `countTrips`, `jobsAtPlaces`, `placeKey` (tested: jobs counted once, places counted once).

## Next stop, what changed + Got it, no signal, Bahasa Malaysia (owner 2026-10-28)
- NEXT banner on Today: the next place by time (30 min grace), with Map and Call; places behind us grey.
- Yellow box "Changed by the office" with the lines the office changed since the driver's last Got it (from the server),
  or a blue "New trip — please check"; button **Got it** → `PUT /api/rti-masters/trips/{id}/seen`.
- No signal: the last answer is kept on the phone (SharedPreferences) and shown with "No signal — trips saved at …".
- EN / BM button: every word of the tab (`today_trips_text.dart`); kept on the phone. The Malay texts are a first version
  for the owner to check.
- Tests: driver_trip_test (8), today_trips_tab_test (1, phone width 360, EN + BM, no overflow).
