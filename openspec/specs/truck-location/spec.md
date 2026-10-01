# Truck location planning board

## Purpose

Describe the weekly and daily truck location board, local edits, grouping, ordering, and save behavior.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/truck_location/domain/truck_location_rules.dart](../../../lib/features/truck_location/domain/truck_location_rules.dart)
- [lib/features/truck_location/presentation/bloc/truck_location_bloc.dart](../../../lib/features/truck_location/presentation/bloc/truck_location_bloc.dart)
- [lib/features/truck_location/presentation/pages/truck_location_board_page.dart](../../../lib/features/truck_location/presentation/pages/truck_location_board_page.dart)
- [lib/features/truck_location/data/models/truck_location_json.dart](../../../lib/features/truck_location/data/models/truck_location_json.dart)
- [lib/features/truck_location/data/repositories/truck_location_repository_impl.dart](../../../lib/features/truck_location/data/repositories/truck_location_repository_impl.dart)
- [test/features/truck_location](../../../test/features/truck_location)

## Requirements

### Requirement: Use Sunday-based weeks and location hints

The board SHALL calculate date-only Sunday-through-Saturday weeks and hint empty locations using the nearest filled earlier day or the truck last-known location.

#### Scenario: First day empty
- **WHEN** Sunday has no typed location
- **THEN** its hint is the truck last-known location; the hint is not a saved cell value.

### Requirement: Save only changed cells and done ticks

Save All SHALL send changed trimmed cells and changed done ticks with week and session context, keeping edits made during an in-flight save unsaved when they differ from the returned saved data.

#### Scenario: Reverted edit
- **WHEN** a location is edited back to its saved value ignoring surrounding whitespace
- **THEN** that cell is omitted from the changed-cell payload.

#### Scenario: Save failure
- **WHEN** SaveWeek fails
- **THEN** pending changes remain available for retry.

### Requirement: Preserve unsaved work on refresh and exit

The board SHALL keep pending edits during refresh and ask before leaving with unsaved work.

#### Scenario: Refresh while dirty
- **WHEN** the user refreshes a week with pending changes
- **THEN** loaded data is refreshed without discarding the pending edits.

#### Scenario: Exit while dirty
- **WHEN** the user attempts to leave with unsaved changes
- **THEN** the page presents its unsaved-work confirmation flow.

### Requirement: Group and order trucks by location

Location grouping SHALL ignore surrounding whitespace and case, place unlocated trucks last, and keep a row matching its saved location while that cell is being edited.

#### Scenario: Equivalent locations
- **WHEN** rows contain KL, kl, and surrounding-whitespace variants
- **THEN** they belong to the same location group.

### Requirement: Persist row ordering independently

Dragging a truck SHALL update its visible order optimistically and request order persistence, restoring the previous order if that request fails.

#### Scenario: Order save failure
- **WHEN** SaveOrder fails after a drag
- **THEN** the prior row order is restored and an error is shown.

## Clarifications

Q03 covers menu-only exposure and unverified backend authorization. Q06 covers server-provided truck inclusion; this is a manually edited board, not evidence of GPS tracking. See [the clarification register](../../baseline/clarifications.md).
