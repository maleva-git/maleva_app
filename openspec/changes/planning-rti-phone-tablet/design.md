# Design: Planning and RTI on phone and tablet (Step 1, parity matrix)

## Key

**React paths**
- `P/` = `maleva-front-end/src/features/Planning/`
- `R/` = `maleva-front-end/src/features/rti/`
- `FE/` = `maleva-front-end/src/`

**Roles**
- Planning comes from screen access (`P/permissions/planningAccess.ts:33-58`, `GET /api/screen-access/planning/me`):
  - **V**: VIEW
  - **W**: `canWrite` (CREATE on a new plan, EDIT on a saved one)
  - **D**: DELETE
- RTI has **no role check** in React (`R/`). Every RTI endpoint except those marked **drv** refuses driver tokens (`SecurityConfig:240`).

**Flutter today (Today)**
- **E**: exists
- **P**: partial
- **M**: missing

**Plan**
- **Build**: built in Step 3
- **Keep**: the existing app feature stays
- **⏳**: deferred, with the reason
- **⛔**: waiting on an owner question

**Layouts**
- **Phone**: under 600 dp
- **TP**: tablet portrait, 600–900 dp
- **TL**: tablet landscape, over 900 dp

---

## 0. Corrections to the reference facts

Each item below is what the code does, where it differs from the brief.

| # | Brief said | The code says (file:line) |
|---|---|---|
| K1 | Search payload from `planningSearch.ts` | The live page uses `helpers.ts:264-271` `hasSearchCriteria` and `helpers.ts:295-303` `buildSearchPayload`, called at `usePlanningListPage.ts:47-48, 579-584`; it sends `employeeid: Number(employee) \|\| 0`. `planningSearch.ts:21-27` (`employeeid: 0`) has no caller. The answer is read with `planningSearch.ts:139` `mapPlanningSearchResults` (`hooks/usePlanningSearch.ts:5-11`). |
| K2 | On merge, existing rows keep truck, remarks and tick | They also keep **sort** and the driver. New rows come in with truck '', `truckRefid` 0 and remarks '' (`usePlanningListPage.ts:189-231`). |
| K3 | Driver cell is plain text with no truck | With no truck it is a **free-text input** (`DriverInputCell`, `planningCellRenderers.tsx:126-272`). With OUTSIDE DRIVER (id 22 or that name) it shows a typed name plus the picker. |
| K4 | Every text cell can be copied | Yes. The copy button shows the toast `Copied: {value}` (`planningCellRenderers.tsx:370-380`). Truck and driver cells also have Copy (`:233, :325`). |
| K5 | Tablet keys F1 Save, F5 View, F10 Clear, Enter/Shift+Enter, Insert | Planning has only **F5 → View** (`usePlanningListPage.ts:383-386`) and **Delete** (Alt+Delete inside an input) to remove the selected row (`:389-402`). F1, F5 and F10 belong to the **RTI** page (`R/pages/RTIPage.tsx:169-173`). Enter/Shift+Enter, Insert, Ctrl+Delete, Esc, Ctrl+Home/End and the arrows belong to the **RTI grid** (`R/components/RTIGridCell.tsx:98-182`). F3 and F9 are defined (`R/model/rti.schema.ts:71-75`) but not wired. |
| K6 | Push toast "Loaded N planning orders into RTI" | Singular and plural: `Loaded ${n} planning order\|orders into RTI` (`R/hooks/useRTIPlanningTransfer.ts:98-102`). |
| K7 | Create RTI refusal list | The first message is "Tick the jobs for this RTI first, or use Create All RTI" (`usePlanningListPage.ts:703-744`), then the service's messages (`planningDirectCreateService.ts:121-257`). |
| K8 | RTI title "RTI (Employee)" | `RTI (${localStorage.EmployeeName})`, or just `RTI` (`R/components/RTIPageHeader.tsx:88`). |
| K9 | Revise toast "RTI revised successfully" | It is a **modal**, not a toast (`R/hooks/useRTIOperations.ts:191-194`), and the result is thrown away (see Q-REV). |
| K10 | Status default | Search gives `'Pending'` (`planningSearch.ts:93`); edit gives `''`, shown as "—" (`planningEditMapper.ts`). The same job can look different depending on how it was loaded. |
| K11 | Planning View loads automatically | It also reloads on **every filter change**, with no debounce (`P/PlanningView.tsx:92-125`). From and To use **UTC** dates (`:54-67`). |
| K12 | RTI list endpoint `/active` | Correct for React (`R/api/rtiApi.ts:206-294`). It is employee-only. The app already uses `/with-jobs`, which drivers may call and which includes the jobs (Q-RTI-LIST). |
| K13 | RTI list Clear turns My RTIs on | Yes, but **on first open My RTIs is off** (`RTIViewPage.tsx:107` vs `:153`). |
| K14 | Truck / driver lists | Planning and RTI trucks: `GET /api/truck-masters/alltruckdetatilcombo?companyId&keyword&column=All` (`FE/api/truckApi.ts:108-117`). Drivers: `GET /api/driver-masters/selectalldriverDetails?companyId` (`FE/api/driverApi.ts:149-168`). Both employee-only. |
| K15 | Truck expiry | Red ("critical") at 3 days or fewer; the warning starts at 10 days (Rotex, Puspakom) or 5 days (Service, Alignment, Greece, Gear Oil) (`FE/utils/truckExpiryWarnings.ts:11-20`). The RTI vehicle check is separate: 12 fields, 5 days (`R/model/rti.validation.ts:16-41`). |
| K16 | Levi delete | **No confirm** (`R/components/RTILeviEntryModal.tsx:357-362, 777-785`). |
| K17 | Employee Assignments "My Job Only" | It sends the logged-in employee id **and** filters by name on the client (`EmployeeAssignmentsPage.tsx:59-65`). Nothing loads until Search. Status is hard-coded "Active" (`:418-423`). |
| K18 | RTI Job No lookup body `{Comid, Search}` | The body is the full sale-order filter, 19 keys (`R/api/rtiApi.ts:457-531`). It reads `Data1.salemaster[]`. |
| K19 | Agent company and agent on the RTI form | Loaded (`RTIFormFields.tsx:258-280`) but **never shown or saved** (save snapshot: 37 master keys with no agent fields). |
| K20 | RTI edit | Everything stays editable. Only the vehicle licence check is skipped (`RTIFormFields.tsx:297`). The update replaces **all** detail and route-activity rows. |

---

## 1. Planning: access

