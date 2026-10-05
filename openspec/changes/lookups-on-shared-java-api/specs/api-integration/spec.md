## ADDED Requirements

### Requirement: Customer and job type pickers on the shared API

The customer and job type pickers SHALL read `/api/customers/options` and
`/api/job-type-master/jobtypes/{companyId}` directly and their Java fields, without the .NET-shaped
adapter.

#### Scenario: Pick a customer
- **WHEN** a customer picker opens
- **THEN** the app lists `/api/customers/options` and shows each option's label

#### Scenario: A company without job types
- **WHEN** the job type list answers 404
- **THEN** the picker is empty, not an error
