# Proposal

## Why

The owner wants leave apply, approve and reject to be correct (2026-10-19). The app stored minutes,
hours or days in the one `totalDays` number depending on the leave's length (a 30-minute leave was
stored as 30, read elsewhere as 30 days), guessed the unit back on display ("15 or more = minutes"),
and offered the Review button on the signed-in employee's own request. Backend change
`leave-approval-rules` now enforces the approval rules on the server.

## What Changes

- **`totalDays` is calendar days** (from-date to to-date, both counted; hours on one day = 1), as the
  server now stores it. One helper, `data/leave_duration.dart`, replaces the four copies of the
  duration code.
- **The length shown is read from the dates and times**: "30 Mins", "2 Hours 30 Mins", "1 Day",
  "3 Days"; never from `totalDays`.
- **No Review button on one's own request** in the Employee Leave Approval tab; it reads "Your own
  request - another employee reviews it". The server refuses it anyway.
- **After a refused review the list reloads**, so a request someone else already decided shows its
  real status.
- **A submit after a refused one is sent** (owner, 2026-10-19: "apply is not working"). The bloc
  only acted while its state was "loaded"; after any refusal the state was "error" and every
  later Request Leave / Review tap did nothing. It now works from the last loaded list, and a
  second tap while one is being sent is ignored.
- **Leave applied for coming dates is listed.** The request tabs listed leave starting between 30
  days ago and *today*, so a request for next week vanished after saving. The window now runs a
  year ahead.
- **Driver leave warning in Planning and RTI** reads every pending / approved leave of the driver
  list (today and the next 3 days), by start, with "on leave today" / "starts in N days" and the
  hours of a part-day leave. Before, only the first row was read. One helper,
  `core/fleet/driver_leave_notes.dart`, serves both pickers. Warn only.
- The server's new refusals (overlapping leave, already reviewed, own leave, applicant not current)
  are shown as its message, as before.

## Capabilities

### New Capabilities

### Modified Capabilities
- `people-leave`: the submitted total is calendar days; the reviewer and own-request rules.

## Impact

`lib/features/dashboard/common_tabs/driverleave/data/leave_duration.dart` (new), the four
`driverleave/view/*` tabs, `test/features/leave/leave_duration_test.dart` (new). No API shape
change. Ships with backend change `leave-approval-rules`.