| # | React (file:line) | API | Rule / message (word for word) | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| PA1 | `planningAccess.ts:33-58`; `useScreenAccess.ts:13-23` | GET `/api/screen-access/planning/me?companyRefId` | VIEW, CREATE, EDIT and DELETE. While loading: VIEW only | — | M | — | — | Build |
| PA2 | `PlanningList.tsx:165-167`; `PlanningView.tsx:236-238` | — | No VIEW → AccessDenied | — | M | Full-screen notice | Same | Build |
| PA3 | `PlanningList.tsx:225-237` | — | "View only. {Your role ({roleName}) can \| You can} open, search and export plans. The Super Admin decides who may create and change plans (Utils → Screen Access)." | V | M | Banner | Banner | Build |
| PA4 | `PlanningFilters.tsx:31-43` | — | A locked button shows a lock; a tap shows toast `deniedReason` (toast id `planning-access-denied`) | — | M | Same | Same | Build |
| PA5 | `planningAccess.ts` | — | "View only: your role can open this plan but not change it." / "View only: your role cannot create a plan." / "Your role cannot delete a plan." | — | M | Same | Same | Build |
| PA6 | `PlanningFilters.tsx:46-72` | — | Badge: "Read-only" / "Editing Plan #{n}" / "Editing" / "New plan" | — | M | Under the title | Toolbar | Build |
| PA7 | `planningColumns.tsx:299-301` | — | Read-only: SORT, REMARKS, TRUCK and DRIVER become text; the tick, remove and drag columns are hidden | V | M | Cards with no edit controls | Board cells locked | Build |

## 2. Planning: search fields (`P/components/PlanningFilters.tsx`)

| # | React (file:line) | API + payload | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| PS1 | PLAN NO `:381-410`; `utils/planningNumber.ts:9-15` | GET `/api/planing/edit?companyId&planningNo` | Strips non-digits, range 1..2147483647, empty does nothing; "Planning data not found"; the URL becomes `/planning/edit/{id}`; busy spinner (`aria-busy`) | V | P | Numeric keypad, Go key, "Open" | Same, in the side panel | Build |
| PS2 | PLAN DATE * `:415-431` | → save `saleDate` | Required. Search: "Please select a Planning Date" (`helpers.ts:138-145`). Default today | W | E | Date field, required mark | Same | Build |
| PS3 | FROM / TO `:434-460` | `fromdate` / `todate` (yyyy-MM-dd) | Default today; independent of each other | V | E | Date fields + Today / Tomorrow / This week chips | Same | Build |
| PS4 | PORT + Add `:462-487`; `usePlanningListPage.ts:415-422` | ports `usePorts(companyId)` | Not saved. Add: `searchText.trim() ? searchText + ',' + port : port` | V | P | Picker + "Add to search" | Same | Build |
| PS5 | EMPLOYEE `:489-504`; `helpers.ts:214-223` | `GET /api/employees/company/{id}/all?type=ALL` | `Number(employee) \|\| 0` | V | E | Searchable picker | Same | Build |
| PS6 | SEARCH `:506-519` | `search` (trimmed) | Placeholder "Job numbers, comma separated..."; debounced 300 ms. Java filters it on port codes (Q-SEARCH) | V | E | Field; each comma value becomes a chip | Same | Build |
| PS7 | REMARKS `:521-533` | → save `remarks` | Debounced 300 ms; read-only when locked; placeholder "Enter notes and remarks..." | W | E | Plan header | Panel | Build |
| PS8 | `helpers.ts:264-271` | — | "Please enter at least one search criteria" (search text, employee, from or to) | — | M | Inline error | Same | Build |
| PS9 | `usePlanningListPage.ts:572-586`; `hooks/usePlanningSearch.ts:7-26` | POST `/api/planing/search` `{comid, search, employeeid, fromdate, todate}` | "Planning data loaded successfully"; error `response.data.message \|\| error.message \|\| 'Search failed'`, and the grid is cleared | V | E | Search button; result count | Same | Build |
| PS10 | `planningSearch.ts:34-51` | — | Unwraps: array, `data1`, `data`, `data.items`, `list`, `rows` | — | P | model `PlanLine.fromJava` | Same | Build |
| PS11 | `usePlanningListPage.ts:189-231` | — | New plan: replace the rows. Saved plan: merge (K2) | W | M | Snackbar "n added · n refreshed" (display only) | Same | Build |
| PS12 | Collapse `PlanningFilters.tsx:361-370` | — | Hides the form; the button reads "Filters" | — | — | The sheet closes | The panel folds to icons | Build |
| PS13 | *Mobile extra* | — | Removable chips, Clear all, result count, remembered filters | — | M | Under the search bar | Top of the board | Build |
| PS14 | *Mobile extra* | — | Find in results: truck, driver, customer, vessel, job no., status. **Filters the loaded rows only** | — | M | Search bar | Find box | Build |

## 3. Planning: header buttons (`PlanningFilters.tsx:196-370`)

| # | Button (file:line) | API | Rule / confirm / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| PB1 | Excel `:196-203`; `usePlanningListPage.ts:935-989` | — | CSV `Planning_Export_{yyyy-mm-dd}.csv`, 18 columns; "No data to export"; "Excel downloaded successfully" | — | M | ⋮ → Export CSV (share sheet) | Toolbar | Build |
| PB2 | View `:205-212` | → PlanningView | — | V | E | ← Plans | Plans tab | Build |
| PB3 | Truck Location `:214-222` | web page `/truck-location-board` | Opens in a new tab | — | M | ⋮ → opens in the browser | Same | ⛔ Q-TRUCKLOC |
| PB4 | Refresh `:224-230` | — | `window.location.reload()` | — | M | Pull to refresh | Refresh icon | Build |
| PB5 | Suggest `:235-249` | AI | — | — | — | — | — | Out of scope |
| PB6 | Save `:250-261` | §5 | "Saving..." | W | E | Sticky "N changes · Save" | Sticky bar | Build |
| PB7 | Delete `:262-270` | §5 | — | D | E | ⋮ → Delete plan (red) | ⋮ | Build |
| PB8 | Sort `:271-278`; `usePlanningOperations.ts:37-57` | — | Drops the last row if its job no. is empty (and there is more than one row); sorts by SORT ascending, 0 or empty last | W | E | ⋮ → Sort | Toolbar | Build |
| PB9 | Clone `:279-286, 539-548`; `usePlanningOperations.ts:251-285` | — | Confirm "Duplicate Planning Row?" / "This row will be duplicated and added to the planning list. The truck assignment will be cleared." / "Duplicate"; "Please select a row to duplicate"; "Cannot duplicate: Row does not have a valid sale order"; "Row duplicated successfully" | W | M | Selection bar / detail ⋮ | Row ⋮ | Build |
| PB10 | Update `:287-294`; `usePlanningListPage.ts:910-933` | §6 | "Please select a row first"; "Selected row does not have a sale order to update" | W | E | Detail → Update sale order | Side sheet | Build |
| PB11 | Push RTI `:297-304` | §7 | "Please select orders to push to RTI" | W | P | Selection bar | Toolbar | Build |
| PB12 | Create RTI `:305-319` | §7 | "Creating..." | W | M | Selection bar | Toolbar | Build |
| PB13 | Create All RTI `:320-334` | §7 | "Working..." | W | M | Plan ⋮ / button | Toolbar | Build |
| PB14 | Clear `:339-345`; `usePlanningListPage.ts:653-665` | POST `/api/planing/max-planning-no/{companyId}` | Resets; "Form cleared"; on an edit page → /planning | — | E | ⋮ → New plan (asks first if there are unsaved changes) | Same | Build |
| PB15 | Search `:347-359` | PS9 | Disabled while searching | V | E | Sheet button | Panel | Build |
| PB16 | Counters `PlanningList.tsx:269-274` | — | "{n} Orders", "{k} Selected" (counts `row.selected`; Q-COUNT) | — | M | Summary tiles | Toolbar | Build |
| PB17 | Pin modes `PlanningList.tsx:277-317` | — | Auto / Unpinned / Pinned columns | — | — | — | Frozen-columns toggle | Build (TL) |

