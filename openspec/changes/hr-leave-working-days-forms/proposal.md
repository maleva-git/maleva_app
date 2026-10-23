# Proposal

## Why

HR Sprint 2: leave counts working days and offers half days. The backend change `hr-leave-working-days`
(maleva-backend) counts and stores them behind `maleva.hr.leave.working-days.enabled` and says so in
`GET /api/hr/work-week` (`leaveWorkingDays`). Owner's answers (`docs/hr/hr-decisions.md` §2, 2026-10-22): staff
9-hour day, half day morning / afternoon = ½ with no fixed clock, hourly leave for staff only (hours ÷ 9);
drivers whole days or half days, Sunday 0 but allowed.

## What Changes

App: the Request Leave sheet (drivers and staff) and the leave lists (request and approval tabs).

- With the server's switch on (read from `/api/hr/work-week`): kinds **Whole days / Half day – morning / Half day –
  afternoon / Hours** (Hours not shown for drivers); a half day is one date; the form shows the working days it
  will count on the company calendar ("2½ working days", "Rest day (0 days)" for a driver's Sunday) and sends
  `Part` (FULL / AM / PM / HOURS). A staff whole-day request with only off days is stopped before sending.
- Lists show the server's `WorkingDays` ("2½ Days", "½ Day (morning)") when sent, else the old length.
- Switch off: the form and lists are exactly as before.

## Not changed

Approve / reject, the API shapes the old screens read, `TotalDays`.
