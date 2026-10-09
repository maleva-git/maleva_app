## Why

Customer Service asks the forwarding team for customs forms (K1 / K2 / K3 / K8) and follows each one to
release; the forwarding team works the steps. The web has it (backend changes `forwarding-requests`,
`forwarding-request-followup`, shared `/api/forwarding-requests`). The owner asked (2026-10-09) for the same
in the app, on phone and tablet: the "Request FW" option on the sale order, and the request list for the team.

## What changes

- Read and write `/api/forwarding-requests` as the Java API answers it (rule: the app adapts, the API is
  shared; the company and the acting employee come from the token).
- **Sale order edit** (`salesorderadd_tab.dart`): a "REQ FW" app-bar button on a saved job opens a sheet
  (bottom sheet on phone, dialog on tablet): form type chips (several at once), estimated date-time (default
  tomorrow 09:00), remarks, and the job's existing requests with their status.
- **Forwarding Requests list** (`ForwardingRequestsBody`): one card per request (job, form, estimate, requester,
  six-step ladder, status; coral when overdue), a filter page (dates, form types, statuses, job no), one column
  on phone, two / three on tablet. Tapping a card opens the edit page: the five ticks and their references
  (C Number, registration no, approved date, release number), the seal and break-seal employees from a
  searchable picker over every employee of the company, saved together by one Save button; cancel with
  confirmation. As a tab on the Forwarding Agent and Air Freight dashboards ("FW Requests") and from the
  drawer ("Forwarding Requests", needs a server menu row).
- **My Forwarding Requests** (`mine`): the same list read-only for the CS employee's own requests, as a tab
  "MY FW REQ" on the Sales dashboard, from the drawer ("My Forwarding Requests") and from the notices.
- **Push notices** (`type=FORWARDING_*`, `link`): tapping opens the planning list (team notices) or My
  Forwarding Requests (requester notices), through the existing `routeForPush` / `routeForPayload`.

Baseline capability touched: `openspec/specs/forwarding/spec.md` (forwarding operations) gains a sibling
capability `forwarding-requests-app`; the existing Forwarding Update screens are unchanged.

## Exclusions

No Excel upload, no legs on `SaleOrderMaster`, no change to the forwarding reports. Role 1500 is "air
freight" in the app and "forwarding" in the web; the backend tells roles 1400 and 1500 until the owner narrows
it (`forwarding-requests.team-role-ids`). Clarification IDs: none affected.

## Impact

`lib/core/forwarding_request/` (models, API), `lib/features/forwarding_requests/` (cubits, pages, sheet, push
routing, injection), `main.dart` / `push_route.dart` (routing), `app_router.dart` (two routes), the Sales,
Forwarding Agent and Air Freight dashboards (one tab each), `salesorderadd_tab.dart` (button), `menulist.dart`
(two drawer entries). No backend change for the app. Owner tests on a device.