## 4. Planning: grid columns (`planningColumns.tsx:36-301`) and row behaviour

**Where each field goes.** Phone order follows the brief's sections 1–6. TL is the board.

| # | Column (file:line) | Read from (`planningSearch.ts:53-136`) | Edit | Phone card | Phone detail | TP detail | TL board | Plan |
|---|---|---|---|---|---|---|---|---|
| PC1 | ✓ `:40-50` | `print` | W | Long-press / checkbox | — | Checkbox | Frozen checkbox | Build |
| PC2 | S.NO + drag `:54-81` | index | W (drag) | — | Notes · move up/down | Drag | Frozen + drag | Build |
| PC3 | SORT `:52-64` | '' (`originalSortByD` kept) | W | — | Notes | ✔ | Cell | Build |
| PC4 | REMARKS `:67-79` | `Remarks` | W | — | Notes | ✔ | Cell | Build |
| PC5 | TRUCK `:275-362` | `TruckName` ('' when the id is 0) | W | ✔ (amber "Assign") | Assignment | ✔ | Frozen, picker | Build |
| PC6 | DRIVER `:126-272` | `DriverName` | W | ✔ | Assignment | ✔ | Frozen, picker | Build |
| PC7 | ORIGIN `:435-511` | `Origin`; hover shows `PickupAddress` split on `{@}`; "No address on this job" | — | ✔ | Route (stops expand) | ✔ | Cell + popover | Build |
| PC8 | DEST | `Destination`, `DeliveryAddress` | — | ✔ | Route | ✔ | Cell + popover | Build |
| PC9 | PKG / WT | `pkg` | — | — | Cargo | ✔ | Cell | Build |
| PC10 | CUSTOMER | `CustomerName` | — | ✔ | Header | ✔ | Cell | Build |
| PC11 | P.DATE | `SPickupDate \| PickupDate` → `dd/MM/yyyy HH:mm` | — | ✔ | Timing | ✔ | Cell | Build |
| PC12 | D.DATE | `SDeliveryDate \| DeliveryDate` | — | — | Timing | ✔ | Cell | Build |
| PC13 | VESSEL | `VesselName` | — | ✔ (with customer) | Cargo | ✔ | Cell | Build |
| PC14 | JOB NO | `JobNo` | — | ✔ | Header | ✔ | Frozen | Build |
| PC15 | PIC | `EmployeeName` | — | — | Notes | ✔ | Cell | Build |
| PC16 | L ETA / O ETA | `LETA` / `OETA` | — | — | Timing | ✔ | Cells | Build |
| PC17 | STATUS `:238-256` | `JobStatus \|\| 'Pending'` | — | Pill | Header | ✔ | Pill | Build |
| PC18 | RTI `:257-277` | `RTINo`, then `rti-status` | — | Badge | Header → RTI | ✔ | Badge; title "RTI created: {no}" | Build |
| PC19 | remove `:278-296` | — | W | Swipe left / ⋮ | ⋮ | ⋮ | Row ⋮ | Build |
| PC20 | Hidden fields | `JobName`, `JobDate`, `AWBNo`, `BLCopy`, `truckSize`, `SPort`, `OPort`, `OriginD`, `DestinationD`, `TruckNameD`, `DriverNameD`, `PickupDateD`, `DeliveryDateD`, warehouse fields, lists | — | size next to the truck | All shown in their sections | ✔ | Column presets | Build |

| # | Row behaviour (file:line) | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|
| PR1 | Status colours `planningStatusUtils.ts:9-73` | Regex order: danger, success, warning, info, primary, accent; otherwise hash into 7 tones | — | M | Pill | Pill | Build |
| PR2 | Selected and same-truck highlight `PlanningList.tsx:132-151` | Selected row is strong blue; other rows with the same truck (not "ASSIGN") are soft blue | — | M | The detail lists "Other jobs on this truck" | Board row tint + By truck view | Build |
| PR3 | Copy cell (K4) | `Copied: {value}` | — | M | Long-press a value → Copy | Cell menu → Copy | Build |
| PR4 | Truck expiry `FE/utils/truckExpiryWarnings.ts` | Red when critical | — | M | Red text + note in the picker | Same | Build |
| PR5 | Driver expiry and leave `FE/utils/driverExpiryWarnings.ts:52-110` | Red critical, purple-700 approved leave, indigo-700 pending leave | — | M | Same | Same | Build |
| PR6 | Remove `usePlanningOperations.ts:288-298` | Confirm "Delete Record" / "This action cannot be undone. Continue?" / "Delete"; "Row removed" | W | E | Swipe or ⋮ | ⋮ | Build |
| PR7 | Reorder `utils/planningRowOrder.ts:8-28` | Save keeps the grid order | W | M | Drag handle | Drag | Build |
| PR8 | Delete key `usePlanningListPage.ts:389-402` | Delete (Alt+Delete in an input) removes the selected row | W | — | — (swipe) | Hardware key | Build |
| PR9 | F5 `:383-386` | Goes to View | — | — | — | Hardware key | Build |

## 5. Planning: assign, save, load, delete

