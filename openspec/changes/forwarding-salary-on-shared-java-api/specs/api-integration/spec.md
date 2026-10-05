## ADDED Requirements

### Requirement: Forwarding salary on the shared API

The Forwarding Salary screen SHALL load and save with `/api/forwarding-salaries/entries` and read its
fields. The app SHALL NOT call .NET `ForwardingSalaryApp`.

#### Scenario: Pick an RTI
- **WHEN** an RTI with a forwarding salary is picked
- **THEN** the app loads its first row and fills the employees and salaries

#### Scenario: Refused save
- **WHEN** the server refuses the save
- **THEN** the app shows its reason and keeps the form
