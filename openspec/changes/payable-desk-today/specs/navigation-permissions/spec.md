## MODIFIED Requirements

### Requirement: Choose dashboard after manual login

Manual login SHALL send driver sessions to the driver dashboard and employee sessions to the role-mapped dashboard.
Role 1100 (PAYABLE) SHALL map to the Payable dashboard, the same dashboard as role 900 (ACCOUNTS).

#### Scenario: Sales employee
- **WHEN** manual login completes with role 300
- **THEN** the sales dashboard opens.

#### Scenario: Payable employee
- **WHEN** manual login or session restore completes with role 1100
- **THEN** the Payable dashboard opens.

#### Scenario: Unmapped manual role
- **WHEN** manual login completes with an unmapped role
- **THEN** the unauthorized page opens.
