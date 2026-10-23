## ADDED Requirements

### Requirement: RTI keeps the trip's outside carrier

An RTI made from planning (Create RTI now, Push RTI, Create All RTI) SHALL carry the plan row's `outsideVehicleRefId` and
`outsideDriverRefId`, and the RTI form SHALL keep them when the RTI is edited, sending them only when greater than 0.

#### Scenario: Push RTI from a subcontractor row
- **WHEN** a row on RG MAJU with truck number WA1229R and driver ALI is pushed to RTI and saved
- **THEN** the RTI save sends both ids, and the RTI shows WA1229R as Outside Truck and ALI as Outside Driver

#### Scenario: Own-truck RTI payload unchanged
- **WHEN** an RTI on an own truck is saved
- **THEN** the payload has no carrier keys
