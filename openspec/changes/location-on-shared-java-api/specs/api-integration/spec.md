## ADDED Requirements

### Requirement: Location picker on the shared API

The Location picker SHALL list the company's locations from `/api/location-master/company/{id}/active`
and read its fields. The app SHALL NOT call .NET `LocationApp`.

#### Scenario: Pick an origin
- **WHEN** the origin picker opens on Add Enquiry TR
- **THEN** the app lists the company's locations from the shared endpoint and the chosen one fills the origin
