# Proposal

## Why

Boarding officers (role 500), boarding officer admins (role 600) and forwarding agents (role 1400), and
anyone holding one of those jobs as an extra job (EmployeeCapability), need the Pre Alert report on the app,
the same report the web opens at `/Report/PreAlertRerport`. The owner asked (2026-10-20) that on the app it
opens ready for their work: ETA "All" ticked, "Delivery Done" ticked, and the port limited to the ports
assigned to that person (EmployeePortMaster), so they pick one of their ports and download that port's PDF.

## What Changes

- New dashboard tab **Pre Alert** as the **second tab** (owner, 2026-10-20: one tap from the first page) on
  the boarding dashboard (roles 500 and 600, after VSL) and the forwarding agent dashboard (after Emp Leave). A person whose extra jobs add these dashboards' work gets
  it too (one tab, never twice).
- The tab shows the existing Pre Alert filter form (`PreAlertReport` screen), in "work" mode:
  - ETA "All" (either vessel's ETA) selected and "Delivery Done" (hide delivered jobs) ticked at start.
  - Ports: a searchable "Select Port" picker at the top (the shared SearchablePickerField: a sheet with a
    search box), like the web. With ports assigned to the person
    (`/api/employee-ports` named by `/api/port-masters`) only those, the first selected. With none
    assigned, the company's active ports (`/api/port-masters/company/{id}/active`, the web's list) with
    "All Ports" first and selected.
  - "View PDF - <port>" fixed at the bottom, always shown; "Preparing the PDF..." while the server builds it.
  - L.Emp unticked and hidden (owner: always unticked; it only locked Job Type and is not sent).
- **FW Requests tab removed** from the boarding and forwarding agent dashboards (owner, 2026-10-20: they
  do not need it). Sales and Air Freight keep theirs. The tab's screen stays in the code, unused here.
- The Sales / Admin drawer entry "PreAlertReport" keeps its screen and defaults. Defect fixed there: the
  port was sent only when `portId != 0`, which the port picker never set, so the port filter never reached
  the report; it is now sent when the "Port" box is ticked, as the web does.
- No backend, web or database change. The PDF comes from the shared
  `GET /api/transaction/pre-alert-report/ticket` the web uses (open to every employee token).

## Not done (noted for the owner)

- The server does not limit the report to the caller's ports: the app limits the choice. Enforcing it on
  the server would be a change to the shared report API (owner's rule 5 allows it) and is left for a
  separate decision.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `boarding`: boarding and forwarding agent dashboards gain the Pre Alert tab limited to own ports.
