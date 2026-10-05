## ADDED Requirements

### Requirement: Transaction reports on the shared API

Driver Salary, the Receipt view and the Pre Alert PDF SHALL use the shared Java reports with the
session token and read their fields. The app SHALL NOT call .NET `TransactionReportApp`.

#### Scenario: Driver Salary
- **WHEN** a driver opens Driver Salary for a period
- **THEN** the app lists `/api/rti-masters/driver-report/detailed/rows` and totals `amount`

#### Scenario: Pre Alert with LETA
- **WHEN** the Pre Alert PDF is asked with LETA chosen
- **THEN** the app asks the ticket with `eta=true&etaType=2` and opens the answered link

#### Scenario: No pre-alert jobs
- **WHEN** the server answers "No Record Found !!!"
- **THEN** the app shows that message
