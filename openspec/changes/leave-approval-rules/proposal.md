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
