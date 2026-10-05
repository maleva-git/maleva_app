## ADDED Requirements

### Requirement: Planning and RTI match the React modules

The app's Planning and RTI screens SHALL offer what the React Planning and RTI modules offer, as
listed in this change's parity matrix, on the same shared Java endpoints. They SHALL use React's
validation rules and messages, and SHALL read the Java responses as they are. The backend and
React SHALL NOT change.

#### Scenario: Create all RTI for a plan
- **WHEN** a user with plan write access opens Create All RTI on a saved plan
- **THEN** the app shows the server preview, and creates the ticked groups through `POST /api/planing/{id}/rti-batch`

#### Scenario: Revise an RTI
- **WHEN** a user revises an RTI and submits the revision after confirming
- **THEN** the lines are refreshed from `GET /api/rti-masters/{id}/revise`, and the RTI is saved through `PUT /api/rti-masters/{id}` under the same number

#### Scenario: View-only planning role
- **WHEN** the screen access for `planning` gives VIEW only
- **THEN** save, delete and the RTI actions are locked, and the app shows React's view-only reason

### Requirement: Mobile-first design

The Planning and RTI screens SHALL use one Material 3 design system in light and dark. They SHALL use
cards instead of wide tables, keep tap targets at 48 dp or more, give each screen one main action, put
errors under the field, and show skeleton, empty and error states with Retry, as set out in `design.md`
§U2–U5.

#### Scenario: Small phone, large text
- **WHEN** a plan or RTI screen is shown on a 320×568 phone with text scaled to 130 %
- **THEN** nothing overflows, nothing needs sideways scrolling, and every action can be reached

#### Scenario: Dark mode
- **WHEN** the phone is set to dark mode
- **THEN** the Planning and RTI screens use the dark colour scheme and status tones, and stay readable
