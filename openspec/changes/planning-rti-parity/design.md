# Design: Planning and RTI parity matrix

## Abbreviations used below

**React paths:**
- `P/` is `maleva-front-end/src/features/Planning/`
- `R/` is `maleva-front-end/src/features/rti/`
- `FE/` is `maleva-front-end/src/`

**Backend:**
- `BE` is `maleva-backend/src/main/java/my/maleva/api/`

**Status (Flutter today):**
- **E**: exists
- **P**: partial
- **M**: missing

**Plan:**
- **Build**: new code in Phase 2
- **Port**: move the existing code into the new feature folder, plus the changes listed
- **Keep**: unchanged
- **Skip**: React has it but it is dead or broken. It is not built and is listed under questions.

**Access:**
- "emp" means employee token only. `SecurityConfig:240` rejects driver tokens.
- "drv" means drivers are allowed, limited on the server to their own records (`DriverRtiPolicy`).
- Plan screen access: `GET /api/screen-access/planning/me?companyRefId=` returns VIEW, CREATE, EDIT and DELETE (`P/permissions/planningAccess.ts:33-58`).
  - Write access (`canWrite`) is EDIT for a saved plan, or CREATE for a new plan.
  - Delete access (`canDelete`) needs DELETE.

---

## A. Planning: list of saved plans (React `PlanningView.tsx`, route `/planning/view`)

| # | React feature (file:line) | Endpoint | Fields / validation / rule | Roles | Flutter today | Flutter plan |
|---|---|---|---|---|---|---|
| A1 | Filters (`P/PlanningView.tsx:54-67, 105-113`) | POST `/api/planing/select-planning` body `{comid, fromdate, todate, search, employeeid}`; bare `{salemaster[], saledetails[]}` | From defaults to **yesterday**, To to today. Plan no. goes in `search`. Employee picker; "Login Employee" box sends own id. Error "From date cannot be greater than to date" | VIEW; emp | **E**: filter sheet (`planning_tab.dart:447-585`), but From defaults to today | Port: filter bottom sheet + chips; From = yesterday; same message. Dates use **local** time (React uses UTC, see Q-P10) |
| A2 | Plan-number search ignores the dates (server: `PlanningMasterService.java:820-824`) | same | Exact match on `CNumberDisplay` (e.g. `PL000000782`) | — | **E** (passes text through) | Keep the exact match, as on the server. See Q-P2 |
| A3 | Columns (`P/PlanningView.tsx:131-224`, mapper `utils/planningViewMapper.ts:80-123`) | same | ID, Planning No, Date (`02 Mar 2026`), Employee, Total Orders (`{n} orders`), Remarks, Report, Edit | — | **P**: card shows no., date, remarks; no employee or order count | Build card: plan no., date, employee, "{n} orders", remarks; expandable jobs |
| A4 | Sort (`:70`) | — | Client forces id ascending; headers not clickable | — | **E**: server order | Keep the server order (SaleDate DESC). See Q-P3 |
| A5 | Report (`P/api/planningReportApi.ts:19-36`) | GET `/api/planning/reports/{id}/pdf-ticket?companyId&reportDate` → `Data1.Url` | Header "Report Date" (default today) is sent as `reportDate`. Errors "Planning details are missing for the Planning report.", "Could not open the Planning report" | emp (no screen check) | **P**: opens PDF, no report date | Build: report-date picker in the sheet; same messages |
| A6 | Open plan (`:127-129, 208-223`) | — | Tap number, Edit, or double-click opens `/planning/edit/{id}` | VIEW | **P**: long-press opens a read-only list | Build: tap card → plan detail/edit screen |
| A7 | Access (`:236-238`) | screen-access | No VIEW → AccessDenied | VIEW | **M** | Build: "no access" state |
| A8 | Loading, empty, error | — | "Failed to load planning list", "Company is not available yet" | — | **P**: private widgets | Build: shared skeleton, empty and error (retry); pull to refresh |
| A9 | Auto reload on each filter change (`:92-125`) | — | Fires on every keystroke | — | — | Skip: apply on "Apply" in the sheet. See Q-P1 |

## B. Planning: create / edit (React `PlanningList.tsx` + `hooks/usePlanningListPage.ts`)

