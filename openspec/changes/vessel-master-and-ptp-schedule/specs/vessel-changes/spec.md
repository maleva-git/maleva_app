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

### Requirement: Read PTP now from the phone

The vessel changes screen SHALL have a "Read PTP now" button in its top bar for every employee. It
SHALL call `POST /api/ptp/vessel-schedules/read`, say what happened ("PTP read: 224 vessel calls, 3
changes", or "PTP was read at <time>; this is the latest schedule" when the server reused a read from
the last few minutes, or the failure), and then reload the list.

#### Scenario: Refresh on the phone
- **WHEN** a customer-service user taps "Read PTP now" on the vessel changes screen
- **THEN** PTP is read (or a read from the last few minutes is reused), the note says so, and the list reloads with the fresh times

### Requirement: Apply and dismiss from the phone

"Update these jobs" SHALL send `POST /api/vessel-plannings/sale-order-update-many` with the
company, the selected jobs of one leg type, and only that leg's dates (loading `eta`/`etd`, off
`oeta`/`oetd`), then reload. Jobs the update refused SHALL be named. "Dismiss" SHALL call
`POST /api/vessel-changes/dismiss` and remove the job. SCN SHALL be copyable; it is not sent.

#### Scenario: Update three jobs
- **WHEN** the user selects three off legs and presses "Update these jobs"
- **THEN** one request carries those ids with `oeta` and `oetd` only, and after reload they are gone

#### Scenario: One job refused (ETA)
- **WHEN** the update reports one job as skipped
- **THEN** the screen names that job and keeps it listed

### Requirement: Pickup and delivery move with the ETA of the job's PTP leg on the phone

Each row SHALL show the API's suggested pickup and delivery, or its reason in words. The screen
SHALL NOT decide by leg: the API says which leg moves the pickup (the loading leg, or the off leg
when it is the job's only leg at PTP), and `NOT_THIS_LEG` reads "Follows the job's other leg"
("Planned for <date>, re-plan in Planning", "Already collected", "Date in the past", "No pickup or
delivery date"). With "Also move pickup and delivery" on (the default), "Update these jobs" SHALL
send the movable selected jobs to `POST /api/vessel-changes/move-pickup-delivery` after their ETA
update succeeds, and SHALL name any job either request refused, with its reason. A planned job SHALL
never be sent to the move request.

#### Scenario: Off leg the API allows
- **WHEN** an off row has a suggested pickup and no reason
- **THEN** the row shows the pickup move, and "Update these jobs" sends that job to the move request after its OETA update

#### Scenario: ETA 15 Oct
- **WHEN** a loading row's ETA moves to 15 Oct and its pickup is 12 Oct 09:00
- **THEN** the row shows pickup 14 Oct 09:00, and after the update both the ETA and the pickup are changed

#### Scenario: Planned job
- **WHEN** a row's reason is PLANNED
- **THEN** its ETA can be updated, it is not in the move request, and the row says "re-plan in Planning"

### Requirement: A boarding month change is confirmed on the row

A row with a boarding month flag SHALL show "Boarding pay moves from <month> to <month>" and SHALL be
left out of "Update these jobs" until the user confirms it on that row.

#### Scenario: Not confirmed
- **WHEN** a selected row is flagged and not confirmed
- **THEN** the other rows are updated and the screen says that one waits for confirmation
