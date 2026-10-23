## ADDED Requirements

### Requirement: Pre Alert tab for boarding and forwarding work
The boarding dashboard and the forwarding agent dashboard SHALL show a Pre Alert tab, once, to every user
they are shown to (roles 500, 600, 1400 and users whose extra jobs open these dashboards), as the second
tab, one tap from the first. The tabs that were there before SHALL keep their order around it.

#### Scenario: Boarding officer opens the dashboard
- **WHEN** a role 500 user opens the boarding dashboard
- **THEN** the tabs are VSL, Pre Alert, Salary, EmpLeave, IR Report

#### Scenario: Forwarding agent opens the dashboard
- **WHEN** a role 1400 user opens the forwarding agent dashboard
- **THEN** the tabs are Emp Leave, Pre Alert, RTI Activities, IR Report

### Requirement: Pre Alert opens ready for the work
In the Pre Alert tab the ETA choice SHALL start on "All" (either vessel's ETA) and "Delivery Done" SHALL
start ticked. The From and To dates SHALL start on today.

#### Scenario: Tab opened
- **WHEN** a boarding officer opens the Pre Alert tab
- **THEN** ETA "All" is selected and "Delivery Done" is ticked

### Requirement: Port picker as the web, limited to assigned ports
The Pre Alert tab SHALL show a port dropdown at the top. When the user has assigned ports it SHALL offer only
those, SHALL select the first one at start and SHALL NOT offer "All Ports". When the user has no assigned
port it SHALL offer the company's active ports (the web's list, `/api/port-masters/company/{id}/active`)
with "All Ports" first and selected. The chosen port SHALL be sent with the report; "All Ports" sends none.
The View PDF button SHALL always be shown, fixed at the bottom of the tab.

#### Scenario: Officer with two ports
- **WHEN** an officer assigned WESTPORT-B18 and NORTHPORT- B10 opens the tab, picks NORTHPORT- B10 and taps View PDF
- **THEN** the report is requested with port "NORTHPORT- B10", ETA type 3, deliveryDone true

#### Scenario: User with no assigned port
- **WHEN** a role 600 user with no assigned port opens the tab
- **THEN** the dropdown lists the company's ports with "All Ports" selected, and View PDF is shown

### Requirement: L.Emp unticked and hidden in the tab
The Pre Alert tab SHALL start with L.Emp unticked and SHALL NOT show the L.Emp box, so Job Type can be
picked. L.Emp is not sent to the report.

#### Scenario: Tab opened
- **WHEN** any user opens the Pre Alert tab
- **THEN** there is no L.Emp box and the Job Type field can be used

### Requirement: No FW Requests tab on the work dashboards
The boarding dashboard and the forwarding agent dashboard SHALL NOT show the FW Requests tab, whatever the
user's role or extra jobs. The Sales and Air Freight dashboards SHALL keep their forwarding requests tab.

#### Scenario: Boarding admin who also seals
- **WHEN** a role 600 user with the FORWARDINGAGENT extra job opens the boarding dashboard
- **THEN** the tabs include RTI Activities and Seal / Break Seal but not FW Requests
