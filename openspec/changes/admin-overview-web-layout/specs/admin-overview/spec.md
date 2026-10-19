## MODIFIED Requirements

### Requirement: Overview follows the web Super Admin dashboard centre
The Overview tab SHALL show the web Super Admin dashboard's Quick Access and report card (Sale Order /
Invoice with today, yesterday, week, month and months) from the same shared Java endpoint, followed by the
mailbox, incident and truck location cards. It SHALL NOT show the web's pickup and vessel side panels.

#### Scenario: Invoice view
- **WHEN** the Super Admin switches the report card to Invoice
- **THEN** the period tiles and months show the invoice numbers (`/api/dashboard/sales` type 0), as the web

#### Scenario: No side panels
- **WHEN** the Super Admin opens the Overview tab
- **THEN** there is no Today's pickup or Vessel planning panel; Quick Access still opens those screens
