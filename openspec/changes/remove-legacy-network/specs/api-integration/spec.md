## ADDED Requirements

### Requirement: No .NET API client in the app

The app SHALL NOT contain a client, router or helper that sends requests to the .NET API. Every API call
SHALL go through a typed client of the shared Java API.

#### Scenario: Start the app
- **WHEN** the app's dependencies are set up
- **THEN** no legacy .NET client is registered, and the picker helpers read the shared Java APIs
