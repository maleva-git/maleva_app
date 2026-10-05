## ADDED Requirements

### Requirement: Salary tab on the shared boarding salary API

The Salary tab SHALL list `/api/boarding-settlement/monthly-salary` for the session company and total
`calculatedRate`. The app SHALL NOT call .NET `BoardingSalaryApp`.

#### Scenario: A boarding officer
- **WHEN** a boarding officer opens the Salary tab for a month
- **THEN** the app asks with their employee id and the company, and shows the same rows React shows for them

#### Scenario: An admin
- **WHEN** an admin opens the Salary tab
- **THEN** the app asks without an employee id and lists every officer of the company
