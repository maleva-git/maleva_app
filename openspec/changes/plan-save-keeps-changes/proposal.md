# Proposal

## Why

Owner (2026-10-21): two planners on one plan — the last Save silently wiped the other's work. Backend
change `plan-save-keeps-changes` now updates rows by job, stores the grid order in `RowNo` and refuses a
save made on a plan that someone saved after it was opened.

## What Changes

- The plan's `SaveVersion` from the edit answer is kept with the plan and sent back on Save (and on the
  remarks / order save on the web).
- When the answer is `{ok: false, conflict: true, changedBy, changedAt}` the screen asks
  **"Plan changed by ANNA — Reload or Save over it?"**
  - **Reload**: the plan is read again; the other planner's changes come in and the rows changed here are
    kept (the existing same-plan reload); then the planner saves again.
  - **Save over it**: Save is sent again with `overwrite: true`.
- Rows are still sent top to bottom; their position is now the saved order (no change needed).

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

`core/planning/planning_api.dart` (`PlanSaveConflict`), `models/plan_header.dart`, `data/planning_save_payload.dart`, `bloc/plan_cubit.dart` / `plan_state.dart`, `view/plan_page.dart` (dialog); test `plan_save_conflict_test.dart`.
