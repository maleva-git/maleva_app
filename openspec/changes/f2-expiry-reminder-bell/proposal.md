## Why
Fleet F2: the app's truck / driver picker colours copy the web rule; the web now uses one rule (10 days warning, 5 days
critical) for every paper (owner 2026-10-21).

## What Changes
- `features/rti/models/fleet_expiry.dart` and `features/planning/models/fleet_options.dart`: every truck paper warns at
  10 days and is red at 5; licence / GDL warn at 10, red at 5. Leave notes unchanged.
- `planning_models_test.dart` updated. No backend call changed. Device test by the owner.
