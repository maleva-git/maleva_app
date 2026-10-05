# Design

`EmployeeApi.dropdown(type, type1)` works in three steps:
1. Clean the types: drop blanks and `ALL`, upper-case them, and remove duplicates.
2. Call `/all` once per type, or once with no type when none is left.
3. Keep `active == 1`, merge by `id`, sort by `employeeName`, and map with `EmployeeModel.fromJava`.

The endpoint answers a bare list. A wrapped answer is read too.

Every caller already turned the rows into `EmployeeModel` for `AppGlobals.EmployeeList` and the
shared `Employee` picker, so the repositories now return `List<EmployeeModel>` and the callers drop
their `fromJson` mapping. FW Break Seal and Sale Order Details looked names up in raw maps
(`['Id']`, `['AccountName']`); they now read the model's fields.

## Employee Master

- `EmployeeRepository` uses `EmployeeApi`: `search`, `roles`, `save` (one row in a list, as
  `/bulk` takes) and `delete`.
- The form bloc loads the roles when it opens. If they fail to load, the form stays and a save is
  refused with "Select a role".
- `SelectRoleEvent` sets `EmployeeDetailsModel.RoleId`, and the save refuses `RoleId == 0`.
- `toJava` sends blanks as null and the password as typed (blank keeps it). It does not send
  `accountCode` or `capabilityIds`, so capabilities set on the web are not touched.
