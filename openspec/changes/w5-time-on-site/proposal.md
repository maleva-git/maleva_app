## Why
Fleet W5 "Time on site" (owner 2026-10-28: "in driver if need change also if need you can add"). GPS gives arrival
and departure; only the driver knows when loading starts, so waiting can be split from loading. Shared Java API
(backend change `w5-time-on-site`); no backend reshaping for the app.

## What Changes
- `RtiApi.siteVisits(rtiId)` → `GET /api/site-visits` and `RtiApi.siteVisitWorkStart(kind, stopId)` →
  `PUT /api/site-visits/work-start`; model `SiteVisit.fromJava` reads the Java fields as they are.
- RTI preview: card "STOPS" (`RtiStopTimes`): each pickup / delivery with "Arrived 09:12 · Left 11:40 · 2 h 28" or why
  there is no time; for the driver one button "Start loading" / "Start unloading" while no start is saved and the truck
  has not left. The first tap counts. Hidden when the server answers no stops or fails.
- No phone location, no new permission, no change to the PickUp / Delivery status screen.

## Billing proof (owner 2026-10-28)
The card shows the driver's next tap, in order: **Check in at gate** → **Start loading / Start unloading** → **Done**
(`RtiApi.siteVisitTap`, `PUT /api/site-visits/check-in | work-start | done`). The server checks the check-in against
the truck's GPS and may refuse it ("The truck is 3.2 km from this place…"); the message is shown as it is. A check-in
not at the gate shows "(not at the gate)" in red. Tests: 4.
- Buttons only when `GET /api/site-visits/settings` says `driverTaps: true` (off until the owner tells the drivers);
  the times are shown either way.
