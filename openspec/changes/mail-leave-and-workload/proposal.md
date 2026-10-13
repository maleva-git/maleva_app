# Proposal

## Why

Backend change `mail-leave-and-workload`: approved leave days of a mailbox's owners are not counted, and each mailbox's
mail per office day is compared with the team and its own period before, with reason HEAVY_LOAD for a very busy
mailbox. This client shows them, reading the Java fields as sent.

## What Changes

- Each mailbox shows "On leave 2 days (8-9 Oct): not counted" when its owners had approved leave in the range.
- Each mailbox shows "36 mails a day needed a reply · team 12 · before 20".
- Reason HEAVY_LOAD reads "Busy: 3x the team's mail (36 a day)" - context, shown in the reason line like the others.
