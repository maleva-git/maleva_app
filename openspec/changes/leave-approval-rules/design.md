# Design

## Decisions

- **Display from the dates, not `totalDays`.** Old rows hold minutes or hours in `totalDays`; reading
  the dates shows them correctly before and after the owner's SQL recount.
- **One helper** (`leave_duration.dart`) for the four tabs and the two request forms, unit-tested.
- **Own request hidden by `AppGlobals.EmpRefId`.** Only the employee tab: the admin tab lists drivers.
  The server is the guard; the app only avoids offering a button that would be refused.
- **Reload after a refused review**, the same fetch as after a success.

## Risks

- `EmpRefId` 0 (not signed in) shows the button; the server still refuses.
