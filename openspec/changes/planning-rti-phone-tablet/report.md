# Final report: Planning and RTI on phone and tablet

Change `planning-rti-phone-tablet`, 2026-10-05.

## 1. Summary

Planning (plan screen and plans list), RTI (entry, list, revise, Levi, share, report) and Employee Assignments are built in Flutter on the same Java endpoints React uses. Each screen has three layouts, all with light and dark themes:
- **Phone:** under 600 dp.
- **Tablet portrait:** 600–900 dp, master-detail.
- **Tablet landscape:** over 900 dp, board and tables with keyboard shortcuts.

The menu and dashboards open the new screens. The old Planning and RTI screens are removed.

**Checks:**
- `flutter analyze`: 0 errors and no new warnings.
- 290 new tests pass. The full app suite has 597 passing tests and 1 failure, the Bluetooth test that was already failing.
- React was not changed.
- **Backend changes:** one, made at the owner's request on 2026-10-05: the mobile login menu now ports the .NET menu (§7).

**Testing on devices and against React is the owner's to do** (tasks 4.3 and 4.4).

## 2. Corrections to the brief

K1–K20 in `design.md` §0 list what the code does where it differs from the brief. Points found while building:

| # | Brief or design said | Code says, and what the app does |
|---|---|---|
| B1 | Route stops start at Seq 10 | React's `addRouteActivity` gives the first stop 1 (`useRTIState.ts:162-163`); the 10 in `rti.initialState.ts:81` is never used. **The app uses 1.** |
| B2 | Sale-order update uses `SaleOrderApi.planningUpdate` | That call re-reads origin, destination, quantity and weight from the server; React sends the edited values (18 keys, `planningSaleOrderUpdate.ts:215-244`). **The app posts React's payload.** |
| B3 | Employees from `EmployeeApi.dropdown` | The dropdown labels "Name-Type" and drops inactive staff; React shows `employeeName` from `/api/employees/company/{id}/all?type=ALL`. **The app calls that endpoint.** |
| B4 | Ports from an existing app API | None existed. **The app calls `/api/port-masters/company/{id}/active`, as React's `usePorts` does.** |
| B5 | OUTSIDE DRIVER is a truck (id 22) | It is both a truck (id 22) and a driver row (id 36) (`DriverSelectModal.tsx:37-42`). **The app follows both files as written.** |
| B6 | RTI list amounts "RM 1,245.00" | React's list uses `toFixed(2)`: "RM 1245.00". **The list shows it React's way**; the RTI entry total uses separators, as React's charges summary does. |

## 3. Parity matrix (row ids from `design.md`)

**Overall:** every row is ✅ except the ones listed under "Not done".

| Area | Rows | Status |
|---|---|---|
| Access (screen access, view-only, locked buttons) | PA1–PA7 | ✅ |
| Planning search and filters | PS1–PS14 | ✅ except PS13 ⏳ (see below) |
| Planning header buttons | PB1–PB17 | ✅ except PB5 (AI Suggest, out of scope) |
| Grid columns and row behaviour | PC1–PC20, PR1–PR9 | ✅ (drag to reorder on every layout, added 2026-10-05) |
| Assign, save, load, delete | PV1–PV12 | ✅ |
| Sale-order update | PU1–PU4 | ✅ except PU2 ⏳ (see below) |
| Planning → RTI (badges, Push, Create, Create All, row Revise) | PT1–PT9 | ✅ |
| Plans list (Planning View) | PW1–PW6 | ✅ |
| RTI entry | RE1–RE21 | ✅ |
| RTI job grid | RG1–RG8 | ✅ except RG7 ⏳ (see below) |
| Route activities | RA1–RA6 | ✅ (first Seq 1, see B1) |
| Revise (option B) | RV1–RV4 | ✅ |
| Levi | RL1–RL6 | ✅ except RL2 ⏳ (see below); delete asks first (decision Q-LEVIDEL) |
| Share and report | RS1–RS2 | ✅ |
| RTI list | RLs1–RLs8 | ✅ |
| Employee Assignments | EA1–EA3 | ✅ |
| Layout, theme and shared widgets | L1–L4 | ✅ |

**Not done:**
- **Out of scope or deliberately left out:**
  - PB5, AI Suggest.
  - RE22, agent fields: not shown or saved, the same as React.
  - EA4, Export: React's button has no handler.
- **⏳ PS13 remembered filters:** kept while the app is open, not across restarts.
- **⏳ PU2:** origin and destination are typed fields. React's location dropdowns (shown for some job types) and its warehouse address autocomplete are not ported.
- **⏳ RG7 multi-cell paste on the phone:** paste works on the tablet (Ctrl/Cmd+V).
- **⏳ RL2 Levi attachments on the phone:** photos only. Other file types need the `file_picker` package.

