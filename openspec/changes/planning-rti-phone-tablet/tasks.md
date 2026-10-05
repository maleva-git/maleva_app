## 1. Inventory (Step 1)

- [x] 1.1 Reference facts checked against the code; 20 corrections (design.md §0).
- [x] 1.2 Parity matrix: access, search, header buttons, columns, row behaviour, assign/save/load/delete, sale-order update, Planning → RTI, Planning View, RTI entry, job grid, route activities, revise, Levi, share/report, RTI list, Employee Assignments, layout.
- [x] 1.3 Owner approved the matrix (2026-10-05): Q-REV = B; the other answers are in design.md "Decisions".

## 2. Design (Step 2)

- [x] 2.1 (2026-10-05, artifact pages "Planning" and "RTI", 62 boards) Phone, tablet portrait and tablet landscape for: Planning search & filters, list/board, detail, assign, Create RTI, Create All RTI, Push RTI; Planning View; RTI list + preview; RTI entry (header, charges, job grid, route activities); Levi; Revise; share/report; Employee Assignments. (Planning search, list, detail and assign are already drafted on the artifact page "Phone & tablet".)
- [x] 2.2 Owner approved the designs (2026-10-05).

## 3. Build (Step 3)

- [x] 3.1 `ResponsiveLayout`, theme (light/dark) and shared widgets in `lib/core/widgets`. Verify: `flutter analyze` clean on lib/core/widgets/ui, theme, layout; status tone, date format and planning API tests pass (6).
- [x] 3.2 `features/planning`: data, bloc, models (Java fields), view/phone, view/tablet, widgets; files about 400 lines at most.
- [x] 3.3 `features/rti`: entry, list, preview, route activities, Levi, revise, share/report.
- [x] 3.4 `features/rti_assignments`.
- [x] 3.5 Menu and dashboards point to the new screens; old screens removed (transaction/planning, transport/updatertidetails, common_tabs/rtiview incl. the mock Create RTI, common_tabs/planningdetailsview). Drivers reach RTI Status from the RTI preview's job lines.

## 4. Verify (Step 4)

- [x] 4.1 `flutter analyze`: 0 errors, no new warnings against the baseline, no issues in the new code.
- [x] 4.2 (284 new tests in test/features/planning, rti, rti_assignments + 6 foundation; full suite 597 pass, only the inherited bluetooth_page_test fails) bloc tests: search rules, payload and merge; save validation, payload and delete; Clone, Sort, Create RTI refusals, Create All readiness; RTI total, RTI validation, Job No lookup and replace; route-activity defaults; Levi checks; revise. Cases from the React tests.
- [ ] 4.3 (owner runs this; see report.md §7) iPhone, iPad (portrait, landscape, split view), Android phone and tablet.
- [ ] 4.4 (owner, on the dev backend; see report.md §7) One real day on the tablet and the phone, repeated in React; the saved plan, RTI, route activities and Levi match.

## 5. Report (Step 5)

- [x] 5.1 (report.md, 2026-10-05) Matrix marked done, deferred or blocked; screens per size; files; tests; open questions.
