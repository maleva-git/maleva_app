# Proposal

> **Superseded by `planning-rti-phone-tablet`** (2026-10-05). Its matrix rows, UX audit (§U) and questions are reused there.

## Why

The app's Planning and RTI screens use the shared Java API, but they lag the React web app:
- Create All RTI, the RTI status per planning row, Levi entry, WhatsApp share and Employee Assignments are missing.
- Screen-access rules are not applied.
- The forms are large single setState files (`add_planning_page.dart` is 1795 lines and `add_rti_page.dart` 1453).
- The dashboard "Create RTI" is a mock.
- The screens are hard to use on a phone and do not look like one app. Section 2 lists the
  problems, measured in the code.

The owner wants React parity on the same Java endpoints, with a mobile-first UI. Only Flutter changes: React and the backend stay as they are (CLAUDE.md rules 1, 2 and 5).

**Phase 1 (this document) is the inventory only.** `design.md` holds the parity matrix, gaps and open
questions. No code is written until the owner approves it.

## UX problems in the app today

Measured in `planning_tab.dart`, `add_planning_page.dart`, `updatertidetails_tab.dart`,
`add_rti_page.dart`, `rtiview_tab.dart` and `rtistatus_tab.dart`. Full evidence is in `design.md` §U1.

1. **Desktop tables on a phone.** The plan lines (13 columns) and the RTI job lines (13 columns) are
   wide tables that scroll sideways. The user sees about three columns at a time and loses the row.
2. **Two colour systems.** The old `colour.*` constants (79 uses in the planning form, 49 in the plan
   list, 30 in RTI View, 28 in RTI Status) are mixed with `AppTokens`. The same status looks different
   on each screen. There is no dark theme, and Material 3 is off.
3. **Text too small and inconsistent.** There are 72 hand-set font sizes in the planning form and 48 in
   the RTI form, most of them 11–13 px. They ignore `AppTypography` and the phone's text size.
4. **Small touch targets.** 17 controls in the planning form and 7 in the RTI form are 20–47 px high,
   under the 48 dp minimum.
5. **Too many equal buttons.** The planning form has eight buttons of the same weight in one bar
   (SEARCH, SORT, NEW, SAVE, UPDATE, VIEW, DELETE, PUSH TO RTI), with Delete next to Save. The RTI form's
   labels are cryptic: **LOAD** means "revise from sale orders", and **VIEW** only closes the page.
6. **Hidden actions.** Plan details and the driver job status open only on a **long-press**, with
   nothing on screen to show it.
7. **No feedback patterns.** There is no pull-to-refresh on any of these screens. Loading is a
   full-screen spinner, with no skeleton. Success opens a blocking dialog (`msgshow`) instead of a
   snackbar. Validation errors appear in a dialog, not under the field.
8. **Filters you cannot see.** Filters live behind a floating button. Once applied, nothing on the
   list shows which filters are active.
9. **Three different RTI lists.** RTI View defaults to Jan–Dec, Update RTI to today, and PDO uses its
   own dates. Each looks different. The dashboard "Create RTI" shows fake data (`JOB-8992`,
   `TN-04-AX-1234`).
10. **Logic inside the widgets.** Every screen keeps its own tablet branch (`isTablet`, used 30 times in
    the plan list). The two forms are setState files of 1795 and 1453 lines, so busy states and
    double-submit guards are not consistent.

## Design goal

The aim is a clean, modern Material 3 app that looks like one product in light and dark, is easy to
use with one hand, and reads well in the sun on a truck yard. `design.md` §U2–U5 gives the design
system, the components, every screen layout and the rules each screen is checked against:

- **One design system.** The brand colours become a Material 3 `ColorScheme` (light and dark). The
  seven React status tones become paired colours in both modes. One type scale with a 14 px minimum
  for body text, a 4/8 spacing grid, 12 px card corners, and no raw colours or font sizes in the screens.
- **Cards, not tables.** Each plan, line, RTI and job is a card showing its key fields, with a status
  badge and an expandable section for the rest.
- **One clear main action per screen.** A sticky bottom bar holds the main action; the rest go in an
  overflow menu. Delete is always red, always separate and always confirmed.
- **Forms in steps.** The RTI form has five steps (Trip → Jobs → Allowances → Route → Review). The plan
  editor has a header card, then the lines. Errors show under the field, the running RM total stays in
  view, and a busy state blocks double submits.
- **Visible state.** A search bar with filter chips, pull to refresh, skeletons, empty and error states
  with Retry, and success snackbars.
- **Revise is its own flow.** Changed values are shown as "was → now" before the user submits.
- **Works everywhere.** A 320 pt phone, a large phone, and a tablet with list and detail side by side;
  text scaled to 130 %; light and dark.

Clickable mockups of these layouts, in light and dark: https://claude.ai/artifact/5e1zJXiZhVQPkq5nDg34Rk

## What Changes (Phase 2, after approval)

- New feature folders `lib/features/planning/` and `lib/features/rti/`, each split into data, bloc, models, view and widgets. They replace `transaction/planning/*`, `transport/updatertidetails/*`, `dashboard/common_tabs/rtiview/*` (including the mock `create_rti_screen.dart`) and `planningdetailsview/*`.
- Typed models read the Java field names, replacing the untyped line maps and the `AppGlobals` planning and RTI lists.
- Screens to add: Create RTI from ticked rows, Create All RTI (preview, then create), the RTI badge per planning row, RTI revise as its own flow, route activities in the RTI form, Levi entry, WhatsApp share, Employee Assignments, the planning report date, and screen-access gating.
- Design system first: a Material 3 light and dark theme built from the tokens, a status tone map,
  and the shared components in `design.md` §U3. Every new screen uses only these.
- Each screen is rebuilt to the layouts in `design.md` §U4 and checked against §U5.
- Tests: repositories, validators, the amount rule, the batch helpers, blocs (bloc_test) and the revise flow. The cases come from the React `*.test.ts(x)` files.

## Capabilities

### New Capabilities
- `planning-rti-parity`: the app's Planning and RTI screens match the React modules on the shared Java API.

## Impact

App only: `lib/features/planning/**`, `lib/features/rti/**`, `lib/core/planning/planning_api.dart`,
`lib/core/rti/*.dart`, `lib/core/widgets/**`, `lib/core/theme/**`, `lib/main.dart` (theme), `lib/menu/menulist.dart`, dashboards that mount the RTI
tabs, `test/**`. No backend or React change.
