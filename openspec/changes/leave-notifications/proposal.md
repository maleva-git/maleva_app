# Proposal

## Why

Backend change `leave-notifications` (owner, 2026-10-21) sends bell notices and phone pushes when
someone applies for leave and when it is approved or rejected. The app's notification list showed
them as plain "other" notices.

## What Changes

- `LEAVE_APPLIED`, `LEAVE_APPROVED`, `LEAVE_REJECTED` (`NoticeKind.leavePrefix`) get their own look
  in the bell list: tone `leave`, icon `event_busy`, purple (the colour of a driver on leave in the
  Planning and RTI pickers). Tapping one opens nothing, as before.
- Drivers get the decision as a phone push (drivers have no bell); nothing to change for that.

## Capabilities

### New Capabilities

### Modified Capabilities
- `people-leave`: leave notices have their own look in the notification list.

## Impact

`core/employee_notifications/employee_notifications_models.dart`,
`features/notifications/notification_routes.dart`, `notification_look.dart`; tests
`test/features/leave/leave_notice_look_test.dart`, and the two notification tests that used a leave
notice as their "other" example.
