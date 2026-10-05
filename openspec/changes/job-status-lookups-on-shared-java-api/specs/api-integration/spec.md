## ADDED Requirements

### Requirement: Job status lookups on the shared API

Job status pickers and job-type steps SHALL be read from `/api/job-status-master/select/{companyId}/`
and `/api/job-type-master/select-all-data` directly, as typed models of the Java fields, without the
.NET-shaped adapter.

#### Scenario: Pick a job type on a sales order
- **WHEN** a job type is picked
- **THEN** the app loads that type's steps and status order and shows its fields; a type with none shows none, not the previous type's

#### Scenario: A status name
- **WHEN** a screen needs the name of status 3 of job type 2
- **THEN** it is taken from job type 2's status order
