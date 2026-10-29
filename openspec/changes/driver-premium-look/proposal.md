# driver-premium-look — premium design for the driver dashboard (owner 2026-10-29)

Owner: "make the driver dashboard look premium, rich, subtle colours, keep our colours" (reference: a soft card dashboard).

## What changes (look only; no data, API or rule changes)
- `lib/core/ui/premium.dart`: one design kit — page grey #F4F6FB, white cards (radius 20, hairline, soft shadow), brand hero
  card (AppColors.primaryGradient), KPI tiles with tinted icons, pill chips, segmented pill, pill buttons, Inter type scale,
  `expiryOf` (Expired / days left / Valid).
- Shell: pill tab bar with icons, title "Driver Dashboard".
- Today: segmented day switch, NEXT hero with Map / Call, KPI tiles, trip card with timeline of places, round actions.
- Fuel: month pill, RM hero, Fills / Litres / No receipt tiles, fill cards with receipt chip; form restyled.
- Maintenance: "papers to renew" hero, Expired / Due tiles, one card per truck (Truck, Trailer, Service) with status chips
  (same expiry rule as before; labels Puspakom, Grease).
- Truck License: hero, Expired / Soon / Valid tiles, chips per date.
- Salary: RM hero, date pills, trip cards; details dialog restyled.
- Driver Leave: Pending / Approved / Rejected tiles, date pills, request cards.

## Checks
- `test/visual/driver_screens_test.dart` renders every tab (and the whole dashboard) with sample data and fails on any
  overflow: `SHOTS=1 [SHOTS_W=360] flutter test --no-pub --update-goldens test/visual/driver_screens_test.dart`
  (PNGs in test/visual/shots/, git-ignored). Checked at 390 and 360 px.
- flutter test: all pass. [ ] owner: device test.
