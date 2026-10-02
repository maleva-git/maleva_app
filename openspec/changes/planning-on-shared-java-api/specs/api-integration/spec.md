## ADDED Requirements

### Requirement: Planning and vessel planning on the shared Java API

The Planning and Vessel Planning screens SHALL use the shared Java `/api/planing`,
`/api/planning/reports` and `/api/vessel-plannings` APIs that React uses, with the session token,
and read their answers as they are; they SHALL NOT call the .NET planning APIs.

#### Scenario: Save a transport plan
- **WHEN** a planner saves a plan with two jobs
- **THEN** the app posts one `PlanningRequest` to `/api/planing/save` and shows the plan number the server answers.

#### Scenario: Refused save
- **WHEN** the server answers `ok:false` for a plan
- **THEN** the screen shows the server's message and the plan is not reported as saved.

#### Scenario: Update a job from Vessel Planning
- **WHEN** a planner sets a loading boarding officer and the PTW on a job
- **THEN** the app posts `/api/vessel-plannings/sale-order-update` with both officer sides and searches the grid again.
