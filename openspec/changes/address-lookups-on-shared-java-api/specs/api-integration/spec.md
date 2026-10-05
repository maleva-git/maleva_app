## ADDED Requirements

### Requirement: Address pickers on the shared API

The address pickers SHALL read `/api/addresses/company/{companyId}/active` and
`/api/addresses/company/{companyId}/search` directly and their Java fields, without the .NET-shaped
adapter.

#### Scenario: Fill a pickup address
- **WHEN** an address is picked for the pickup on a sales order
- **THEN** the app searches `/api/addresses/company/{companyId}/search` for it and fills its name, address and phone
