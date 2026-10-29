## ADDED Requirements

### Requirement: The driver sees today's trips first
The driver dashboard SHALL open on a Today tab that lists the driver's trips of the chosen day (Yesterday, Today,
Tomorrow) by their real day from the server, in time order, each with its stops, Call and Map actions, the photo status,
the RTI PDF and the time on site.

#### Scenario: Two trips today and one tomorrow
- **WHEN** the driver has RTI A (first pickup today 08:00), RTI B (today 14:00) and RTI C (typed today, first pickup tomorrow 07:00)
- **THEN** Today shows "Trip 1 of 2" A then "Trip 2 of 2" B, and Tomorrow (1) shows C
