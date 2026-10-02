# Proposal

## Why

Planning and Vessel Planning still called the .NET API (15 calls). The owner's rule (2026-10-02):
the app uses the same Java APIs as React and reads their answers as they are. Every call has a
Java endpoint React already uses; nothing had to be ported. Backend change
`scope-planning-saves-to-company` holds the save and delete of both to the caller's company.

## What Changes

- **New** `PlanningApi` and `VesselPlanningApi` (`lib/core/planning`): next number, saved list,
  edit read, jobs search, save, delete and the report ticket. A refusal (`ok:false` or an error)
  is an `ApiFailure` with the server's message. New `javaReportUrl` (shared with `SaleOrderApi`).
- **Planning**: the list screen, its PDF and its planning details read the Java plans; the Add
  Planning page searches, saves (`planningSaveBody`, as the web's `buildPlanningSavePayload`),
  deletes, numbers, opens a saved plan (Java edit, in saved order) and its PDF on Java. The list
  reloads when the page closes.
- **Vessel Planning (web)**: search, save, delete, number, saved list, edit and PDF on Java. The job
  update sheet is the web's Update window: PTW, cargo, the six vessel dates (an unticked date is
  cleared) and the three loading and three off-vessel boarding officers
  (`/api/vessel-plannings/sale-order-update`); the grid is searched again after an update. A saved
  plan stays open, so the next save updates it.
- `SaleOrderApi.vesselUpdate` sends `ptw` and `cargo`.
- **Removed**: the unreachable transaction Vessel Planning and Vessel Planning Details screens, the
  unused filter sheet, the dead planning save path and events, `EditPlanning`/`EditVesselPlanning`,
  the planning PDF call in enquiry, `PlanningDetailsRepository`, the planning globals and constants.

## Capabilities

### Modified Capabilities
- `api-integration`: planning and vessel planning use the shared Java APIs.

## Impact

`lib/core/planning`, `lib/core/network/java_report.dart`, `SaleOrderApi`, `auth_injection.dart`,
`injection.dart`, `api_constants.dart`, `app_globals.dart`, `legacy_api_repository.dart`, the
planning, vessel planning web and enquiry features. Ships with backend change
`scope-planning-saves-to-company`.
