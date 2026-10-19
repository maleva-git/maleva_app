## 1. Session

- [x] 1.1 `MobileSession`: `jobs`, `linkedDriverId`, `linkedEmployeeId`; `SessionWriter` + `AppPreferences` store and clear them; `AppSession.hasJob`. Verify: `mode_switch_test.dart`.

## 2. Tabs (spec boarding)

- [x] 2.1 `work_tabs/work_tabs.dart` `workTabsFor`. Verify: `work_tabs_test.dart`.
- [x] 2.2 Boarding and forwarding agent dashboards use it (`boarding_dashboard.dart:40`, `forwarding_agent_dashboard.dart:24`, both `_ui.dart`). Verify: `work_tabs_test.dart`.
- [x] 2.3 Replace role 500/600 checks with job checks (`Port.dart:13`, `vesselreport_bloc.dart:56`, `vesselreportview_tab.dart:176,261,1573,1743`). `core/session/work_jobs.dart`. Verify: `work_tabs_test.dart` (boarding checks, old-backend fallback).

## 3. Driver mode (spec authentication)

- [x] 3.1 `SessionService.switchTo`. Verify: `mode_switch_test.dart`.
- [x] 3.2 `ModeSwitchButton` on the dashboards; confirm dialog; route reset. On the boarding, forwarding agent and driver dashboards. Verify: `mode_switch_test.dart` (`canSwitch`).

- [x] 3.3 `PushModeGate` used from the three handlers in `main.dart`. Verify: `mode_switch_test.dart` (`otherModeFor`).

## 4. Check

- [x] 4.1 `flutter analyze`: no errors, no new warnings in changed files; `flutter test`: 1033 pass, 1 fails (`bluetooth_page_test.dart`, untouched by this change).
- [ ] 4.2 Owner tests on device: Kabilan's tabs, switch both ways, restart keeps mode, office alert arrives and opens in Driver mode.
