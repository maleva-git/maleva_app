## ADDED Requirements

### Requirement: Truck entry screens on the shared Java APIs

The Spare Parts, Summon and Spot Sale views SHALL list from the shared Java `/entries` APIs with the
session token, and SHALL read their fields. The Spare Parts add SHALL save through
`POST /api/truck-spare-parts/entries` with its documents.

#### Scenario: Add spare parts with a photo
- **WHEN** spare parts for a truck are saved with a photo
- **THEN** the app posts the entry JSON and the photo as multipart, and shows success when an id comes back

#### Scenario: Driver opens Summon view
- **WHEN** a driver opens the Summon view
- **THEN** only the summons of the truck on their record are listed
