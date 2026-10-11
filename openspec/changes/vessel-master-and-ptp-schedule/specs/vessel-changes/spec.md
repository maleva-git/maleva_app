## Purpose

Show employees on the app which of their jobs have dates that no longer match PTP's vessel
schedule, and let them apply PTP's times or dismiss the difference from the phone.

## ADDED Requirements

### Requirement: The vessel changes screen lists jobs that differ from PTP

The screen SHALL load `GET /api/vessel-changes` (My jobs by default, My team as a switch) and show
the answer as the Java API returns it: one group per vessel call (vessel, voyage, when PTP last
changed it) and, per job, the job number, customer, leg, Maleva's and PTP's ETA, ETD and SCN, with
PTP's estimated mark. An empty answer SHALL show "No vessel changes" and the last PTP read time.
A failed request SHALL show the error and a retry, not an empty list.

#### Scenario: One vessel moved
- **WHEN** the answer has MAERSK RIO NEGRO 641S with five off legs
- **THEN** one group shows five jobs with O ETA 10 Oct 06:30 against PTP 11 Oct 02:00

#### Scenario: Server error
- **WHEN** the request fails
- **THEN** the screen shows the error with a retry button

### Requirement: Apply and dismiss from the phone

"Update these jobs" SHALL send `POST /api/vessel-plannings/sale-order-update-many` with the
company, the selected jobs of one leg type, and only that leg's dates (loading `eta`/`etd`, off
`oeta`/`oetd`), then reload. Jobs the update refused SHALL be named. "Dismiss" SHALL call
`POST /api/vessel-changes/dismiss` and remove the job. SCN SHALL be copyable; it is not sent.

#### Scenario: Update three jobs
- **WHEN** the user selects three off legs and presses "Update these jobs"
- **THEN** one request carries those ids with `oeta` and `oetd` only, and after reload they are gone

#### Scenario: One job refused
- **WHEN** the update reports one job as skipped
- **THEN** the screen names that job and keeps it listed
