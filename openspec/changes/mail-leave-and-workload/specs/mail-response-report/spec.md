## ADDED Requirements

### Requirement: Show leave and workload
The reply report SHALL show, per mailbox, the leave days that were not counted and its mails per office day with the
team median and the period before, when the server sends them, and SHALL word reason HEAVY_LOAD as context.

#### Scenario: On leave and busy
- **WHEN** the server sends leave day 2026-10-08 and 36 a day against a team median of 12 with reason HEAVY_LOAD
- **THEN** the mailbox shows "On leave 1 day (8 Oct): not counted", "36 mails a day needed a reply · team 12" and "Busy: 3x the team's mail (36 a day)"
