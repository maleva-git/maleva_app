# Proposal

## Why

The owner reported (2026-10-19) that boarding officers (500), boarding admins (600) and forwarding
agents (1400) do each other's work, and some of them also drive (e.g. Kabilan, 600, creates RTIs and
now has a second Driver Master login). Backend change `employee-extra-jobs-and-driver-mode`
(maleva-backend) adds `jobs` and driver links to the session and a `switch` endpoint. This is the app
part. The app reads the Java fields as they are (owner's rule 2).

## Affected capability paths

- `boarding` (boarding dashboard), `forwarding` (forwarding agent dashboard, FW Update, FW Exit
  Update), `authentication` (session, dashboard routing, sign-out), `navigation-permissions`.

## What Changes

**1. One work dashboard, tabs for every job.** The main role still picks the home route
(`dashboard_routes.dart`, unchanged). The boarding and forwarding agent dashboards build their tab
list from `session.jobs`:

| Job | Tabs it adds |
|---|---|
| `BOARDINGOFFICER` | VSL, IR Report |
| `BOARDINGOFFICERADMIN` | VSL, SpotsSaleOrder, IR Report, InventoryReport |
| `FORWARDINGAGENT` (on the boarding dashboard) | RTI Activities, FW Requests, **Seal / Break Seal** (one tab with two buttons that open FW Update and FW Exit Update) |
| everyone on these dashboards | Salary (boarding roles, as today), Emp Leave |

Tabs are added once (IR Report and Emp Leave never twice), in a fixed order. With no jobs
(old backend), the tabs are exactly today's for the role.

Boarding rules that check `roleId == 500/600` (`Port.dart:13`, `vesselreport_bloc.dart:56`,
`vesselreportview_tab.dart:176,261,1573,1743`) check the boarding job instead, so a 1400 user with
a boarding job gets his own ports, and the 500 limits apply to `BOARDINGOFFICER` without
`BOARDINGOFFICERADMIN`.

**2. Driver mode switch.** When the session has `linkedDriverId`, the dashboard app bar shows a
**"Driver mode"** button; the driver dashboard shows **"Office mode"** when the driver session has
`linkedEmployeeId`. Tapping it: confirm dialog → `POST /api/mobile/auth/switch` → `SessionWriter`
saves the new session → go to the new home dashboard. On error a toast shows the server message and
the user stays where he is. The last mode is kept after restart (the stored token is the new one).

**3. Alerts in both modes (owner, 2026-10-19).** A linked person gets office alerts while in Driver
mode and driver alerts in office mode: the backend keeps the phone's push token on both records.
Each push carries `forKind`. The phone shows every alert as usual. Tapping an alert of the other
mode asks "This is an office alert. Switch to office mode to open it?" (or "driver alert"); Yes
switches and opens it, No just closes the alert. Pushes without `forKind` open as today.

Not changed: login screen (the driver toggle stays for drivers with their own login), RTI save,
menus from the server.

## Clarifications

No baseline clarification is resolved here. Owner decisions Q1–Q3 are recorded in the backend
proposal.
