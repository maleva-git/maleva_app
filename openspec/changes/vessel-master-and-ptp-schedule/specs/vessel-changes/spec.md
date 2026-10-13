## Purpose

Show employees on the app which of their jobs have dates that no longer match PTP's vessel
schedule, and let them apply PTP's times or dismiss the difference from the phone.

## ADDED Requirements

### Requirement: The vessel changes screen lists jobs that differ from PTP

The screen SHALL load `GET /api/vessel-changes` (My jobs by default, My team as a switch) and show
the answer as the Java API returns it, one card per vessel call. The card header SHALL show
"<VESSEL> <voyage>", the sub-line "PTP: arrives <time> · departs <time>" with " (est.)" after a time
PTP marks as estimated and "—" for a time PTP does not give, then " · changed <time>" only when the
call's last change time is known (never "PTP changed -"), and the call's SCN as a chip that copies it.
Each job SHALL show "<job no> · Loading|Off", then the customer and employee on one muted line, then a
table headed "In Maleva" | "PTP now" with an ETA and an ETD row (each time on one line, "12 Oct
20:15", PTP's with " est." when estimated):
- a time that differs (the server's `etaDiffers` / `etdDiffers`) SHALL be highlighted quietly (a thin
  amber left accent and a faint background), PTP's value semibold with how far it moves ("+8 h later",
  "−2 d 3 h earlier"; rounded to hours, days and hours from 24 h, minutes only under 1 h); when Maleva
  has no time it SHALL read "not set" (muted, italic) and "to fill";
- a matching time SHALL be muted with "✓ same" for PTP;
- a time PTP does not give SHALL read "—" without a highlight.
The screen SHALL NOT show a per-job SCN line and SHALL NOT have checkboxes. An empty answer SHALL show
"No vessel changes" and the last PTP read time. A failed request SHALL show the error and a retry, not
an empty list.

#### Scenario: One vessel moved
- **WHEN** the answer has MAERSK RIO NEGRO 641S with five off legs
- **THEN** one card shows five jobs, each with ETA "10 Oct 06:30" in Maleva against "11 Oct 02:00 est." and "+20 h later" from PTP

#### Scenario: Header without a change time
- **WHEN** the call has no last change time and PTP gives no departure
- **THEN** the sub-line reads "PTP: arrives 10 Oct 06:30 (est.) · departs —" and nothing reads "PTP changed"

#### Scenario: Matching and missing times
- **WHEN** Maleva's ETA matches PTP's within the threshold and the job has no ETD from PTP
- **THEN** the ETA row is muted with "✓ same" and the ETD row shows "—", neither highlighted

#### Scenario: Time not set in Maleva
- **WHEN** the job has no ETA and PTP has one
- **THEN** the ETA row is highlighted with "not set" and "to fill"

#### Scenario: Narrow phone
- **WHEN** a 360-wide phone shows a long vessel, customer and employee name
- **THEN** nothing overflows: names are cut with an ellipsis and times shrink to stay on one line

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

"Use PTP's times" on a job SHALL update only that job; the card's "Update all N jobs to PTP" ("Update
this job to PTP" for one job), enabled without selecting anything, SHALL update every job of the call.
Both SHALL send `POST /api/vessel-plannings/sale-order-update-many` with the company, the jobs of one
leg type and PTP time pair, and only that leg's dates (loading `eta`/`etd`, off `oeta`/`oetd`), then
reload; the updated jobs leave the list. A snackbar SHALL say "<job no> updated to PTP's times" for
one job or "N jobs updated to PTP's times" for several. Jobs the update refused SHALL be named.
"Keep mine (dismiss)" SHALL call `POST /api/vessel-changes/dismiss` and remove the job. SCN SHALL be
copyable; it is not sent.
The update SHALL change only the ETA and ETD: the screen SHALL NOT move a job's pickup or delivery
date and SHALL NOT show a pickup or delivery suggestion (the owner removed "pickup and delivery follow
the vessel ETA" on 2026-10-13; the backend removed `POST /api/vessel-changes/move-pickup-delivery`
and the pickup fields of the list at the same time).

#### Scenario: Update three jobs
- **WHEN** a call has three off legs and the user presses "Update all 3 jobs to PTP"
- **THEN** one request carries those ids with `oeta` and `oetd` only, the snackbar says "3 jobs updated to PTP's times", and after reload they are gone

#### Scenario: Update one job
- **WHEN** the user presses "Use PTP's times" on MY002 of a call with two jobs
- **THEN** the request carries only MY002, the snackbar says "MY002 updated to PTP's times", and the other job stays listed

#### Scenario: One job refused (ETA)
- **WHEN** the update reports one job as skipped
- **THEN** the screen names that job and keeps it listed

#### Scenario: Pickup and delivery stay as they are
- **WHEN** the user updates a loading leg whose ETA moves to 15 Oct and whose pickup is 12 Oct 09:00
- **THEN** only the ETA and ETD request is sent, the row shows no pickup line, and the pickup stays 12 Oct 09:00

### Requirement: A boarding month change is confirmed on the row

A row with a boarding month flag SHALL show "Boarding pay moves from <month> to <month>" under its
times and SHALL be left out of "Use PTP's times" and "Update all N jobs to PTP" until the user confirms
it on that row.

#### Scenario: Not confirmed
- **WHEN** a row being updated is flagged and not confirmed
- **THEN** the other rows are updated and the screen says that one waits for confirmation
