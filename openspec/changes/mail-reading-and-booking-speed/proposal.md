# Proposal

## Why

Same as backend change `mail-reading-and-booking-speed`: reading habits, the AI's why, booking speed per employee.

## What Changes

- Mail Response tab: reading line and reasons on mailbox cards; AI points show their why.
- New section **Booking speed** in the tab (button from the header, own page): tiles, employees ranked fastest first
  (bookings, median to sale order and to reply), tap an employee for their jobs.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `mail-response-report`: reading habits, why, booking speed (added requirement).

## Impact

`core/mailmonitor` (models, API call), `features/mail_monitor/report` (cards, AI points, booking page), tests.
