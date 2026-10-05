## 1. Client

- [x] 1.1 `EmployeeApi`, `EmployeeModel.fromJava` and DI. Verify: `test/core/employee/employee_api_test.dart`.
- [x] 1.2 Every employee picker and the port picker on the Java APIs; old constant and `MasterApi.getEmployees` removed. Verify: analyzer 0 errors, no new warnings.
- [x] 1.3 Employee Master on search / bulk / company-scoped delete, with the required Role picker. Verify: `employee_details_model_test.dart`, `employeemaster_bloc_test.dart`.
- [x] 1.4 Full suite. Verify: 270 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 Email Inbox and Google Review once `SP_EmailInbox` and `SP_GoogleReview` are available.
- [ ] 2.2 On a test environment: the Sales/Admin, Sales, Operation and all-employee pickers; the boarding officer port picker; Employee Master list, add (with role), edit (password kept), delete.
