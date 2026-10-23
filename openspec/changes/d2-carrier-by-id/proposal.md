## Why

Fleet sprint D2 is live on the backend and the web (2026-10-23; backend change `maleva-backend/openspec/changes/d2-carrier-by-id`,
web change `maleva-front-end/openspec/changes/d2-carrier-by-id`, design `docs/fleet/d2-truck-master-analysis.md`).
Every TruckMaster row now has a kind (`unitKind`); a subcontractor (RG MAJU …) has its own truck numbers
(`/api/outside-vehicles`); outside drivers are a list (`/api/outside-drivers`); every plan row and RTI saves who carried
the trip (`outsideVehicleRefId`, `outsideDriverRefId`; the billing company comes from the truck master on the server).

The app plans and makes RTIs too, but still types the outside driver as text and never sends the ids. The backend now
keeps a row's ids when a save sends none (so the app does not erase the web's picks), but trips planned in the app get
no truck number or outside driver.

## What Changes

- **Read** `unitKind` / `supplierRefId` from the truck combo row (`TruckOption.raw`), and the carrier of a plan row from
  `/api/planing/edit` (`CarrierKind`, `OutsideVehicleRefId`, `OutsidePlateNo`, `OutsideDriverRefId`).
- **Planning (phone, tablet portrait, tablet board):** on a row whose truck is `SUBCONTRACTOR` or `HIRED_TRUCK`, the driver
  pick opens an **outside trip sheet**: *Truck number (optional)* — only that subcontractor's numbers, `+ Add truck number`
  (number + size) — and *Driver* (required) — `+ Add driver` (name, mobile, IC or passport). Own trucks: unchanged.
- **Plan save:** sends `outsideVehicleRefId` / `outsideDriverRefId` only when picked (> 0), as the web does.
- **RTI from planning** (Create RTI now, Push RTI, Create All RTI) carries the ids; the RTI form keeps them on edit and
  sends them only when > 0. The server fills the Outside Truck / Outside Driver text from the lists.
- New shared API client `core/fleet/outside_carrier_api.dart` (the same Java endpoints the web uses; no mobile-only API).

## Not changed

- Own-truck rows, the old outside-driver typed name for rows whose truck has no kind, the truck master screens
  (License Update posts the whole truck map back, so `unitKind` / `supplierRefId` survive its save).
- No backend change for the app (rule: the app reads the Java API as it is).

## Known inconsistency (recorded, not fixed here)

- Outside-driver placeholder id: the app uses 36 (`fleet_options.dart:184`) and 22 as fallback; the web uses 22.
  Recorded in `openspec/baseline/clarifications.md`.
