## ADDED Requirements

### Requirement: Leave screens on the shared API

The leave request and approval screens SHALL use `/api/leave` (types, search, save, status) with the
session token and read its fields. The app SHALL NOT call .NET `LeaveRequestApp`.

#### Scenario: A driver requests leave
- **WHEN** a driver submits a leave request
- **THEN** the app posts it to `/api/leave/save` and the request shows as pending in their list

#### Scenario: Refused request
- **WHEN** the server refuses the request (for example the dates are reversed)
- **THEN** the app shows the server's reason
