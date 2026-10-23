# Proposal

## Why

Owner (2026-10-21): leave must have no date problems. The app's Request Leave form always stored a
date **and the time it was opened** (default "now" to "now + 1 day", e.g. 10:23 to 10:23 next day),
so a one-day leave became a timed two-day leave, and every app leave looked timed (overlap by time,
"dd MMM hh:mm a" in lists, two days in the day counts). The driver and employee forms were two copies.
Status colours and the Review button used fixed ids 1 / 2 / 3.

## What Changes

- **One form** (`view/leave_request_form_sheet.dart`) for drivers and employees, with
  **Whole days** (default: from day, to day, stored 00:00) or **Hours** (one day, from and to time).
  Default: today, one day. Pure rules in `data/leave_form.dart` (tested): to-day before from-day,
  to-time not after from-time, both refused with a message.
- **Status by name** (`StatusName`, then the id as before) for colours, the pending check and the
  Review button; approve / reject send `decision` `APPROVED` / `REJECTED` (backend change
  `leave-dates-and-decisions`), with the id as before.

## Capabilities

### New Capabilities

### Modified Capabilities
- `people-leave`: the request form has whole days and hours; status is read by name.

## Impact

`driverleave/view/*` (both request tabs use the shared form), `data/leave_form.dart`,
`data/leave_request_model.dart` (status helper), `core/employee/leave_api.dart` (decision), tests.
