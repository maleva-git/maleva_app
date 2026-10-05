## ADDED Requirements

### Requirement: Trucks on the shared API

Truck pickers SHALL read `/api/truck-combo`, and License Update SHALL load a truck from
`/api/truck-masters/search` and save it with `/api/truck-masters/process`, reading and writing the Java
fields, without the .NET-shaped adapter.

#### Scenario: Update a truck's licences
- **WHEN** License Update saves a truck with its insurance date changed and its APAD date unticked
- **THEN** the app posts the stored truck with `insuranceExp` changed and `apadExp` cleared, the rest kept

#### Scenario: Refused save
- **WHEN** the server refuses the save
- **THEN** License Update shows its reason and keeps the form
