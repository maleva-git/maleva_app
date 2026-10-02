# Spec Delta

## MODIFIED Requirements

### Requirement: Choose dashboard after manual login

Manual login and session restore SHALL use one dashboard map: driver sessions open the driver dashboard; employee sessions open the dashboard mapped to their role (100, 200, 400 and 800 admin; 300 sales; 500 and 600 boarding; 900 payable; 1000 transport; 1200 receivable; 1300 maintenance; 1400 forwarding agent; 1500 air freight); any other role opens the unauthorized page.

#### Scenario: Sales employee
- **WHEN** manual login or session restore completes with role 300
- **THEN** the sales dashboard opens.

#### Scenario: Unmapped manual role
- **WHEN** manual login or session restore completes with an unmapped role
- **THEN** the unauthorized page opens.

#### Scenario: Same dashboard after a restart
- **WHEN** an employee with role 200 signs in, and later reopens the app and the session is restored
- **THEN** the admin dashboard opens both times.
