## ADDED Requirements

### Requirement: Enquiry lists and status on the shared API

The enquiry lists SHALL read `/api/enquiry-masters/search`, and cancel and confirm SHALL use
`/api/enquiry-masters/{id}/status`, with the session token.

#### Scenario: Cancel an enquiry
- **WHEN** an enquiry is cancelled from a list
- **THEN** the app sets CANCEL and lists again without it

#### Scenario: Sale order from an enquiry
- **WHEN** an enquiry is opened as a sale order and saved
- **THEN** the form starts from the Java enquiry row, and the enquiry is set CONFIRMED

### Requirement: Enquiry save on the shared API

Add Enquiry and Add Enquiry TR SHALL save with `POST /api/enquiry-masters/entries`, sending their own
fields under the Java names. The app SHALL NOT call .NET `EnquiryMasterApp`.

#### Scenario: Save a transport enquiry
- **WHEN** a TR enquiry is saved
- **THEN** the app posts its customer, job type, ports, quantity, weight, origin, destination and dates, and shows success

#### Scenario: Refused save
- **WHEN** the server refuses the save
- **THEN** the form shows the server's reason
