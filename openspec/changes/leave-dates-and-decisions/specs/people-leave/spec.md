## ADDED Requirements

### Requirement: Whole-day leave is stored as days

The leave form SHALL default to whole days (today to today) and store them at 00:00, and SHALL store
times only when the user chooses Hours on one day.

#### Scenario: One day tomorrow
- **WHEN** a driver picks Whole days, from tomorrow to tomorrow
- **THEN** the request is 1 day, from tomorrow 00:00 to tomorrow 00:00

#### Scenario: Two hours
- **WHEN** an employee picks Hours, today 09:00 to 11:00
- **THEN** the request is today 09:00 to 11:00 and shows "2 Hours"

### Requirement: Leave status is read by name

The leave lists SHALL colour and offer review by the status name, and SHALL send approve / reject as
a decision name.

#### Scenario: Ids differ
- **WHEN** a company's Approved status has id 5
- **THEN** the request shows as approved and no Review button is offered