**⛔ Blocked:** none in the build.

**Verification still open (owner):**
- 4.3: runs on devices.
- 4.4: one planning day compared with React on the dev backend.

## 4. Screens

The layouts follow the approved designs at https://claude.ai/artifact/5e1zJXiZhVQPkq5nDg34Rk:
- the **"Planning"** page: plan screen, plans list, Create, Push and Create All RTI;
- the **"RTI"** page: RTI list, entry, revise, Levi, assignments.

Each page has phone, tablet-portrait and tablet-landscape rows. Layout tests render every screen at all three widths, in light and dark, with no overflow. Device screenshots come from the owner's testing (4.3).

## 5. Files changed

**App (`maleva_app/`)**
- **New features:**
  - `lib/features/planning/`: the plan screen, Create All RTI, sale-order update and the plans list in `plans/`. 61 files.
  - `lib/features/rti/`: RTI entry, Levi, revise, the RTI list in `list/`, and the Planning→RTI service and navigation. 56 files.
  - `lib/features/rti_assignments/`: 14 files.
  - About 16,900 lines in all. The largest file is 317 lines.
- **New core code:**
  - `lib/core/layout/responsive_layout.dart`
  - `lib/core/theme/app_theme.dart`, `status_tone.dart`
  - `lib/core/widgets/ui/` (8 shared widget files)
  - `lib/core/access/screen_access_api.dart`
  - `lib/core/rti/levi_api.dart`, `rti_job_lookup_api.dart`, `rti_list_api.dart`, `employee_assignments_api.dart`
- **Edited:**
  - `lib/core/planning/planning_api.dart`: React's search payload, plan by number, RTI status, RTI batch.
  - `lib/core/rti/rti_api.dart`: WhatsApp share.
  - `lib/core/rti/rti_entry_api.dart`: route activities in save.
  - `lib/core/fleet/truck_api.dart`, `driver_api.dart`: lists with expiry and leave dates.
  - `lib/features/auth/auth_injection.dart`, `lib/core/di/injection.dart`: registrations.
  - `lib/menu/menulist.dart`: Planning opens the plans list; Update RTI Details opens the RTI list; the unreachable duplicate case is removed.
  - The admin, operation-admin and maintenance dashboards: the RTI tab opens the new list, and leftover providers are removed.
  - `rtistatus_tab.dart`: after a send it goes back to the list. Drivers open it from the RTI preview's job lines.
