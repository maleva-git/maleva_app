# Tasks

## 1. Tabs
- [x] 1.1 `WorkTab.preAlert`, label "Pre Alert", in `workTabsFor` for both dashboards; `workTabView` → `PreAlertReportBody(workMode: true)`
- [x] 1.2 Update `test/features/dashboard/work_tabs_test.dart`

## 2. Pre Alert screen
- [x] 2.1 `PreAlertStarted(workMode)`; state gains `workMode` and `portChoice` (`PreAlertPortChoice`)
- [x] 2.2 Work mode defaults: ETA All (`etaVal` 3, enabled), Delivery Done ticked, first own port selected
- [x] 2.3 `PreAlertReportBody` (no Scaffold) used by the tab and by the full `PreAlertReport` page
- [x] 2.4 "Select Port" dropdown at the top, "View PDF" fixed at the bottom; company ports + All Ports when none assigned; L.Emp hidden and unticked
- [x] 2.5 Bloc test for the work-mode defaults and port rules

## 3. Checks
- [x] 3.1 `flutter analyze` on the changed files, `flutter test` for the tests above
- [ ] 3.2 Owner: device test with a role 500, a role 600 and a role 1400 login
