## Decisions

- **Entry points.** Sale order edit app bar ("REQ FW", enabled when `state.editId > 0`; the job number is
  `loadedMaster['cNumberDisplay']`); dashboard tabs (Sales: "MY FW REQ" read-only; Forwarding Agent and Air
  Freight: "FW Requests"); drawer cases "Forwarding Requests" / "My Forwarding Requests" (server menu rows
  must exist, `FormText` dispatch as today); GoRoutes `/forwarding_requests` and `/forwarding_requests/mine`
  for push taps.
- **Client permission checks.** None in the app beyond the employee token: the server scopes by company and
  employee, refuses drivers (403) and cancelled rows (400). `mine` is a search flag the server applies.
- **API payloads** (read as sent): `POST /api/forwarding-requests` `{saleOrderId, formTypes[], estimatedDate
  'yyyy-MM-dd HH:mm:ss', remarks}`; `POST …/search` `{fromDate, toDate, formTypes, statuses, jobNo, mine}`;
  `PUT …/{id}/ticks` `{documentReceived, draftCreated, cNumber, submitted, submittedRef, approved, approvedDate
  'yyyy-MM-dd', released, releaseNo, sealByRefId, breakSealByRefId}`; `PUT …/{id}/cancel`; `GET
  …/sale-order/{id}`. All answer `ApiResponse` PascalCase with `Data1`, unwrapped by `JavaResponse.data`.
- **Ladder in the client** (`ForwardingRequestTicks.step`): the same rule as the server, so the form never
  shows a state the server would refuse; the server remains the authority (its message is shown on refusal).
- **Employees for the seal pickers**: `EmployeeApi.dropdown()` with no type, every active employee, in
  `showPickerSheet` (searchable; bottom sheet on phone, dialog on tablet). Owner's decision 2026-10-09: no
  employee-type restriction.
- **State**: `ForwardingRequestsCubit` (filter, rows, loading, error, busyId; a save or cancel re-reads the
  list) and `RequestForwardingCubit` (the job's existing requests, create). `ForwardingRequestApi` is a
  `get_it` lazy singleton registered by `registerForwardingRequestsFeature`.
- **Layout**: `ResponsiveLayout` picks one column (phone), two (tablet portrait) or three (tablet landscape);
  the edit and detail pages are plain scrolling pages with a `StickyActionBar`.
- **Compatibility**: `routeForPush` keeps `MAIL_UNREAD` first; the unread-mail signal in `main.dart` now fires
  on `MAIL_UNREAD` only (it used to fire for any routed push, which was only mail). Existing tests
  `my_unread_mail_test.dart` still pass.
- **Relevant existing tests**: `test/core/employee/employee_api_test.dart` (the `QueueAdapter` pattern),
  `test/features/mail_monitor/mine/my_unread_mail_test.dart` (push routing, cubit pattern).
