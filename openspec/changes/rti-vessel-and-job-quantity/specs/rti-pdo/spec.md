## ADDED Requirements

### Requirement: RTI job line vessel name and job quantity

Each RTI job line SHALL show its vessel name and job quantity. A saved line SHALL show the values stored by the server. A line not yet saved SHALL show them from its sale order: for job type 11, the vessel whose ETA is nearest now; for other job types, the loading vessel, else the off-loading vessel; and the quantity as Quantity / TotalWeight. The app SHALL NOT send them in the job-line save.

#### Scenario: Look up a job type 11 job
- **WHEN** a job of type 11 is looked up whose off-loading ETA is nearer today than its loading ETA
- **THEN** its line shows the off-loading vessel and the job quantity

#### Scenario: Reopen a saved RTI
- **WHEN** a saved RTI is opened
- **THEN** each line shows the vessel name and job quantity the server stored

### Requirement: Route activity vessel name and job quantity

Each route activity SHALL have a vessel name, picked from the RTI's job-line vessels or typed, and a job quantity, filled from the job lines with that vessel and editable. The app SHALL save both with the route activity.

#### Scenario: Pick a vessel for a stop
- **WHEN** the user picks a vessel that two job lines carry
- **THEN** the stop's job quantity shows both lines' quantities, and both values are saved with the stop

#### Scenario: One vessel on the RTI
- **WHEN** a stop is added to an RTI whose job lines carry one vessel
- **THEN** the stop starts with that vessel and its quantity
