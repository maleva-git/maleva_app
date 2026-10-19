## 1. Client

- [x] 1.1 `leave_duration.dart` (calendar days, label from dates); the four tabs and two forms use it. Verify: `test/features/leave/leave_duration_test.dart`.
- [x] 1.2 Employee approval tab: no Review on one's own request; both approval tabs reload after a refused review. Verify: `flutter analyze` 0 errors, no new warnings in `driverleave`.

- [x] 1.3 Bloc acts from the last loaded list (no ignored submit after an error; double tap ignored); request tabs list a year ahead. Verify: `test/features/leave/leave_bloc_test.dart`.

- [x] 1.4 `driver_leave_notes.dart` for Planning and RTI pickers. Verify: `planning_models_test.dart`, `test/core/fleet_driver_leave_notes_test.dart`.

## 2. Open

- [ ] 2.1 Owner on devices with the new backend: request a 30-minute leave (shows "30 Mins", stored 1 day); request overlapping leave (server's message); approve another employee's leave; see no Review on your own; two phones approving the same request — the second sees "already reviewed" and the list refreshes.
