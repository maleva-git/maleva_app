## ADDED Requirements

### Requirement: Booking insights on the page
The Booking speed page SHALL show the server's slow spots, spread, groups by arrival time, weekday and customer, the
daily trend, the waiting booking mails, and an AI summary written on request in the chosen language and read aloud.

#### Scenario: Slow evenings
- **WHEN** the server sends slow spot "17:00 to closing" with 4 bookings, 150 minutes, 2.7x
- **THEN** the page shows it under "Where bookings get slow" with "2 h 30 m" and "2.7x the team"

#### Scenario: AI summary
- **WHEN** the user taps "Write summary"
- **THEN** the summary is requested for the shown range and language and its points show with names, why and suggestion