| # | React feature (file:line) | Endpoint | Fields / validation / rule | Roles | Flutter today | Flutter plan |
|---|---|---|---|---|---|---|
| B1 | Next plan no. (`usePlanningListPage.ts:334-366`; `usePlanningOperations.ts:74-94`) | POST `/api/planing/max-planning-no/{companyId}` → `{sequenceNumber}` | Preview only; the server assigns the number on save. Reloaded after Clear | emp | **E** | Port |
| B2 | Load by PLAN NO (`P/components/PlanningFilters.tsx:382-410`; `utils/planningNumber.ts:9-15`) | GET `/api/planing/edit?companyId&planningNo` | Digits only, 1..2147483647 ("PL000000782" → 782). Empty does nothing. Error "Planning data not found" | VIEW | **P**: only through the VIEW sheet by id | Build: plan-no. field (numeric keypad, Go); same parse rule (tests from `planningNumber.test.ts`) |
| B3 | Load by id (`usePlanningListPage.ts:260-329`; `utils/planningEditMapper.ts:37-178`) | GET `/api/planing/edit?id&companyId` → `PlanningEditResponseDto` (PascalCase) | Master: `Id, CNumberDisplay, SaleDate, FDate, TDate, EmployeeRefId, Remarks, Search, SaleDetails[]` | VIEW | **E** | Port into typed `PlanEdit` / `PlanLine` models read from the Java names |
| B4 | Header fields (`PlanningFilters.tsx:375-536`; defaults `constants/planningConstants.ts:26-35`) | — | PLAN DATE* (today), FROM (today), TO (today), PORT (adds to SEARCH, not saved), EMPLOYEE, SEARCH, REMARKS | write | **E** (port multi-select) | Port into section cards; searchable pickers |
| B5 | Search jobs (`usePlanningListPage.ts:572-586`; `utils/helpers.ts:295-303`) | POST `/api/planing/search` `{comid, search, employeeid, fromdate, todate}` → bare `PlanningDetailsModel[]` | "Please select a Planning Date"; "Please enter at least one search criteria". New plan: the result replaces the rows. Edit: merge by `saleOrderMasterRefId`, keeping truck, remarks, tick and sort | VIEW | **P**: needs a port; always replaces | Build: same two checks and the merge rule. See Q-P4 (search = ports on the server) |
| B6 | Line columns (`P/components/planningColumns.tsx:36-301`) | — | Tick, S.No, SORT, REMARKS, TRUCK, DRIVER, ORIGIN, DEST (address hover), PKG/WT, CUSTOMER, P.DATE, D.DATE, VESSEL, JOB NO, PIC, L ETA, O ETA, STATUS, RTI, remove | — | **P**: no vessel, PIC, ETAs, status or RTI | Build: line card with job no., customer, vessel, P/D date, truck and driver, status badge, RTI badge; the rest in an expandable section |
| B7 | Status colours (`P/components/planningStatusUtils.ts:9-73`) | — | Ordered regex → tone (danger, success, warning, info, primary, accent, else hash). Search defaults to 'Pending', edit to '' | — | **M** | Build `statusTone()` with the same order; unit tests from the table |
| B8 | Truck and driver cells (`planningCellRenderers.tsx:126-362`) | `/api/truck-combo`, `/api/driver-combo` | Outside-driver truck (`truckRefid==22` or name `OUTSIDE DRIVER`): typed driver name, `driverRefid=0`. No truck: free text. Red on critical expiry; purple or indigo for driver leave | write | **P**: dropdowns, no expiry or leave colours | Build pickers with the same three modes and colours. Expiry and leave fields come from the combo rows (to be confirmed in Phase 2) |
| B9 | Edit SORT, remarks; Sort button (`usePlanningOperations.ts:37-57`) | — | Drops a trailing empty row, then sorts by SORT ascending with 0 or empty **last** | write | **E** (`_sortPlanningItems`) | Port with that rule; unit test |
| B10 | Reorder by drag (`utils/planningRowOrder.ts:8-28`) | — | Save keeps the grid order | write | **M** | Build: `ReorderableListView` handle; tests from `planningRowOrder.test.ts` |
| B11 | Remove row (`usePlanningOperations.ts:288-298`) | — | Confirm "Delete Record" / "This action cannot be undone. Continue?"; toast "Row removed" | write | **E** | Port with the same text |
| B12 | Clone row (`usePlanningOperations.ts:251-285`; `PlanningFilters.tsx:539-548`) | — | Confirm "Duplicate Planning Row?"; "Please select a row to duplicate"; "Cannot duplicate: Row does not have a valid sale order"; truck cleared; "Row duplicated successfully" | write | **M** | Build |
| B13 | Bulk apply truck, driver or dates | — | Not in React | — | **E** (`_showBulkApplySheet`) | Skip, because it is not in React. See Q-P15 |
| B14 | Save (`utils/planningSavePayload.ts:110-263`; `usePlanningOperations.ts:97-178`) | POST `/api/planing/save`, header `Comid`, body `[plan]` → `[{ok, message, id}]` | Checks: "Company ID is required", "Planning date is required", "From date is required", "To date is required", "Please add at least one valid row in the table before saving". Dates `yyyy/MM/dd`. `!ok` → message. New: "Planning saved successfully", then open the saved plan. Edit: "Planning updated successfully" | CREATE (new) / EDIT; server `PlanningAccessPolicy` | **E** (`planning_save_body.dart`) | Port: same checks and messages; busy state stops a double save; reload the plan after save instead of the page |
| B15 | Delete plan (`usePlanningOperations.ts:181-212`; `PlanningList.tsx:411-420`) | DELETE `/api/planing/{id}?companyId` → `{ok, message}` | "No planning selected to delete"; confirm "Delete Planning" / "Are you sure you want to delete this planning? This action cannot be undone."; "Planning deleted successfully" | DELETE | **E** | Port: hidden without DELETE |
| B16 | Clear (`usePlanningListPage.ts:653-665`) | — | Reset, new number, "Form cleared" | — | **E** (NEW) | Port |
| B17 | Sale-order update (`FE/components/modals/UpdateSaleOrderModal.tsx`; `utils/planningSaleOrderUpdate.ts:98-276`) | GET sale-order edit; POST `/api/planing/update-dates` (18 keys) | "Please select a row first"; "Selected row does not have a sale order to update"; confirm "Sale Order Update" / "Do you Want to Update the Details?"; then every line of the job is patched | EDIT; server `canEdit` | **E** (`SaleOrderApi.planningUpdate`) | Port into its own sheet; tests from `planningSaleOrderUpdate.test.ts` |
| B18 | Excel/CSV (`usePlanningListPage.ts:935-989`) | — | CSV `Planning_Export_{date}.csv` | — | **M** | Build: share the CSV through `share_plus` (already a dependency). See Q-P19 |
| B19 | Access gating (`P/permissions/planningAccess.ts`; `PlanningList.tsx:225-237`) | GET `/api/screen-access/planning/me` (`BE/module/screenaccess/ScreenAccessController.java:36`) | Banner "View only. … (Utils → Screen Access)"; locked actions toast `deniedReason` / `deleteDeniedReason` | — | **M**: menu flags ignored | Build `PlanningAccess` with the same rules; tests from `planningAccess.test.ts` / `planningAccessUi.test.tsx` |
| B20 | Truck-location board link, Refresh | — | — | — | — | Skip the board (web page); Refresh becomes pull to refresh |

