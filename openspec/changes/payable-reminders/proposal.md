# Proposal

## Why
Scan items 5–6: monthly reminders with a calendar, own time, and a notice. Design `docs/payable/s5-reminders-design.md`.

## What Changes
- Payable dashboard tab **Reminders** (after Today): month calendar with dots (due, done, missed, today), a day's list
  with time, title, who, note, **Done / Undo**; an "Upcoming" strip; a reminder's page (rule in words, last 6 months,
  Edit / Pause / Delete).
- **Add / Edit** screen: title (quick picks), every month on a day (1–31 / last day) or once, time, weekend rule, team
  or chosen people, start / end month, follow-up, notes, and a live "Next: …" sentence.
- Today tab card "Reminders today"; bell / push of kind `PAYABLE_REMINDER*` opens the Reminders tab on that day.
- Uses the shared `/api/payable-reminders` (backend change `payable-reminders`).

## Capabilities
### New Capabilities
- `payable-reminders`: the app's reminders calendar and form.

## Impact
`payable_dashboard/reminders/`, dashboard tabs, Today card, notification route; tests.
