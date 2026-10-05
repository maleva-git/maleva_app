## ADDED Requirements

### Requirement: RTI screens on the shared RTI APIs

The RTI View, PDO, TransportDB, Update RTI, RTI Status, forwarding route activity and Forwarding
Salary screens SHALL use the shared Java RTI APIs with the session token, and SHALL read their
fields. The PDO / TransportDB status save SHALL post to `/api/rti-masters/job-statuses` with the line
photos. The app SHALL NOT call .NET `RTIApp`.

#### Scenario: Driver opens PDO
- **WHEN** a driver opens PDO on the driver dashboard
- **THEN** the app lists from `/api/rti-masters/with-jobs`, and only the driver's own RTIs are shown

#### Scenario: Open an RTI PDF
- **WHEN** the PDF button of an RTI is tapped
- **THEN** the app asks `/api/rti-masters/{id}/report-ticket` and opens the answered link on the Java host

#### Scenario: Send a job status
- **WHEN** a driver sends "PICKUP Done" with photos for a job
- **THEN** the app posts to `/api/rti-masters/jobs/{id}/status`, and shows the server's reason if it is refused

#### Scenario: Complete a route stop
- **WHEN** a forwarding agent marks a stop completed
- **THEN** the app calls `PUT /api/rti-route-activities/{id}/status` with status 1

#### Scenario: Verify a PDO line again
- **WHEN** a PDO line that was verified before is saved again
- **THEN** the app sends its `statusId`, and the existing status row is updated