## C. Planning → RTI

| # | React feature (file:line) | Endpoint | Fields / validation / rule | Roles | Flutter today | Flutter plan |
|---|---|---|---|---|---|---|
| C1 | Push RTI (`usePlanningOperations.ts:223-248`; `R/services/planningTransferService.ts:151-444`) | none; opens the RTI form prefilled | "Please select orders to push to RTI". Truck and driver from the first item; an outside driver goes to `outsideDriver`/`outsideTruck`; "Loaded N planning order(s) into RTI" | write | **P**: passes only job no., customer, date | Port: pass the full item (truck, driver, dates, addresses, lists) |
| C2 | Create RTI now (`usePlanningListPage.ts:703-744`; `R/services/planningDirectCreateService.ts:121-257`) | POST `/api/rti-masters` | Messages in order (inventory §3): one truck, one driver, outside name, "Truck "{name}" was not found…". OUTSIDE DRIVER and NONE truck resolved by name (React fallback ids 22, 43). "RTI {no} created with {n} job(s)" | write; emp | **M** | Build. See Q-C2 (hard-coded ids) |
| C3 | Create All RTI (`P/hooks/useCreateAllRti.ts`; `components/CreateAllRtiModal.tsx`; `utils/planningRtiBatch.ts`) | GET `/api/planing/{id}/rti-batch/preview?companyId&includeExisting`; POST `/api/planing/{id}/rti-batch` | "Save the plan first, then create its RTI."; groups with driver source; driver picker; skipped panel; "Skip jobs that already have an RTI"; "Tick at least one truck to create."; result messages; rows stamped | write; emp | **M** | Build as a full-screen sheet; tests from `planningRtiBatch.test.ts` (all cases). See Q-C3 |
| C4 | RTI status per row (`usePlanningListPage.ts:758-807`) | POST `/api/rti-details/rti-status` body `[ids]` → `[{saleOrderMasterRefId, rtiMasterRefId, rtiNo}]` | Refreshed when the job set changes. Failures are silent | emp | **M** | Build: RTI badge on each line, and refresh after create or create-all |
| C5 | RTI Revise and Open RTI from a planning row (`usePlanningListPage.ts:813-868`) | revise + PUT | Handlers exist, but `planningColumns.tsx:37` never renders them | — | **M** | Skip in Planning (not reachable in React). The RTI badge opens the RTI detail, where Revise lives. See Q-C5 |

## D. RTI: list (React `RTIViewPage.tsx`)

