## ADDED Requirements

### Requirement: Same search as React

The app's planning search SHALL send the same request as React's live page (`helpers.ts`
`buildSearchPayload`) to `POST /api/planing/search`. It SHALL apply the same criteria check and
messages, and SHALL read the answer as `mapPlanningSearchItem` does.

#### Scenario: Search without criteria
- **WHEN** the planner searches with no search text, employee, FROM or TO
- **THEN** the app shows "Please enter at least one search criteria" and does not call the API

#### Scenario: Find in results stays local
- **WHEN** the planner types a truck or customer in the find-in-results bar
- **THEN** only the loaded rows are filtered, and no search request is sent

### Requirement: Phone and tablet layouts

The Planning and RTI screens SHALL use a phone layout below 600 dp, a master-detail layout from
600 to 900 dp, and a board layout above 900 dp. Every React grid field SHALL be reachable on each
layout.

#### Scenario: Rotate a tablet
- **WHEN** a tablet showing an unsaved plan is rotated
- **THEN** the layout changes, and the rows, the selection and the unsaved changes stay

### Requirement: Manual assignments are never replaced

The app SHALL change a job's truck or driver only when the planner picks one for that job, or for jobs
the planner selected.

#### Scenario: Pick a truck
- **WHEN** the planner picks a truck for a job
- **THEN** only the job's truck name and id change, and its driver stays as it was
