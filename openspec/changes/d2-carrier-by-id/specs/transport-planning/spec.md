## ADDED Requirements

### Requirement: Outside trip on a subcontractor or hired truck

When a plan row's truck is a subcontractor (`unitKind = SUBCONTRACTOR`) or a hired truck (`HIRED_TRUCK`), the app SHALL
pick the trip's outside driver (required) and, for a subcontractor, its truck number (optional) from the shared lists,
and SHALL save `outsideVehicleRefId` / `outsideDriverRefId` with the plan row only when they are picked.

#### Scenario: Subcontractor row
- **WHEN** a planner taps the driver of a row on RG MAJU
- **THEN** a sheet lists only RG MAJU's truck numbers (with "+ Add truck number") and the outside drivers (with "+ Add driver"), and the chosen ones are shown on the row as "truck number · driver"

#### Scenario: Hired truck row
- **WHEN** the row's truck is a hired truck
- **THEN** the sheet asks only for the driver

#### Scenario: Own truck row is unchanged
- **WHEN** the row's truck is an own truck
- **THEN** the driver is picked from the company drivers as before and no carrier ids are sent

#### Scenario: Re-opened plan keeps the carrier
- **WHEN** a saved plan is opened again
- **THEN** each row shows its truck number and outside driver read from `/api/planing/edit`, and saving again sends them back