| # | React feature (file:line) | Endpoint | Fields / validation / rule | Roles | Flutter today | Flutter plan |
|---|---|---|---|---|---|---|
| D1 | Filters (`R/pages/RTIViewPage.tsx:55-160, 409-486`) | React: GET `/api/rti-masters/company/{id}/active` (emp, bare list). App: GET `/api/rti-masters/with-jobs` (`ApiResponse`, drv-scoped, includes jobs) | From and To default today; Driver, Truck, RTI No (exact match; overrides the dates); "My RTIs" sends `employeeId`; "Not Salary Entered" (client: amount 0) | emp (React) | **E**: date, driver, truck, RTI no.; no My RTIs, not-salary | Build both missing filters on `with-jobs`. See Q-R4 |
| D2 | Columns and preview (`:275-372, 749-848`) | `with-jobs` carries the jobs | RTI No, Date, Driver, Truck, Amount `RM x.xx`, Remarks; preview with destination and job chips `JobNo · Customer` | — | **E** (cards with job lines) | Port: card with RTI no., date, driver, truck, amount, job count; expandable jobs |
| D3 | Stats and states (`:506-516`) | — | Records and Total Amount; loading, timeout, error and empty texts | — | **P** | Build: summary strip; shared states; empty text as in React |
| D4 | Report (`R/api/rtiReportApi.ts:20-29`) | GET `/api/rti-masters/{id}/report-ticket?companyId` → `Data1.Url` | "Could not open the RTI report" | drv | **E** | Port |
| D5 | WhatsApp share (`R/components/RtiShareWhatsAppButton.tsx`; `api/rtiShareApi.ts:37-40`) | POST `/api/rti-masters/{id}/share-whatsapp` `{companyId}` → `Data1 {sent, rtiNo, truck, detail, documentSkipped}` | Confirm "Send {rtiNo} to the truck's WhatsApp group?"; "{rtiNo} sent to the group of {truck}"; `documentSkipped`; "The message was not sent"; "Could not share this RTI" | emp | **M** | Build; hidden for drivers |
| D6 | Duplicate RTI list screens | — | — | — | RTI View tab (Jan–Dec), Update RTI, the mock `CreateRTIScreen` | Replace RTI View and Update RTI with one RTI list; delete the mock |

## E. RTI: create / edit / delete (React `RTIPage.tsx`)

| # | React feature (file:line) | Endpoint | Fields / validation / rule | Roles | Flutter today | Flutter plan |
|---|---|---|---|---|---|---|
| E1 | Next number (`R/api/rtiApi.ts:148-203`) | GET `/api/sequence-masters/company/{id}` (`rtimaster` + 1, `RTI%09d`) | Preview; the server assigns the number | emp | **E** | Port |
| E2 | Header fields (`R/components/RTIFormFields.tsx:344-606`; `rtiService.ts:565-704`) | — | Inventory §3 table: date, driver*, outside driver, vehicle*, outside truck, Enter/Exit link, punctuality, document, multiple pickup, sleeping, empty pickup/delivery, add pickup/drop + count, manpower, destination, seal by, break seal by, remarks, comments | emp | **E** (no outside driver or truck) | Port into step cards; add outside driver and truck |
| E3 | Validation (`R/model/rti.validation.ts:46-81`) | — | "Please select Driver Name", "Please select Vehicle Number", "Please select RTI Date", "Please add at least one job", "Row {n}: Job No is required", "Row {n}: job {JobNo} was not found. Press Enter in Job No to look it up, or remove the row." | — | **P** (different text) | Build the validator with React's text; tests from `rti.validation.test.ts` |
| E4 | Expiry warnings (`RTIFormFields.tsx:146-168, 297-299`; `rti.validation.ts:16-41`) | GET `/api/truck-masters/{id}` | Create only: 12 licence fields expiring within 5 days → "{names} - License expired / Going to be expired !!" | emp | **M** | Build: warning banner; test |
| E5 | Job number (`R/hooks/useRTIOperations.ts:295-339`; `rtiApi.ts:457-531`) | React: POST `/api/sale-orders/search` + exact match, then GET `/api/sale-orders/{id}`. App: GET `/api/rti-masters/company/{id}/job-search?jobNo` | Typed, looked up on Enter; "Job not found."; several matches insert extra rows; the same job may repeat | emp | **E** (job-search sheet) | Keep the app's `job-search` lookup. See Q-R5 |
| E6 | Lines grid (`R/components/RTIGrid.tsx:25-90`) | — | Editable: Job No, Salary, PPIC, DPIC, PWD; read-only: customer, job date, origin, destination, P/D date. Delete confirm "Delete RTI row?" | — | **E** | Port as line cards with an edit sheet; numeric Salary |
| E7 | Amount rule (`R/services/calculationService.ts:13-59`) | — | Σ salary + sleeping 50 + empty 80/50 + manpower 50/100 + 30×pickups + 30×drops, rounded to 2 places | — | **E** (`RtiEntryApi.amounts`) | Keep; add all `rtiMoney.test.ts` cases |
| E8 | Save (`R/api/rtiApi.ts:310-378`; `useRTIOperations.ts:104-160`) | POST `/api/rti-masters` (201) or PUT `/api/rti-masters/{id}`; master + `rtiDetails` (+ `routeActivities`) | "Company is required before saving RTI."; "RTI saved successfully" then edit mode; "RTI updated successfully" then reload; "Failed to save RTI." | emp | **E** | Port; busy state; detail payload keys locked by a test (15 keys) |
| E9 | Delete (`useRTIOperations.ts:162-272`) | DELETE `/api/rti-masters/{id}` (204, soft) | Confirm "Delete RTI" / "Do you want to permanently delete this RTI? This action cannot be undone."; "RTI deleted successfully" | emp | **E** | Port with the same text |
| E10 | Route activities (`R/components/RTIRouteActivitiesGrid.tsx`; `useRTIState.ts:148-188`; `rtiService.ts:411-439, 663-697`) | inside the master POST/PUT; employees GET `/api/employees/company/{id}/all?type=ALL` | Seq (last + 1, start 10), destination (16 fixed + custom), agent (employee or typed), mobile, driver number (row 0 copies to all), job type (SEAL, BREAK SEAL, SEAL AND BREAK ↔ `SEAL,BREAK_SEAL`, K1/K2/K3/K8), full route, Marqis, remarks, ETA; delete confirm | emp | **M** in the form (app omits `routeActivities` so it keeps web stops) | Build the section; once loaded, send the full list as React does |
| E11 | Levi entry (`R/components/RTILeviEntryModal.tsx`; `FE/features/pass-entry/api/passEntryApi.ts:88-122`) | `/api/levi-entries/by-rti/{rtiId}`, `/next-no`, POST, DELETE; attachments folder `LeviEntry` (`BE/module/fleet/controller/LeviEntryController.java`) | IN and OUT slots; Link from the RTI's Enter/Exit link; messages "Save the RTI first", "Choose IN or OUT", "Select a truck", "Select a driver", "Enter an amount", "Amount must not be negative"; duplicate-leg guard | emp | **M** | Build (saved RTI only); tests from `rtiLeviEntryModal.test.tsx`. See Q-R17 (React deletes without a confirm) |
| E12 | Print from the form | — | React RTIPage has no Report button | — | **E** (app-bar PDF) | Keep it on the RTI detail screen |