- **Removed:**
  - `lib/features/transaction/planning/`
  - `lib/features/transport/updatertidetails/`
  - `lib/features/dashboard/common_tabs/rtiview/` (with the mock Create RTI screen)
  - `lib/features/dashboard/common_tabs/planningdetailsview/`
  - `test/features/transaction/planning_save_body_test.dart` (ported into the new feature's tests)
- **Tests:**
  - `test/features/planning/` (10 files), `test/features/rti/` (11), `test/features/rti_assignments/` (2)
  - `test/core/planning/planning_search_api_test.dart`
  - `test/core/theme/status_tone_test.dart`
- **Left over:** `tool/preview/preview_adapter.dart`, an unfinished device-preview fake backend. It is not used by the app; delete it unless wanted.

**Backend (`maleva-backend/`), owner request (§7)**
- New `module/mobileauth/menu/LoginServicesMobileMenuProvider.java`, replacing the deleted `LegacyCopyMobileMenuProvider.java`.
- Tests: new `LoginServicesMobileMenuProviderTest.java`; `MobileAuthServiceTest.java` updated.
- `docs/MOBILE_AUTH_API.md`; `openspec/changes/add-mobile-auth-api/tasks.md` (1.1 and 1.2 ticked).

**React:** no change.

## 6. Tests and checks

| Command | Result |
|---|---|
| `flutter analyze` (whole app) | 0 errors; no new warnings against the baseline; 0 issues in the new code |
| `flutter test test/features/planning test/features/rti test/features/rti_assignments` | 284 pass (planning 154, RTI entry 79, RTI list + assignments 61, overlapping folders counted once) |
| `flutter test test/core/planning/planning_search_api_test.dart test/core/theme` | 6 pass |
| `flutter test` (whole app) | 597 pass, 1 fails: `bluetooth_page_test` (already failing before this change) |
| `./mvnw test` (backend, after the menu port) | 1778 run, 0 failures |
| `openspec validate planning-rti-phone-tablet --strict` / `add-mobile-auth-api --strict` | valid / valid |

What the tests cover:
- **Planning:** the React test cases (planningAccess, planningAccessUi, planningPlanNoLoad, planningRowOrder, planningRtiBatch, planningSaleOrderUpdate); the search payload and merge; save validation and payload; delete, clone, sort, remove and reorder; assigning (the other field never changes); assigning several jobs at once.
- **RTI:** rtiMoney (including the 37 master and 15 detail key lists), rti.validation, rtiLeviEntryModal; the job lookup and replace; route-activity defaults; the revise flow (option B); the Create RTI refusals in order; the Push prefill.
- **Lists:** filters, stats, share and report messages, the 30 s timeout, and the assignments rules.
- **Layout:** each screen renders at phone, tablet-portrait and tablet-landscape widths, in light and dark.

## 7. Open questions, API gaps and React gaps

**For the owner:**
1. **Device testing (4.3):** iPhone, iPad (portrait, landscape, split view), Android phone and tablet.
2. **One real planning day compared with React (4.4)** on the dev backend: search, assign, save, Create All RTI, open an RTI, add a route activity, Levi, share. The saved plan, RTI, route activities and Levi should match.
3. **Truck Location link:** it opens `https://maleva.mydriverszone.com/truck-location-board`. Please confirm the web app is on that host (`truckLocationBoardUrl`, `lib/features/planning/widgets/plan_flows.dart`).
4. **Who is the user on a plan save:** the app sends the signed-in employee id as both `userRefId` and `employeeRefId`. React takes `userId` and `employeeId` from auth separately. Please confirm they are the same id.
5. **Wording with no React source:**
   - the save-revise confirm ("Save revised RTI?");
   - the revise summary banner;
   - the Levi delete text ("{no} will be deleted.");
   - the WhatsApp confirm title;
   - the view-only banner always says "You can …", because the app has no role name;
   - after a search merge, "(n added · n refreshed)" is added to the success message.
6. **Small behaviour differences:**
   - After Delete or New plan the app fetches the next plan number; React leaves it blank.
   - After Save the app reloads the plan in place; React reloads the page.
   - If one sale order cannot be read while an RTI loads, that job line keeps its saved values; React fails the whole load.
7. **"My Job Only"** in Employee Assignments compares the employee name with the app's saved user name, as React compares with `userName`. They may not always match.
8. **`file_picker`:** add it if Levi attachments on the phone should accept PDFs and other files.

**Mobile menu (backend, done 2026-10-05):**
- The Java login now sends the live .NET menu, including Planning for SALES, TRANSPORTATION, ADMIN and ADMIN2.
- BOARDING, OPERATION, FORWARDING and AIR FRIEGHT users don't see Planning, the same as in .NET.
- `add-mobile-auth-api` task 4.2 (compare the Java and .NET login answers on a test server) stays open.

**API gaps:** none block the work.
- The RTI list API has no vessel, destination or status. The vessel shows in the RTI preview, as in React.
- The Planning sort and push-rti endpoints React defines are never called by React either.

**React gaps (kept as they are):**
- The planning row's RTI Revise handler is never shown in React; the app shows it (decision Q-REV-ROW).
- RTIPage Revise throws its result away; the app follows option B.
- Four Planning components are never rendered.
- Endpoints defined but never called.
- The Employee Assignments Export button has no handler.
- The save toast shows twice; the "Selected" counter counts the wrong field. The app fixes both (Q-TOAST / Q-COUNT).
- Levi delete has no confirm; the app asks first (Q-LEVIDEL).

## 8. Addendum, 2026-10-05: drag to reorder like the web grid

At the owner's request, rows reorder by dragging on every layout, as the web grid's S.NO grip does (`planningColumns.tsx:54-81`, `planningRowOrder.ts` `moveRow`). Only the order changes; Save stores the rows top to bottom.

- **Tablet landscape board:** a frozen **S.NO** column shows the row number and a grip. Press the grip and drag up or down: a blue line shows where the row lands, a label follows the pointer ("TR… → row 3"), and the board scrolls itself near the top and bottom edges. Dragging is off while a filter hides rows; the hint says "clear the filters to reorder". New file `view/tablet/board_drag.dart`; `board_grid.dart` and `tablet_board_view.dart` changed.
- **Tablet portrait list and phone list:** each card has the row number and a grip on its right; drag it up or down. On the phone, long-press still starts multi-select. `phone_plan_view.dart` and `tablet_portrait_view.dart` changed.
- **Row menu and job detail:** **Move to top**, Move up, Move down and **Move to bottom**. `plan_menu.dart` and `job_detail.dart` changed.
- **Tests:** `test/features/planning/plan_reorder_test.dart` (5): drag on the board lands where shown; move to top and bottom; no drag while filtered; phone drag; read-only has no grip. Planning tests 163 pass; the full app suite fails only the old `bluetooth_page_test`.
