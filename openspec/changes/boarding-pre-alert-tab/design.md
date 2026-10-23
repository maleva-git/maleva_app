# Design

## Context

- Web: `/Report/PreAlertRerport` (`maleva-front-end/src/features/pre-alert-report`) prints through
  `GET /api/transaction/pre-alert-report/ticket` (`PreAlertPdfController`, port of .NET
  `TransactionReportApp/PreAlertReport`). Filters: dates, customer, job type, `port` (LIKE on SPort/OPort),
  vessel, `discussion`, `eta` + `etaType` (1 OETA, 2 LETA, other either), `deliveryDone`, `consolidated`.
- App: `features/transaction/prealertview` already calls it (`TransactionReportApi.preAlertUrl`) from the
  drawer entry "PreAlertReport" (Sales / Transportation / Admin menus only).
- Assigned ports: `EmployeeApi.portNames` (EmployeePortMaster), used by the vessel report and `loadPortNames`.
- Work dashboards are built from `workTabsFor` + `workTabView` (employee-extra-jobs-and-driver-mode).

## Decisions

1. **A tab, not a drawer entry.** The drawer menu comes from the backend's port of .NET LoginAppSuccess;
   adding a row there is a backend change. The work dashboards are the boarding user's home, and their
   tabs are app-side. So: `WorkTab.preAlert` → `PreAlertReportBody(workMode: true)`.
2. **One screen, two modes.** `PreAlertReport` (full page) wraps `PreAlertReportBody(workMode: false)`;
   the drawer behaviour is unchanged. `PreAlertStarted(workMode)` sets the defaults and loads own ports.
3. **Ports by name.** The report filters by port text, as the jobs store it; the assigned-port lookup
   already answers names. The chosen name is sent as `port`.
4. **Who is restricted.** Anyone with assigned ports: those only. No assigned port: the company's active
   ports and "All Ports", as the web (owner, 2026-10-20: a port picker must always be there).

## Risks

- Port matching is the report's `LIKE %port%`, the same as web and .NET.
- The server does not enforce the port limit (see proposal).
