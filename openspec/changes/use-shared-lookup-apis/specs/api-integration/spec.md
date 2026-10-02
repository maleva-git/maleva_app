## ADDED Requirements

### Requirement: Lookups and fuel entries from the shared Java APIs

The app SHALL read its truck, driver, customer, address, job type, job step, job status, agent, agent company and product lists, License Update's truck, and fuel entries from the Java APIs the web app uses, and SHALL give its screens the same rows they read before.

#### Scenario: Truck picker
- **WHEN** a truck picker loads
- **THEN** the app calls `GET /api/truck-combo` with the session token and lists `{Id, AccountName}` rows as before.

#### Scenario: Empty list
- **WHEN** a web API answers an empty list with 404 or 204
- **THEN** the screen shows an empty list, not an error.

#### Scenario: Refused save
- **WHEN** the server refuses a fuel save
- **THEN** the screen shows the server's message.

### Requirement: Driver screens stay within driver rights

A driver login SHALL NOT open office screens from the transport list, and License Update SHALL treat a driver as a driver whether or not a truck is assigned.

#### Scenario: Long-press as a driver
- **WHEN** a driver long-presses a transport row
- **THEN** nothing opens.
