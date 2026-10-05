## ADDED Requirements

### Requirement: File links on the Java server

Every link the app builds to a stored file SHALL be on the Java server (`<java>/Upload/...`), and the
company's Upload folder SHALL follow the signed-in company.

#### Scenario: Open a spare-parts document
- **WHEN** a spare-parts document stored at `/Upload/6/SpareParts/12/a.jpg` is opened
- **THEN** the app opens `<java>/Upload/6/SpareParts/12/a.jpg`

#### Scenario: Another company
- **WHEN** a user signs in to company 9 after company 6
- **THEN** image links use `<java>/Upload/9/`
