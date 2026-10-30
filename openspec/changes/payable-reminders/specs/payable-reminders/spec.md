## ADDED Requirements

### Requirement: Reminders calendar
The Reminders tab SHALL show a month calendar with a mark on each day that has reminders (done, due, missed) and the
chosen day's reminders with Done / Undo.

#### Scenario: Mark done
- **WHEN** the user taps Done on "Print TNG invoice" on 3 Nov
- **THEN** it shows done (who, when) and no follow-up comes

### Requirement: Add a reminder
The Add screen SHALL save title, repeat, day or date, time, weekend rule, who, start / end, follow-up and note, and SHALL
show the next due dates before saving.

#### Scenario: Next dates shown
- **WHEN** the user picks every month on day 3 at 09:00
- **THEN** the screen shows the next three due dates with any weekend move
