# Tasks

## 1. Data

- [x] 1.1 `overview/data/admin_overview_repository.dart` and summary models over the existing clients;
      unit tests with fake clients for each counting rule (JO open, IR open, truck location today/workshop)
- [x] 1.2 `overview/bloc/admin_overview_cubit.dart`: parallel load, per-area loading/data/error, reload all
      and retry one; cubit tests: one area failing leaves the others loaded

## 2. Screen

- [x] 2.1 `overview/view/admin_overview_tab.dart` and widgets (header, quick buttons, number cards, section
      cards) in existing tokens; phone one column, tablet wide layout; widget tests for both widths and for
      a failing area showing Retry
- [x] 2.2 Quick buttons: tab switch for SO/JO/Mailbox Monitor/IR; menu-gated screen buttons for Vessel
      Planning (with menu flags), Truck Planning, Truck Location; widget test: button hidden without menu entry

## 3. Dashboard

- [x] 3.1 Overview first tab for role 100 only in `admin_dashboard.dart` / `admin_dashboard_ui.dart`
      (controller length +1, tab ids from one list); widget test: role 100 first tab Overview, role 200 SO
- [x] 3.2 `flutter analyze lib/features/dashboard/admin_dashboard`; `flutter test test/features/dashboard/admin_dashboard`

## 4. Owner check

- [ ] 4.1 Owner on tablet and phone as Super Admin: Overview first, numbers match SO, JO, Mailbox Monitor,
      IR, Planning, Vessel Planning and Truck Location for the same day; buttons open the right place; Admin
      (200) dashboard unchanged
