## ADDED Requirements

### Requirement: Booking speed leaderboard in the app
The app SHALL show the fastest ranked employees on a podium, the others with a speed bar, a notice for bookings without
an employee on the sale order (never ranked), and the jobs with status filters and a search.

#### Scenario: No employee on the sale order
- **WHEN** the server sends the group "No employee on the sale order" with 43 bookings
- **THEN** the app shows the notice "43 bookings have no employee on the sale order" and does not rank that group

#### Scenario: Filter jobs
- **WHEN** the user taps "Counted"
- **THEN** only counted jobs are listed
