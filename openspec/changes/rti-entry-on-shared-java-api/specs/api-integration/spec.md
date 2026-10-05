## ADDED Requirements

### Requirement: Add / Edit RTI on the shared API

The Add / Edit RTI page SHALL load, number, search jobs for, save, revise, delete and print RTIs with
the shared Java RTI API, sending the session company. The app SHALL NOT call the .NET `/RTI/*` web
routes.

#### Scenario: Save a new RTI
- **WHEN** a new RTI with a driver, a truck and a job is saved
- **THEN** the app posts it to `/api/rti-masters` and shows the number the server gave it

#### Scenario: Edit keeps the web's data
- **WHEN** an RTI made on the web is edited in the app and saved
- **THEN** its route stops, pickup / drop counts and line addresses stay
