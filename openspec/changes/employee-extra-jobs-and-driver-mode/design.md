# Design

## Session

`MobileSession` (`features/auth/data/mobile_session.dart`) reads three new Java fields as they are:

| Field | Type | Missing (old backend) |
|---|---|---|
| `jobs` | `List<String>` | `[]` → role-based tabs as today |
| `linkedDriverId` | `int?` | `null` → no switch button |
| `linkedEmployeeId` | `int?` | `null` → no switch button |

`SessionWriter` stores them in `AppPreferences` (`jobs` as a comma list, the two ids as ints) and
`AppPreferences.clearOnLogout` clears them. `AppSession` gets `hasJob(String code)`.

## Tabs

New `features/dashboard/work_tabs/work_tabs.dart`:

```
List<WorkTab> workTabsFor({required int roleId, required Set<String> jobs})
```

- Returns `(label, builder)` pairs; the dashboards use its length for the `TabController`.
- `jobs` empty → today's list for the role, exactly (500: VSL, Salary, EmpLeave, IR Report;
  600: VSL, Salary, SpotsSaleOrder, IR Report, InventoryReport, EmpLeave; 1400: Emp Leave, RTI
  Activities, IR Report, FW Requests).
- One "Seal / Break Seal" tab (`work_tabs/seal_break_seal_tab.dart`) with two buttons that push the
  existing `FWUpdatePage` and `FWUpdateBreakSeal` screens, as the drawer does (their own app bar and
  Back would close the dashboard if they were embedded). The drawer menu entries stay.
- The forwarding agent dashboard adds the boarding tabs (VSL; admin: SpotsSaleOrder, InventoryReport)
  for a boarding job; Seal / Break Seal stay in its drawer as today.

`boarding_dashboard.dart:40` (`roleId==500 ? 4 : 6`) and the forwarding agent dashboard (length 4)
take the length from `workTabsFor`.

## Boarding checks

`isBoardingAdmin = hasJob('BOARDINGOFFICERADMIN')`,
`isBoardingOfficerOnly = hasJob('BOARDINGOFFICER') && !isBoardingAdmin`,
`isBoarding = hasJob('BOARDINGOFFICER')`. Each `roleId == 500/600` branch listed in the proposal
is replaced by one of these, with the role as fallback when `jobs` is empty.

## Driver mode

- `SessionService.switchTo(PrincipalKind to)` posts `/api/mobile/auth/switch` through the existing
  Java client, reads `Data1` like login, and calls `SessionWriter`.
- Button: `ModeSwitchButton` widget in the boarding, forwarding agent, admin and driver dashboard
  app bars; hidden when the matching linked id is null.
- After the switch: `Navigator.pushNamedAndRemoveUntil(dashboardRouteFor(...))`, so Back does not
  return to the other mode.
- Errors: 403/400 → toast with the server `Message`; network error → the usual offline toast.

## Alerts of the other mode

- `main.dart:177` (`getInitialMessage`), `:195` (`onMessage`) and `:218` (`onMessageOpenedApp`)
  read `message.data['forKind']`.
- Foreground (`onMessage`): the local notification is shown as today, whatever the mode.
- Tap (`getInitialMessage` / `onMessageOpenedApp`): new `PushModeGate.open(message)`:
  - `forKind` missing, or equal to the current mode → open as today.
  - other mode and a linked id exists → confirm dialog; Yes → `SessionService.switchTo`, then the
    usual open; No → nothing.
  - other mode and no linked id (link removed) → open the home dashboard only.
- The bell list stays per mode (it reads the current principal's notifications).
- Limitation: a push that **starts** the app (`getInitialMessage`) opens in the saved mode, as before.

## Tests

- `work_tabs_test.dart`: each role with no jobs gives today's tabs; 600 + `FORWARDINGAGENT` gives
  boarding admin tabs + RTI Activities, FW Requests, Seal / Break Seal, each once.
- `mobile_session_test.dart`: new fields read; missing fields give defaults.
- `session_service_switch_test.dart`: success writes the new session; 403 keeps the old one.
- `push_mode_gate_test.dart`: same mode opens; other mode asks; no `forKind` opens as today.

Device testing is done by the owner.
