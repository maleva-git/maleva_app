## ADDED Requirements

### Requirement: No .NET API code in the app

The app SHALL call only the shared Java API, and SHALL NOT keep .NET API clients, URLs or models
that nothing uses.

#### Scenario: Search the source
- **WHEN** the app source is searched for `/api/<name>App/` paths or the old .NET clients
- **THEN** nothing is found
