## ADDED Requirements

### Requirement: The driver can say the fuel card and engine state
The driver's fuel form SHALL offer "Engine off" / "Engine on" and the fuel card (No card / cash, or a card from the server's
list), none chosen at first; only a chosen value SHALL be sent.

#### Scenario: Driver fills with card PETRA, engine off
- **WHEN** the driver chooses Engine off and PETRA and saves
- **THEN** the entry is sent with engineOn false and cardCode PETRA
