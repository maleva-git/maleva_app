## ADDED Requirements

### Requirement: Employee pickers on the shared employee API

The employee and port pickers SHALL read the shared Java `/api/employees/company/{id}/all`,
`/api/employee-ports` and `/api/port-masters` with the session token. The app SHALL NOT call .NET
`EmployeeApp/GetEmployee` or `GetEmployeeport`.

#### Scenario: Two employee types
- **WHEN** a screen asks for the Sales and Admin employees
- **THEN** the app asks `/all` for SALES and for ADMIN, and offers the active employees of both once each, by name, as `Name-Type`

#### Scenario: Boarding officer ports
- **WHEN** a boarding officer opens the port picker
- **THEN** it lists the names of the ports actively assigned to them

### Requirement: Employee Master on the shared employee API

Employee Master SHALL list, save and delete through `/api/employees/search`,
`/api/employees/bulk/{companyId}` and `DELETE /api/employees/{id}?companyRefId=`. It SHALL require a
role, from `/api/employees/types`, before saving.

#### Scenario: New employee without a role
- **WHEN** a new employee is saved with no role chosen
- **THEN** the app shows "Select a role" and sends nothing

#### Scenario: Edit keeps the password
- **WHEN** an employee is edited and the Password field is left blank
- **THEN** the save sends a blank password, and the server keeps the current one
