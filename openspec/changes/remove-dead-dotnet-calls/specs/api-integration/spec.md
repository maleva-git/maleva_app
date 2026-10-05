## ADDED Requirements

### Requirement: No unused .NET addresses

The app SHALL NOT keep .NET `/api/*App/*` addresses that nothing calls. The only ones left SHALL be the
lookups `LegacyCallAdapter` answers from the shared Java API.

#### Scenario: A .NET-host URL
- **WHEN** a URL on the .NET host that the adapter does not know is posted
- **THEN** it still goes to the legacy client, unchanged