## F. RTI revise

| # | React feature (file:line) | Endpoint | Fields / validation / rule | Roles | Flutter today | Flutter plan |
|---|---|---|---|---|---|---|
| F1 | What revise loads (`R/api/rtiApi.ts:394-409`; `BE/module/rti/service/impl/RTIMasterServiceImpl.java:551`, ported from .NET `RTIServices.cs:615 ReviseRTI`) | GET `/api/rti-masters/{id}/revise?companyRefId` → `Data1` master + `rtiDetails` + `routeActivities` | Same RTI, same number, no new record. Each line's job no., job date, P/D dates, origin, destination and customer are re-read from the **current sale order**. The server also re-copies RTIPickup/RTIDelivery and the warehouse fields | emp | **E** ("LOAD" button) | Build the flow below |
| F2 | What is saved (working path: `R/services/planningDirectCreateService.ts:265-297` `reviseRTIInPlace`) | PUT `/api/rti-masters/{id}` | Revised lines + the form, validated, then PUT. It differs from edit only in that the lines are refreshed from the sale orders before saving | emp | **P** | Flow: RTI detail → **Revise** → confirm "Do you want to revise data from the Sales Order? This will overwrite the current RTI information." → the screen shows the refreshed lines, with changed values marked → user edits → **Submit revision** (confirm) → PUT → "RTI revised successfully" |
| F3 | RTIPage Revise button (`R/hooks/useRTIOperations.ts:184-198, 274-293`) | same GET | React **throws the result away** and shows success without saving | — | — | Skip that defect; Flutter follows F2 |
| F4 | `?revise=1` from Planning (`R/pages/RTIPage.tsx:129-150`) | — | Not reachable in React (C5) | — | — | Skip; RTI detail → Revise covers it |
| F5 | Revise with no lines (`RTIMasterServiceImpl.java:578-581`) | — | Returns `routeActivities: null`; a later save would wipe the stops | — | — | When `routeActivities` is null, Flutter keeps the stops it loaded. That is a client-side guard, not a backend change |

## G. Job status, PDO, route activities, employee assignments

| # | React feature (file:line) | Endpoint | Fields / validation / rule | Roles | Flutter today | Flutter plan |
|---|---|---|---|---|---|---|
| G1 | Driver job status | POST `/api/rti-masters/jobs/{id}/status` | Not used by React (app-only driver flow) | drv | **E** (`RTIStatusPage`) | Keep; reach it from the RTI detail job line |
| G2 | PDO / TransportDB verify | POST `/api/rti-masters/job-statuses` | App-only (.NET port) | drv | **E** | Keep (not part of the React modules) |
| G3 | Route stops for forwarding agents | `/api/rti-route-activities` | App-only | — | **E** | Keep |
| G4 | Employee Assignments (`R/pages/EmployeeAssignmentsPage.tsx`; `api/employeeAssignmentsApi.ts:38-49`; `BE/module/rti/controller/RtiJobWiseController.java:44`) | POST `/api/rti/employee-assignments` `{fromDate, toDate, companyId, employeeId}` → `Data1[]` (range ≤ 90 days) | "Please select both From and To dates"; employee picker; "My Job Only" (React also compares names on the client); card fields RTI no., SO no., customer, pickup, delivery, origin, destination, vessel, commodity, qty, truck size, pickups, drops, employee, driver, truck; report | emp | **M** | Build; "My Job" sends the logged-in employee id (the server filters) without the name check. See Q-R8 |

