# Design

`EmailInboxApi(Dio, {companyId})` follows the other shared APIs.

- `unanswered` maps `Data1.emails` with `EmailModel.fromJava`. A zone-less `receivedDate` is read as
  UTC.
- `keep` posts `EmailModel.toJava(employeeId)` for every ticked mail. Each is an active entry
  (`id` 0), with `receivedDate` formatted from its UTC value as `yyyy-MM-ddTHH:mm:ss`.