| # | React (file:line) | API + payload | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| PV1 | Truck pick `usePlanningListPage.ts:424-468`; `FE/components/modals/TruckSelectModal.tsx` | trucks (K14) | Search; "Current" mark; Enter or arrows (desktop). **Sets only `truckName` and `truckRefid`** | W | P | Bottom sheet: search, recent first, severity, "Current" | TP inline / TL popover; arrows and Enter | Build |
| PV2 | Driver pick `:470-488` | drivers (K14) | Sets `driverName` and `driverRefid`; a typed name is allowed | W | P | Bottom sheet | Popover | Build |
| PV3 | Outside driver (K3) | — | Truck id 22 or `OUTSIDE DRIVER` → typed name, `driverRefid` 0 | W | M | Text field in the sheet | Same | Build |
| PV4 | Clear X `planningCellRenderers.tsx:275-362` | — | Truck: id 0, name ''. Driver: all name fields '' | W | M | "Clear" | Clear icon | Build |
| PV5 | *Mobile extra:* assign several jobs at once | — | PV1/PV2 for each selected row; nothing else changes | W | E | Multi-select → Assign | Select rows → Assign | Build |
| PV6 | Save `utils/planningSavePayload.ts:110-263`; `usePlanningOperations.ts:97-178` | POST `/api/planing/save`, header `Comid`, `[{id, companyRefId, userRefId, employeeRefId, fDate, tDate, saleDate (yyyy/MM/dd), cNumberDisplay, cNumber, remarks, search, saleDetails[...]}]` | Rows without a sale order are dropped; fDate/tDate fall back to the plan date. Messages: "Company ID is required", "Planning date is required", "From date is required", "To date is required", "Please add at least one valid row in the table before saving"; fallback "Invalid planning payload"; `!ok` → `message \|\| 'Error saving planning'` | W, server | E | Same checks; busy; double tap ignored | Same | Build |
| PV7 | After save `usePlanningListPage.ts:598-627` | — | "Planning saved successfully" / "Planning updated successfully"; a new plan opens `/planning/edit/{id}`; the page reloads; the toast is shown again from sessionStorage (twice, Q-TOAST) | — | P | Reload the plan in place; one snackbar | Same | Build |
| PV8 | Unsaved changes `dirtyRowIds` `:260-329` | — | Reloading the same plan keeps the edited rows; only the latest load applies | — | M | "N changes" bar + warning before leaving | Same | Build |
| PV9 | Load `:260-329`; `planningEditMapper.ts:37-178` | GET `/api/planing/edit?id&companyId&planningNo` | "Planning data not found"; error `message \|\| 'Failed to load planning'` | V | E | — | — | Build |
| PV10 | Next no. `usePlanningOperations.ts:74-94` | POST `/api/planing/max-planning-no/{companyId}` → `sequenceNumber` | Preview only | — | E | Title | Title | Keep |
| PV11 | Delete `usePlanningOperations.ts:181-212`; `PlanningList.tsx:411-420` | DELETE `/api/planing/{id}?companyId` | "No planning selected to delete"; confirm "Delete Planning" / "Are you sure you want to delete this planning? This action cannot be undone." / "Delete"; `!ok` → `message \|\| 'Error deleting planning'`; "Planning deleted successfully" → new plan | D | E | Red, confirm | Same | Build |
| PV12 | Loading and errors `PlanningList.tsx:153-185` | — | "Loading planning data..."; "Error loading employees" + Retry; toast "Failed to load employees. Please refresh." | — | P | Skeleton / error + Retry | Same | Build |

## 6. Planning: update sale order (`FE/components/modals/UpdateSaleOrderModal.tsx`; `utils/planningSaleOrderUpdate.ts`)

| # | React (file:line) | API | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| PU1 | Load `planningSaleOrderUpdate.ts:98-146` | GET sale-order edit | "Unable to prepare the sale order update form.", "Failed to load sale order details.", "Unable to load the selected sale order." + Retry | W | E | Full-screen form | Side sheet | Build |
| PU2 | Sections | — | Job & Schedule (job, customer, pickup, delivery, origin, destination); Cargo (PKG, weight KG); Warehouse (address, enter, exit); pickup and delivery stops. With one stop, its date follows the job date | W | E | Section cards | Two columns | Build |
| PU3 | Save `:215-244` | POST `/api/planing/update-dates` (18 keys) | "Sale order details are missing."; "This job did not finish loading. Close and reopen it before saving."; confirm "Sale Order Update" / "Do you Want to Update the Details?" / Yes / No; `message \|\| 'Sale order updated successfully'`; `'Update Failed'` | W, server `canEdit` | E | Sticky Save | Same | Build |
| PU4 | After `:251-276` | — | Every row with that sale order is updated; no reload | — | P | Same | Same | Build |

## 7. Planning → RTI

