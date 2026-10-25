## ADDED Requirements

### Requirement: Trip number on a plan row

The app SHALL let the planner set a plan row's trip (1–20) with the same rule as the web: the row's number wins over
"1ST TRIP" in Remarks, typing a number fills the blank rows under it on the same truck, and every save sends the trip
fields so the server keeps them.

#### Scenario: Typing a trip fills the rows under it
- **WHEN** a planner sets trip 2 on a row of QD 7151 and the next two QD 7151 rows have no trip
- **THEN** those two rows show 2 in grey (filled) and a later QD 7151 row the planner set to 3 keeps 3

#### Scenario: Clearing a trip
- **WHEN** the planner clears the trip of that row
- **THEN** the filled rows under it take the trip of the nearest QD 7151 row above, or none

#### Scenario: Trip read from Remarks
- **WHEN** a row has no trip but its Remarks say "2ND TRIP"
- **THEN** the app shows 2 in grey italic and does not send it as a typed trip

#### Scenario: Saving
- **WHEN** the plan is saved
- **THEN** every row sends `tripNo` and `tripSource` (TYPED, FILLED, AI, REMARKS, BACKFILL, or NONE without a trip)

#### Scenario: Re-opened plan keeps the trips
- **WHEN** a saved plan is opened again
- **THEN** each row shows its trip read from `/api/planing/edit`

### Requirement: Regular drivers first in the driver picker

The driver picker SHALL list the row's truck's regular drivers first (assigned in Driver Master, last RTI driver,
most used), marked with why, and the other drivers below as before.

#### Scenario: Truck with a regular driver
- **WHEN** the planner opens the driver picker on a QD 7151 row
- **THEN** QD 7151's regular driver is first with "regular · assigned · last RTI"

#### Scenario: Truck without regular drivers
- **WHEN** the truck has none
- **THEN** the list is the same as today