## H. Roles

| # | Rule | Source | Flutter plan |
|---|---|---|---|
| H1 | Planning actions | B19 | Hide or lock as React does; the server enforces the same rules |
| H2 | RTI actions | No role check in `R/` (inventory §11) | Office users see every action, as in React. Drivers see only list, PDF and job status, because every other RTI endpoint refuses driver tokens |
| H3 | Menu entry | `lib/menu/menulist.dart` `FormText` "Planning", "Update RTI Details" | Point both at the new screens; add "Employee Assignments" if the server menu has a row for it (Q-H3) |

---

## Gaps: React features with no usable API

- POST `/api/planing/sort` and `/api/planing/push-rti` have no Java endpoint. React never calls them either (sorting is client-side, and push hands the rows over in the browser). **Nothing is blocked.**
- Every other React call has a Java endpoint (backend audit, 33 calls).

## Questions for the owner

- **Q-P1:** Should the plan list reload on each filter change, as React does, or on Apply? *Proposed: on Apply.*
- **Q-P2:** Plan-number search on the list is an exact `PL000000782` match on the server. Should typing "782" be turned into the padded form on the client, as React's PLAN NO box does on the form?
- **Q-P3:** Should the list be ordered newest first (server order) or by id ascending (React's client sort)? *Proposed: newest first.*
- **Q-P4:** The SEARCH placeholder says "Job numbers", but the server treats it as port codes. *Proposed: label it "Ports", as the server reads it.*
- **Q-P10:** React computes "today" in UTC, so before 08:00 in Malaysia it gives yesterday. *Proposed: Flutter uses local time.*
- **Q-P15:** Should the app's "Bulk apply" sheet, which React does not have, be dropped?
- **Q-P19:** Is a CSV export needed on the phone at all?
- **Q-C2:** Should React's OUTSIDE DRIVER (22) and NONE truck (43) fallback ids be copied, or should a missing name be an error? *Proposed: an error.*
- **Q-C3:** Create All RTI matches created RTIs to groups by truck and job count, so two trips on the same truck with the same number of jobs can be stamped wrongly. *Proposed: Flutter re-reads `rti-status` after the create instead.*
- **Q-C5:** Should a planning row with an RTI offer "Revise RTI" directly? React wired the handler but never shows it.
- **Q-R4:** React lists through `/active` (employee only). The app uses `/with-jobs` (shared, driver-scoped, includes the jobs). *Proposed: keep `/with-jobs`.*
- **Q-R5:** React looks up a job with `/api/sale-orders/search` plus an exact match. The app uses the dedicated `/api/rti-masters/company/{id}/job-search`. *Proposed: keep `job-search`.*
- **Q-R6:** Agent company and agent are loaded but never shown or saved in React. *Proposed: leave them out.*
- **Q-R7:** React overwrites `employeeRefId` and `createdBy` with the current user on every edit. Should Flutter copy that, or keep the creator?
- **Q-R8:** "My Job Only" on Employee Assignments: is the employee id enough, without React's name comparison?
- **Q-R17:** Should Levi delete ask for a confirm, even though React deletes without one? *Proposed: yes, as every other delete does.*
- **Q-H3:** What is the menu `FormText` for Employee Assignments?
- **Q-UI1:** The app has no dark theme (`main.dart:139-144`). Light and dark "from the theme tokens" needs an app-wide `darkTheme` and token pairs. Should that be built inside this change, or should the new screens only read `Theme.of(context)` so dark mode follows later?
- **Q-V1:** `AppConfig.javaBaseUrl` points at the **live** server. Phase 3's create, edit, revise and push test against "the dev backend" needs the dev URL and a test company and login. I will not write test RTIs or plans to live.

---

# UX and design

## U1. Problems today (evidence)

The counts below were taken from the code on 2026-10-05.

| Screen file | Lines | Wide tables | Old `colour.*` uses | Hand-set `fontSize` | `setState` | Controls under 48 px | Long-press only | Pull to refresh |
|---|---|---|---|---|---|---|---|---|
| `transaction/planning/view/planning_tab.dart` | 703 | 12 | 49 | 0 | 0 | 4 | 1 | no |
| `transaction/planning/view/add_planning_page.dart` | 1795 | 2 (13 columns, sideways scroll) | 79 | 72 (mostly 11–13) | 22 | 17 | 0 | no |
| `transport/updatertidetails/view/updatertidetails_tab.dart` | 1124 | 0 | 6 | 0 | 6 | 1 | 1 | no |
| `transport/updatertidetails/view/add_rti_page.dart` | 1453 | 1 (13 columns, sideways scroll) | 0 | 48 | 35 | 7 | 0 | no |
| `dashboard/common_tabs/rtiview/view/rtiview_tab.dart` | 840 | 3 | 30 | 0 | 2 | 2 | 0 | no |
| `dashboard/common_tabs/rtistatus/view/rtistatus_tab.dart` | 468 | 0 | 28 | 0 | 0 | 1 | 1 | no |

Problems the numbers don't show:

| # | Problem | Where | Fix |
|---|---|---|---|
| U1.1 | Eight equal buttons in one bar; Delete next to Save | `add_planning_page.dart:1580-1608` | One main action plus overflow; Delete separate (U3.7) |
| U1.2 | "LOAD" means revise; "VIEW" just closes the page | `add_rti_page.dart:1221-1300` | Plain labels: "Revise from sale orders"; remove VIEW |
| U1.3 | Plan details and job status open only on long-press | `planning_tab.dart:64-73`, `updatertidetails_tab.dart:560-578` | Visible tap targets; long-press only as a shortcut for selecting |
| U1.4 | Active filters not shown | filter FAB on the plan and RTI lists | Search bar and filter chips (U3.3) |
| U1.5 | Three RTI lists with different defaults and looks; a fake Create screen | RTI View, Update RTI, PDO; `create_rti_screen.dart` | One RTI list and one form |
| U1.6 | Success and errors in blocking dialogs | `msgshow` | Snackbars, and errors under the field |
| U1.7 | No dark theme; Material 3 off; date picker forced dark on one screen | `main.dart:139-144`, `planning_tab.dart:622` | U2 theme |
| U1.8 | Each screen has its own tablet branch | `isTablet` used 30× in `planning_tab.dart` | Width breakpoints in a shared layout (U4.0) |
| U1.9 | Misleading titles: "Update RTI" on the create page; "Return to Inventory" | `add_rti_page.dart`, `rtiview_tab.dart:313` | "New RTI" / "Edit RTI" / "RTI" |
| U1.10 | Three private copies of loader, empty and error views | `planning_tab.dart:656-703`, Update RTI, RTI View | Shared states (U3.5) |

## U2. Design system (foundation)

| Token | Rule |
|---|---|
| Theme | `useMaterial3: true`. `ColorScheme` built from the brand blue (`Palette.blue950` / `blueCobalt`), with `theme` and `darkTheme` in `main.dart`, following the system setting. Screens read only `Theme.of(context)` and `AppTokens`, never `colour.*` or a raw `Color(0x…)`. |
| Status tones | The seven React tones (`planningStatusUtils.ts:9-17`): success, warning, danger, info, primary, accent, neutral. Each is a pair (container + on-container) in light and dark, kept in one `StatusTone` enum. |
| Type | `AppTypography` mapped to the `TextTheme`. Body is 14 or more, labels 12 or more (captions only). Titles go up to 20–22. Numbers and money use tabular figures. Text follows the phone's text size. |
| Spacing | 4/8 grid: 8, 12, 16, 24. A 16 px page gutter. 12 px between cards. |
| Shape | Cards 12 px radius with a 1 px outline-variant border and no heavy shadow. Inputs 10 px. Sheets 20 px top corners. |
| Touch | Every tap target is 48 dp or more. The main button is full width and 52 dp high. |
| Motion | 150–250 ms: card expand, sheet slide, skeleton shimmer done with the SDK only (no new package). |
| Icons | Material Symbols outlined, one icon per meaning (e.g. truck = `local_shipping`, driver = `badge`, RTI = `receipt_long`). |

## U3. Shared components (`lib/core/widgets/`)

| # | Component | Purpose |
|---|---|---|
| U3.1 | `AppPage` | Scaffold with a large title that collapses on scroll, pull to refresh, safe-area sticky bottom bar, and keyboard-aware padding |
| U3.2 | `EntityCard` | Title line (number + status badge), subtitle (customer/vessel), meta row (date · truck · driver), trailing chevron; optional expandable body; selection checkbox in selection mode |
| U3.3 | `SearchFilterBar` + `FilterSheet` + `FilterChips` | Search field, a filter button showing the count, removable chips for each active filter, and "Clear all" |
| U3.4 | `StatusBadge` | Tone from `statusTone()` (same regex order as React); dot + text |
| U3.5 | `SkeletonList`, `EmptyState`, `ErrorState` | Skeleton cards while loading; empty with icon, text and action; error with the server message and **Retry** |
| U3.6 | `SectionCard` / `StepHeader` | Numbered form sections; collapsible; shows a check or an error count |
| U3.7 | `ActionBar` | One main action, up to one secondary, the rest in an overflow menu. A selection-mode variant shows "{n} selected" with the actions for the selection |
| U3.8 | `ConfirmSheet` | Title, message (React text) and buttons; the destructive variant is red |
| U3.9 | `AppSnack` | Success, info and error snackbars; the error can show details |
| U3.10 | Fields | `AppFormField`, `AppTextInput`, `SearchablePickerField`, plus `DateField`, `MoneyField` (RM, numeric keypad), `SegmentedChoice` (YES/NO, NO/1/2, NO/EMPTY 80/EMPTY 50), `CountStepper` |
| U3.11 | `KeyValueRow`, `MoneyText`, `InfoBanner` | Detail rows; "RM 1,234.50"; warning banner (expiry, view only) |

## U4. Screen layouts

**U4.0 Breakpoints.** Under 600 dp: one pane. At 600 dp or more: list on the left, detail on the right.
The same widgets are used in both.

| # | Screen | Layout |
|---|---|---|
| U4.1 | **Plans** (list) | Large title "Planning". Search (plan no.) with chips (dates, employee, "My plans"). Cards show the plan no. and status, date, employee, "{n} orders" and remarks; expanding shows the jobs. FAB "New plan" (CREATE only). Overflow: Report (with report date). |
| U4.2 | **Plan editor** | Header card: plan no., plan date, from–to, ports, employee, remarks. Then "Find jobs", then the line cards. Each line card shows: sort no. and drag handle, job no., status badge, RTI badge; customer · vessel; P.date → D.date; origin → destination; truck and driver chips (tap to pick). Expandable: PKG/WT, PIC, L/O ETA, addresses. Bottom bar: **Save**, overflow (Sort, Clear, Report, Delete). Tick lines to enter selection mode: **Create RTI**, Push to RTI, Clone, Update sale order. A separate **Create all RTI** button sits in the header once the plan is saved. View-only role: an info banner, with fields and actions locked. |
| U4.3 | **Create all RTI** | Full-screen sheet. Summary strip ("{trucks} RTI · {jobs} jobs"). The "Skip jobs that already have an RTI" switch. One group card per truck: tick, truck, trip label, driver-source pill, driver picker, job list. Collapsible "Will not get a new RTI" panel. Sticky button "Create {n} RTI". |
| U4.4 | **Sale-order update** | Sheet with sections Job & schedule, Cargo, Warehouse, Pickups, Deliveries. Sticky "Save" with a confirm. |
| U4.5 | **RTIs** (list) | Large title "RTI". Search (RTI no.) with chips (dates, driver, truck, "My RTIs", "Not salary entered"). Summary strip: records and total RM. Cards show the RTI no. and amount, date, driver · truck, "{n} jobs", destination. FAB "New RTI" (office only). Drivers see only their own RTIs and no FAB. |
| U4.6 | **RTI detail** | Hero card: RTI no., date, total RM, driver, truck. Sections: Trip, Allowances (each charge with its RM), Jobs (cards; tap a job → job status for drivers), Route stops, Levi (IN/OUT slots). Bottom bar: **Edit**; overflow: Revise from sale orders, PDF, Share to WhatsApp, Levi entry, Delete. |
| U4.7 | **RTI form** (new/edit) | Five steps, shown as a step header: 1 Trip (date, driver, vehicle, outside driver/truck, links, expiry banner) · 2 Jobs (type job no. → look up; job cards with Salary, PPIC, DPIC, PWD) · 3 Allowances (segmented choices, counts) · 4 Route stops · 5 Review (charges summary, total, warnings). The total RM is always visible in the bottom bar. **Save** stays disabled with a spinner while saving. |
| U4.8 | **Revise** | From the RTI detail: confirm (React text). A review screen lists each job with changed values marked "was → now", and the route stops kept. The user may edit them. **Submit revision** → confirm → PUT → snackbar "RTI revised successfully" → back to the detail. |
| U4.9 | **Levi entry** | Sheet with IN and OUT tabs showing their state ("Not filed" or the number). Fields: date, link, truck, driver, amount, remarks, attachments. **Save IN** / **Update OUT**. |
| U4.10 | **Employee assignments** | Search with chips (dates, employee, "My jobs"). Cards: RTI no. (PDF), SO no., customer; route and dates; cargo; pickups and drops; employee, driver and truck. |

## U5. Rules each screen is checked against (Phase 3)

1. No `colour.*`, raw `Color(0x…)` or raw `fontSize` in the new feature folders (a test greps for them).
2. Every tap target is 48 dp or more. Body text is 14 or more. Text scaled to 130 % does not overflow.
3. Screenshots in light and dark at 320×568, 390×844 and a tablet size.
4. Loading shows a skeleton. Empty and error states have an action. Lists support pull to refresh.
5. One main action per screen. Every destructive action is red and confirmed with React's text.
6. Busy state on every submit; a second tap does nothing.
7. Errors show under the field, using React's messages.
8. No action is reachable only by long-press.