| # | React (file:line) | API | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| PT1 | RTI badges `usePlanningListPage.ts:758-807` | POST `/api/rti-details/rti-status` body `[ids]` → `[{saleOrderMasterRefId, rtiMasterRefId, rtiNo}]` | Refreshed when the job set changes; failures are silent | — | M | Badge | Badge | Build |
| PT2 | Push RTI `usePlanningOperations.ts:223-248`; `R/services/planningTransferService.ts:151-444` | none | "Please select orders to push to RTI"; "Unable to prepare the selected orders for RTI"; the RTI form takes the first item's truck and driver; outside → `outsideDriver`/`outsideTruck`; one job row each; K6 toast; the user saves | W | P | Review sheet → RTI form | Same | Build |
| PT3 | Create RTI (K7) | POST `/api/rti-masters` | Messages in order (K7 plus the service's): sale order missing, different trucks, different drivers, outside name, no driver, truck not in master, no truck; then RTI validation. Fallback ids 22 and 43 (Q-IDS); RTI date today; "RTI {no} created with {n} job(s)"; the rows are stamped; `'Failed to create RTI'` | W | M | Review sheet → confirm → progress → result | Dialog | Build |
| PT4 | Create All: open `hooks/useCreateAllRti.ts:72-111` | GET `/api/planing/{id}/rti-batch/preview?companyId[&jobIds][&includeExisting=true]` | "Save the plan first, then create its RTI."; "Company is required."; load error `Message \|\| 'Could not read the plan.'`; opens with includeExisting=true; ticks are ignored | W | M | Full-screen sheet | Dialog | Build |
| PT5 | Create All: groups `CreateAllRtiModal.tsx`; `utils/planningRtiBatch.ts:34-67` | — | Ticked at the start only with a driver; ready = truck > 0, driver > 0, jobs > 0; driver source "From the plan" / "Suggested" / "Outside driver" / "Pick a driver"; trip label tooltip; "was on {no} · {date}" | — | M | Group cards | Same | Build |
| PT6 | Create All: skip switch | — | "Skip jobs that already have an RTI" re-runs the preview; "{n} job(s) left out because they already have one." / "{n} job(s) were on an earlier RTI — a new one is created, the old one stays." | — | M | Switch | Same | Build |
| PT7 | Create All: skipped panel | — | "{n} job(s) will not get a new RTI"; labels "Already has an RTI", "No truck assigned", "No job reference", "On the plan twice", "Truck not ticked", "Not created" | — | M | Collapsible | Same | Build |
| PT8 | Create All: footer and create `useCreateAllRti.ts:122-157` | POST `/api/planing/{id}/rti-batch` `{companyRefId, employeeRefId, groups[{groupKey, truckRefId, driverRefId, outsideDriver, outsideTruck, saleOrderMasterRefIds}], allowDuplicates}` | "{trucks} RTI · {jobs} job(s)"; "{n} truck(s) still need a driver"; "Tick at least one truck to create."; "{k} RTI created for {n} job(s)" / "No new RTI was created — every job already had one." / "Nothing was created."; info "{n} job(s) already had an RTI and were left alone."; error `Message \|\| 'Could not create the RTI for this plan.'`; ticks cleared; rows stamped | W | M | Sticky footer → progress → result per job | Same | Build |
| PT9 | Planning row "RTI Revise" / "Open RTI" `usePlanningListPage.ts:813-868` | §10 | The handlers exist; **no UI calls them** (`planningColumns.tsx:37`) | W | M | ⛔ Q-REV-ROW | ⛔ | ⛔ |

## 8. Planning View (`P/PlanningView.tsx`)

| # | React (file:line) | API | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| PW1 | Filters `:54-67, 289-342` | POST `/api/planing/select-planning` `{comid, fromdate, todate, search, employeeid}` | From = yesterday, To = today; Plan number; Employee; "Login Employee" disables Employee and sends the user's own id | V | E | Search bar (plan no.) + sheet | Side panel | Build |
| PW2 | Checks `:94-116` | — | "Company is not available yet"; "From date cannot be greater than to date"; "Failed to load planning list" | — | P | Inline | Same | Build |
| PW3 | Plan-number search (server `PlanningMasterService.java:820-824`) | — | Exact `CNumberDisplay`; ignores the dates | — | E | Same | Same | Keep |
| PW4 | Columns `:131-224` | — | ID · Planning No (opens the plan) · Planning Date ("02 Mar 2026") · Employee · "{n} orders" · Remarks · Report · Edit; "Rows: n", "Total Logs: n" | V | P | Plan cards | Table + preview pane | Build |
| PW5 | Report `P/api/planningReportApi.ts:19-36` | GET `/api/planning/reports/{id}/pdf-ticket?companyId&reportDate` | "Report Date" input; "Planning details are missing for the Planning report."; "Could not open the Planning report" | V | P | Report-date chip + PDF on the card | Same | Build |
| PW6 | Open `:127-129, 208-223` | — | Double-click, number or Edit → `/planning/edit/{id}` | V | P | Tap | Tap | Build |

## 9. RTI entry (`R/pages/RTIPage.tsx`)

| # | React (file:line) | API + payload | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| RE1 | Title (K8) | — | "Edit Mode" / "New RTI" badge | emp | P | App bar | Header | Build |
| RE2 | View [F5] `RTIPageHeader.tsx:90-132` | → RTI list | — | emp | P | ← | F5 + button | Build |
| RE3 | Clear [F10] `RTIPage.tsx:70-78` | sequence-masters | Edit → /rti; new → clear + next number | emp | E | ⋮ → New RTI | F10 + button | Build |
| RE4 | Delete `useRTIOperations.ts:162-272` | DELETE `/api/rti-masters/{id}` (204) | "No RTI selected for delete."; confirm "Delete RTI" / "Do you want to permanently delete this RTI? This action cannot be undone." / "Yes, Delete" / "Cancel"; "RTI deleted successfully" → clear; "Failed to delete RTI." | emp (edit) | E | ⋮ → Delete (red) | ⋮ | Build |
| RE5 | Revise | §10 | — | emp (edit) | P | ⋮ → Revise | Toolbar | ⛔ Q-REV |
| RE6 | Levi Entry | §11 | — | emp (edit) | M | ⋮ → Levi | Side sheet | Build |
| RE7 | Save [F1] `useRTIOperations.ts:96-160, 238-251` | §RE20 | "Company is missing. Please refresh and try again."; "Employee login is required before saving RTI."; double save blocked | emp | E | Step 5 Save | F1 + button | Build |
| RE8 | RTI No `rtiApi.ts:148-203` | GET `/api/sequence-masters/company/{id}` (`rtimaster` + 1), fallback max from `/active` | Read-only `RTI%09d`; the server assigns the real number | — | E | Header | Header | Keep |
| RE9 | RTI Date `RTIFormFields.tsx:349-354` | `saleDate` `yyyy-MM-ddT00:00:00` | Today; "Please select RTI Date" | — | E | Step 1 | Header form | Keep |
| RE10 | Driver `:355-396` | K14 | Expiry colours + toast on pick; "Please select Driver Name" | — | E | Step 1 picker | Picker | Build |
| RE11 | Outside Driver / Outside Truck `:397-402, 461-466` | `outsideDriver` / `outsideTruck` | Placeholders "Enter outside driver name" / "Enter outside truck plate" | — | M | Step 1 | Header form | Build |
| RE12 | Vehicle `:403-460` | K14; licence `GET /api/truck-masters/{id}` | "Urgent" / "Due soon" badges; new RTI only: "{names} - License expired / Going to be expired !!"; "Please select Vehicle Number" | — | P | Step 1 + warning banner | Same | Build |
| RE13 | Enter / Exit `:467-478` | `eLink` / `exLink` | '' / 1ST LINK / 2ND LINK | — | E | Segmented | Same | Keep |
| RE14 | Toggles `:482-496` | `punctuality`, `documentSub`, `pckHandling` 1/0 | — | — | E | Step 2 switches | Charges panel | Keep |
| RE15 | Charges `:500-569`; `calculationService.ts:13-59` | `sleeping`/`sleepingAmount` 50; `exitYN` 0/1/2 + `exitAmount` 0/80/50; `emptyDeliveryYN` + amount; `pickup`/`pickupCount`/`pickupAmount` 30×; `addDrop`/`dropCount`/`dropAmount` 30×; `manpw` 0/1/2 → 0/50/100 | Total = Σ salary + allowances, rounded to 2 places; the count box shows only when YES; NO clears the count | — | E (`RtiEntryApi.amounts`) | Step 2 segmented + live RM | Charges panel, live | Keep + tests |
| RE16 | Destination / Seal By / Break Seal By / Remarks / Comments `:573-606` | same names | Destination overwrites each route activity's `fullRoute` (`useRTIState.ts:77-84`) | — | E | Step 1/5 | Header form | Build (fullRoute) |
| RE17 | Charges summary `:170-192, 610-662` | — | Each allowance and the total | — | P | Step 5 + sticky total | Right panel | Build |
| RE18 | Validation `rti.validation.ts:46-81` | — | "Please select Driver Name", "Please select Vehicle Number", "Please select RTI Date", "Please add at least one job", "Row {n}: Job No is required", "Row {n}: job {JobNo} was not found. Press Enter in Job No to look it up, or remove the row."; all shown together | — | P | Under each field + a list on Review | Same | Build |
| RE19 | Load `rtiService.ts:365-484` | GET `/api/rti-masters/{id}[?companyId]`, GET `/api/rti-details/rti-master/{id}`, GET `/api/sale-orders/{id}` per job | — | emp | E | — | — | Keep |
| RE20 | Save `rtiApi.ts:310-378`; `rtiService.ts:565-704` | POST `/api/rti-masters` (201) / PUT `/api/rti-masters/{id}`, master + `rtiDetails` (sent only when the sale order > 0) + `routeActivities` | "Company is required before saving RTI."; "RTI save did not return a valid master id."; "Failed to save RTI."; create → "RTI saved successfully" → edit page; edit → reload → "RTI updated successfully"; edit retried up to 2 times | emp | E (route activities left out) | Snackbar | Same | Build (+ route activities) |
| RE21 | Truck vs driver toasts `RTIFormFields.tsx:146-168` | — | Expiry toast on each pick | — | M | Snackbar | Same | Build |
| RE22 | Agent company / agent (K19) | — | Not shown, not saved | — | — | — | — | Not built (same as React) |

### RTI job grid (`R/components/RTIGrid.tsx`, `RTIGridCell.tsx`)

| # | React (file:line) | API | Rule / message | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|
| RG1 | Columns `:25-90` | — | S/N · JOB NO✎ · Customer · Job Date · Salary✎ · PPIC✎ · DPIC✎ · PWD✎ · Origin · Destination · Pickup Date · Delivery Date · delete | E | One card per job | Full-width grid | Build |
| RG2 | Job No lookup `useRTIOperations.ts:295-339`; `rtiApi.ts:452-531` | POST `/api/sale-orders/search` (K18), exact match on `BillNoDisplay \| CNumberDisplay \| JobNo`, then GET `/api/sale-orders/{id}` each | "Job not found."; an already-loaded row is skipped; blank rows and older rows of that job are replaced; extra matches go below; repeats allowed | E (app uses `/job-search`) | Job No field + "Look up" | Enter in the cell | ⛔ Q-JOBLOOKUP |
| RG3 | Badges `:208-210` | — | Rows · Jobs · Salary total | M | Step 3 header | Grid header | Build |
| RG4 | Add Row `:214-222` | — | — | E | "Add job" | Insert / button | Build |
| RG5 | Delete row `:305-321`; `useRTIState.ts:133-140` | — | Confirm "Delete RTI row?" / "This line item will be removed from the RTI grid."; the last row leaves one blank row | E | Card ⋮ | Row button / Ctrl+Delete | Build |
| RG6 | Keys `RTIGridCell.tsx:98-182` | — | Insert add; Ctrl/Cmd+Delete delete; Esc undo cell; Enter next; Shift+Enter previous; Enter on the last cell adds a row; Ctrl+Home/End; arrows | — | — (buttons) | Hardware keys | Build (TL/TP) |
| RG7 | Paste `useRTIState.ts:194-245`; `rtiGridClipboard.ts` | — | A multi-cell paste fills the editable columns and adds rows; Salary/PWD as numbers | M | ⏳ (no multi-cell paste on phone) | Paste into the grid | Build (tablet) |
| RG8 | Placeholder `:227-232` | — | "Enter a Job No and press Enter to pull the matching sale-order lines." | M | "Type a Job No and tap Look up." | React text | Build |

### Route activities (`R/components/RTIRouteActivitiesGrid.tsx`)

| # | React (file:line) | Rule / message | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|
| RA1 | Columns `:24-44` | Seq No · Destination (16 `ROUTE_LOCATIONS` or custom) · Agent Name (employee or custom) · Agent Mobile · Driver Number · Job Type (SEAL, BREAK SEAL, SEAL AND BREAK, K1/K2/K3/K8 Clearance) · Full Destination · Marqis Clearance · Remarks · ETA (date + "HH:mm") · Created Date (read-only) · delete | M | Step 4: one card per stop | Full-width grid | Build |
| RA2 | Agent `:93-116`; `useRTIEmployees.ts:11-23` (`GET /api/employees/company/{id}/all?type=ALL`) | Picking an employee sets `employeeRefId`, clears `agentName` and copies the mobile number; custom text sets `agentName` | M | Picker with "use typed name" | Same | Build |
| RA3 | Defaults `useRTIState.ts:148-188`; `rti.initialState.ts:81` | New row: seq = last + 1 (the first is 10); `fullRoute` = destination; the driver number comes from row 0; editing row 0's driver number copies it to every row | M | Same | Same | Build |
| RA4 | Delete | "Delete Activity?" / "This route activity will be removed." | M | Same | Same | Build |
| RA5 | Empty | 'No route activities defined. Click "Add Activity" to create milestones.' | M | Same text, saying "Tap" | React text | Build |
| RA6 | Save mapping `rtiService.ts:663-697` | SEAL_AND_BREAK ↔ "SEAL,BREAK_SEAL"; status defaults to 0; planned time and ETA default to the RTI date; `:00` added to 16-character ETAs; `active: true` | M | — | — | Build |

## 10. RTI revise

| # | React (file:line) | API | Rule / message | Today | Plan |
|---|---|---|---|---|---|
| RV1 | Revise button `useRTIOperations.ts:274-293` | GET `/api/rti-masters/{id}/revise?companyRefId` → `Data1` master + `rtiDetails` + `routeActivities` | "No RTI selected to revise."; confirm "Revise RTI" / "Do you want to revise data from the Sales Order? This will overwrite the current RTI information." / "Yes, Revise" / "Cancel"; success **modal** "RTI revised successfully"; **the result is not loaded and not saved** (`:191-194`); "Failed to load revise data." | P (app loads the result into the form) | ⛔ Q-REV |
| RV2 | `?revise=1` `RTIPage.tsx:129-150` | same | Runs once after the RTI loads; the confirm still shows | M | ⛔ Q-REV |
| RV3 | `reviseRTIInPlace` `planningDirectCreateService.ts:265-297` | revise → validate → PUT | Same id and number; route activities kept; "No RTI to revise."; Planning messages (PT9). **No UI reaches it** | M | ⛔ Q-REV / Q-REV-ROW |
| RV4 | Server `RTIMasterServiceImpl.java:551-581` | — | A GET that also re-copies RTIPickup/RTIDelivery and the warehouse fields. With no lines it returns `routeActivities: null` | — | Guard: keep the loaded stops when null |

## 11. Levi entry (`R/components/RTILeviEntryModal.tsx`; `FE/features/pass-entry/api/passEntryApi.ts:88-122`)

| # | React (file:line) | API | Rule / message | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|
| RL1 | Load `:298-317, 495-533` | GET `/api/levi-entries/by-rti/{rtiId}?companyRefId` → `{items, entriesTotal}`; GET `/api/levi-entries/next-no?companyRefId` | IN and OUT slots: "Loading…", "Not filed" or the number; opens on IN if filed, else OUT, else a new IN | M | Bottom sheet | Side sheet | Build |
| RL2 | Fields `:537-662` | — | Levi no (read-only) · Date (today) · Entry IN/OUT · Link (from the RTI's Enter for IN, Exit for OUT) · RTI no · Truck · Driver · Amount · Remarks (2000) · Attachments (folder `LeviEntry`, `/api/attachments`) | M | Form | Form | Build |
| RL3 | Checks `:365-392` | — | "Company not found", "Save the RTI first", "Choose IN or OUT", "Select a truck", "Select a driver", "Enter an amount", "Amount must not be negative" | M | Under the field | Same | Build |
| RL4 | Duplicate leg `:410-424` | — | "This RTI already has an {type} levi ({no}). Press Save again to update it." The form takes over that entry and keeps what was typed | M | Same | Same | Build |
| RL5 | Save `:426-439` | POST `/api/levi-entries` `{id?, companyRefId, truckRefId, driverRefId, rtiRefId, employeeRefId?, saleDate, amount, remarks?, enterLink, exitLink}`, then attachments | "Levi entries {no} saved"; "Could not save the levi entry"; button "Save IN" / "Update OUT" / "Saving…" | M | Same | Same | Build |
| RL6 | Delete `:357-362` | DELETE `/api/levi-entries/{id}?companyRefId` | **No confirm** (K16); "levi entry deleted"; "Could not delete the levi entry" | M | ⛔ Q-LEVIDEL | ⛔ | ⛔ |

## 12. Share and report

| # | React (file:line) | API | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| RS1 | WhatsApp `R/components/RtiShareWhatsAppButton.tsx`; `api/rtiShareApi.ts:37-40` | POST `/api/rti-masters/{id}/share-whatsapp` `{companyId}` → `Data1 {sent, rtiNo, truck, group, messages, detail, documentSkipped}` | Confirm "Send {rtiNo} to the truck's WhatsApp group?"; "{rtiNo} sent to the group of {truck \| 'the truck'}"; `documentSkipped` (10 s); `detail \|\| 'The message was not sent'`; `message \|\| 'Could not share this RTI'` | emp | M | ⋮ / card action | Toolbar / row | Build |
| RS2 | Report `R/api/rtiReportApi.ts:20-29` | GET `/api/rti-masters/{id}/report-ticket?companyId` → `Data1.Url` | "RTI details are missing for the RTI report."; "Could not open the RTI report" | emp, **drv** | E | App bar / card | Same | Keep |

## 13. RTI list (`R/pages/RTIViewPage.tsx`)

| # | React (file:line) | API | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| RLs1 | Filters `:55-160, 409-486` | React `/active` (K12); app `/with-jobs` | From/To today; Driver ("All Drivers"); Truck ("All Trucks"); RTI No ("Search RTI...", Enter, exact match, ignores the dates); "My RTIs" (off at first, on after Clear, K13); View; Clear | emp | P | Search bar (numeric, Go) + sheet + chips | Side panel | ⛔ Q-RTI-LIST |
| RLs2 | Not Salary Entered `:174-183, 409-417` | — | Client-side `amount === 0` | — | M | Chip | Same | Build |
| RLs3 | Columns `:275-372` | — | # · RTI No · Date (en-GB) · Driver · Truck · Amount `RM x.xx` · Remarks · Report · Share · Edit | — | E | Card + Report / Share / Edit | Table | Build |
| RLs4 | Stats `:506-516` | — | Records · Total Amount; "Showing N records" | — | M | Stats strip | Same | Build |
| RLs5 | Preview `:749-848` | full RTI load | Driver, Vehicle, Date, Amount, Destination, Remarks, up to 10 jobs `JobNo · CustomerName`, Edit, Close | — | P | Bottom sheet | Preview pane | Build |
| RLs6 | Double-click → edit `:642` | — | — | — | — | Edit button | Double-tap | Build |
| RLs7 | States `:76, 204, 537-568` | — | "Loading RTI records"; after 30 s "Still loading records" + Retry; "Unable to load records" + Retry; "No RTI records found" / "Try adjusting your date range, changing filters, or uncheck "My RTIs Only" to see all records." | — | P | Skeleton / timeout / error / empty | Same | Build |
| RLs8 | New RTI `:418-424, 589-595` | — | — | emp | E | FAB | Toolbar | Keep |

## 14. Employee assignments (`R/pages/EmployeeAssignmentsPage.tsx`; `api/employeeAssignmentsApi.ts:38-49`)

| # | React (file:line) | API | Rule / message | Role | Today | Phone | Tablet | Plan |
|---|---|---|---|---|---|---|---|---|
| EA1 | Filters `:44-98` | POST `/api/rti/employee-assignments` `{fromDate, toDate, companyId, employeeId}` (range at most 90 days on the server) | From/To today (required: "Please select both From and To dates"); Employee ("All Employees"); "My Job Only" (K17); loads only on Search / Refresh; Clear does not search; `Message \|\| 'Failed to fetch employee assignments'` | emp | M | Search bar + sheet | Side panel | Build |
| EA2 | Columns `:300-430` | — | RTI / SO (RTI no + report, SO no, customer) · Route & Dates · Cargo (vessel, commodity, qty, truck size) · Counts · Assignment · Vehicle · Status ("Active", hard-coded) · Remarks ("No remarks provided.") | — | M | Cards | Table | Build |
| EA3 | Report | report-ticket | "RTI Number is missing"; "Failed to open RTI report" | — | M | Card | Row | Build |
| EA4 | Export `:122-124` | — | **The button has no handler in React** | — | — | — | — | Not built (React gap) |

## 15. Shared and layout

| # | Item | Phone | Tablet | Plan |
|---|---|---|---|---|
| L1 | One `ResponsiveLayout`: under 600 / 600–900 / over 900 dp; split view and multi-window use the window's width; state lives in the blocs so it survives rotation | ✔ | ✔ | Build |
| L2 | Theme: Material 3 light and dark from the tokens; one brand colour; seven status tones (PR1) | ✔ | ✔ | Build (Q-DARK from `planning-rti-parity`) |
| L3 | Shared widgets: app bar, job card, status pill, RTI badge, filter sheet/panel, chips, picker with severity, detail section, editable grid cell, sticky action bar, confirm dialog, skeleton, empty, error + Retry, snackbar | ✔ | ✔ | Build |
| L4 | Folders: `features/planning`, `features/rti`, `features/rti_assignments`, each with `data/`, `bloc/`, `models/`, `view/phone/`, `view/tablet/`, `widgets/`; files about 400 lines at most | — | — | Build |

---

## API gaps

There are none that block the work. Every React call has a Java endpoint (backend audit: 33 calls).

- **G1:** POST `/api/planing/sort`, `/api/planing/push-rti`, `/api/planing/list` and `PLANNING.UPDATE` have no Java endpoint, and React never calls them.
- **G2:** The `/with-jobs` RTI list has no vessel, destination or status. React's `/active` list has none of these either.
- **G3:** The trucks and drivers lists (K14), the RTI CRUD, Levi, WhatsApp, Planning and Employee Assignments all **refuse driver tokens**. These screens are for office staff. Drivers keep the RTI list (`/with-jobs`), the PDF, and the job status they already have.

## React gaps (kept as they are)

- The Planning row's RTI Revise / Open RTI handlers are never shown (`planningColumns.tsx:37`).
- RTIPage Revise throws its result away (`useRTIOperations.ts:191-194`).
- These components are never rendered: PlanningHeader, PlanningActions, PlanningActionButtons, PlanningFormFields.
- These endpoints are defined but never called: `planing/list`, `update`, `sort`, `push-rti`.
- `MISSING_LOGIC.md` and `RTI_DESIGN_COMPARISON.md` are out of date.
- Employee Assignments Export has no handler. Its Status column is hard-coded.
- The "{k} Selected" counter counts `row.selected`, but ticks set `row.print`.
- The save success toast shows twice.
- Levi delete has no confirm.

## Open questions

- **Q-REV (the owner must decide):** what should Revise do in the app? `/revise` re-reads each job line from the current sale order: job no., date, pickup/delivery date, origin, destination and customer.
  - **A. Copy React exactly:** confirm, call `/revise`, show "RTI revised successfully", and change nothing on screen or on the server. (The server does re-copy the pickup, delivery and warehouse tables during the GET.)
  - **B. Load and review** (what .NET `ReviseRTI` did, and what the backend comment says: "Use GET /{id}/revise to load data for the UI"): confirm, load the result into the form showing each change as was/now, let the user edit, confirm, then save with the normal PUT.
  - **C. Revise in place** (`reviseRTIInPlace`): confirm, then fetch, validate and PUT straight away, with no review.
  - *My recommendation is B.*
- **Q-REV-ROW:** should the planning row's "RTI Revise" (PT9) be shown? It would use whichever Q-REV behaviour you pick.
- **Q-RTI-LIST:** should the RTI list use `/with-jobs` (shared, safe for drivers, includes the jobs, already used by the app) or React's `/active`? The filters and results are the same.
- **Q-JOBLOOKUP:** should the Job No lookup use React's `POST /api/sale-orders/search` plus an exact match, or the app's current `GET /api/rti-masters/company/{id}/job-search`? *Proposed: React's, for exact parity.*
- **Q-IDS:** React falls back to driver id 22 (OUTSIDE DRIVER) and truck id 43 (NONE) when the lookup by name fails. Should I copy that?
- **Q-SEARCH:** the SEARCH field's label says job numbers, but Java filters on ports. Should I keep React's label?
- **Q-TRUCKLOC:** Truck Location is a web page. Should it open in the browser, or be left out?
- **Q-LEVIDEL:** should Levi delete ask for a confirm, unlike React?
- **Q-TOAST / Q-COUNT:** may I fix two small React slips in the app? The save toast shows twice, and the "Selected" counter counts the wrong field.
- **Q-DEV:** I need the dev backend URL plus a test company and login for Step 4. The app points at the live server.

## Decisions (owner, 2026-10-05)

The owner approved the matrix, chose **Option B** for revise, and said to use the best option for the rest.

| Question | Decision |
|---|---|
| Q-REV | **B. Load and review.** Confirm with React's text, then `GET /revise` → the form shows each changed job value as was → now → the user edits → confirm → `PUT /api/rti-masters/{id}` → "RTI revised successfully". If `routeActivities` comes back null, the stops already loaded are kept. |
| Q-REV-ROW | **Shown.** A planning row with an RTI offers "Revise RTI", which opens that RTI in the revise flow above (the handler's confirm text, `usePlanningListPage.ts:813-845`). |
| Q-RTI-LIST | **`/with-jobs`.** It is shared, drivers may call it, it includes the jobs, and it takes the same filters. The preview loads the full RTI the way React does. |
| Q-JOBLOOKUP | **React's lookup:** `POST /api/sale-orders/search`, exact match, then `GET /api/sale-orders/{id}`. |
| Q-IDS | **Copy React.** Look the OUTSIDE DRIVER and NONE trucks up by name; fall back to ids 22 and 43. |
| Q-SEARCH | **Keep React's label**, "Job numbers, comma separated...". |
| Q-TRUCKLOC | **Open the web page** in the device browser. |
| Q-LEVIDEL | **Confirm before deleting** ("Delete levi entry?"). This is the only difference from React, kept for safety. |
| Q-TOAST / Q-COUNT | **Fixed in the app:** one success message; the selected count counts ticked rows. |
| Q-DARK | **Light and dark** are built now. |
| Q-DEV | Still open: the dev backend URL and a test login are needed for Step 4. |
