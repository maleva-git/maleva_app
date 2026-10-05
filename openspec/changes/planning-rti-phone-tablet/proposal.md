# Proposal

## Why

Planners should be able to plan on a phone or a tablet instead of the desktop.

- **React (desktop) stays exactly as it is.** It is the reference for behaviour.
- Flutter gets the same Planning and RTI features on the same Java APIs, with **two designs**: one for the phone (under 600 dp) and one for the tablet (600 dp and up).
- Three things matter most:
  1. **Search and filter:** every React option, working the same way.
  2. **Plan detail:** every job's truck, driver, route, dates, cargo, vessel, status and RTI at a glance.
  3. **Assigning and saving:** fast and safe.

Today's app screens use desktop-style tables on a phone and lack several React features. The UX problems are listed in change `planning-rti-parity` §U1.

This change **replaces** `planning-rti-parity`. That change's parity matrix, UX audit and questions carry over here, now with a phone and a tablet design per row.

## Phases

1. **Inventory (this document, revised 2026-10-05 against the full brief):** `design.md` holds the matrix, with one row per React search field, button, column and action, plus the API gaps and open questions.
2. **Design checkpoint:** mockups of the phone, tablet portrait and tablet landscape screens for search and filter, the list, the plan detail and assigning, at https://claude.ai/artifact/5e1zJXiZhVQPkq5nDg34Rk (page "Phone & tablet"). **No app code is written until the owner approves both.**
3. **Build:**
   - Feature folders `lib/features/planning/`, `lib/features/rti/` and `lib/features/rti_assignments/`, each with `data/`, `bloc/`, `models/`, `view/phone/`, `view/tablet/` and `widgets/`.
   - Shared widgets go in `lib/core/widgets/`, plus one responsive layout helper.
4. **Verify:**
   - `flutter analyze` passes clean.
   - bloc tests cover search, filters, assigning several jobs at once, save, push to RTI and revise, using the cases from React's tests.
   - Run on an iPhone simulator, an iPad simulator (portrait, landscape, split view), and Android phone and tablet emulators.
   - Plan one real day on each device, then compare the results with React.
5. **Report:** the matrix marked done, deferred or blocked, with screenshots for each device.

## What Changes (Phase 3)

- The phone and tablet layouts from `design.md` §L, built on one design system (`planning-rti-parity` §U2–U3) with light and dark themes.
- Every matrix row marked "Build", with React's rules and messages.
- Mobile-only extras that add no business rules. Each one only filters, groups or remembers rows that are already loaded:
  - remembered filters, quick date chips and the result count
  - find-in-results, the by-truck and by-status views
  - recent values first in the pickers
  - assigning the same truck or driver to several jobs at once

## Capabilities

### New Capabilities
- `planning-rti-mobile`: Planning and RTI on phone and tablet, matching the React modules on the shared Java API.

## Impact

App only:
- `lib/features/planning/**`, `lib/features/rti/**`
- `lib/core/planning/planning_api.dart`, `lib/core/rti/*.dart`
- `lib/core/widgets/**`, `lib/core/theme/**`, `lib/main.dart`
- `lib/menu/menulist.dart`, the dashboards that mount the RTI tabs
- `test/**`

No backend or React change.
