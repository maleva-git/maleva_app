# MALEVA project workflow

## Plan before implementation

The project owner requires OpenSpec planning for future changes to this app.

1. Read `openspec/README.md`, the relevant `openspec/specs/*/spec.md`, and
   `openspec/baseline/clarifications.md`. Inspect the affected source and tests.
2. Use the project default `maleva-spec-driven` schema. For a behavior change,
   create a change with `proposal.md`, `specs/<capability>/spec.md` requirement
   deltas, `design.md`, and `tasks.md`. Follow the installed OpenSpec skills.
3. Keep planning read-only with respect to application code. Resolve material
   ambiguity and validate the completed artifacts before presenting the plan.
4. Begin implementation only after the user explicitly asks to apply the plan.
   Such authorization covers the reviewed scope; do not repeatedly ask for it.
5. Verify changes with appropriate checks, update task checkboxes truthfully,
   and sync/archive the change when requested after completion.

Read-only explanations and investigation do not require a new change. Pure docs,
tooling, or refactoring changes still need proposal, design, and tasks; if no
observable requirement changes, use OpenSpec's explicit `skip_specs: true`
mechanism and explain it in the proposal instead of inventing a product requirement.
Do not use that exception for a behavior change. This initial baseline setup is
documentation of existing behavior, not a pending application implementation.

## Evidence and scope

- Baseline facts are verified by source inspection, not by a live backend or device run.
- Source comments about the backend are claims to confirm, not proof of enforcement.
- Preserve API spelling, casing, payload shapes, and zero/null conventions unless
  an approved change explicitly revises them.
- Keep known inconsistencies in the clarification register; do not silently fix
  them while documenting another change.
- Do not put credentials, tokens, production response data, or personal data in specs.
- Keep application changes out of documentation-only work.

## OpenSpec commands

Use `openspec --version` and `openspec list --json` first. If `openspec` is not on
PATH, check the existing npm installation rather than installing another version.
The setup environment has it at `$HOME/.npm-global/bin/openspec`.

```sh
openspec list --specs
openspec new change <change-name>
openspec status --change <change-name> --json
openspec instructions proposal --change <change-name> --json
# Request instructions for specs, design, and tasks in dependency order.
openspec validate <change-name> --strict --no-interactive
openspec validate --all --strict --no-interactive
openspec schema validate maleva-spec-driven
```

## Mobile app and the Java API (owner's rule, 2026-10-02)

The Flutter app is being moved off the old .NET API. Every AI working on this project follows these rules:

1. **One Java API per feature, shared by React and the app.** The app calls the same Java endpoints the React web app uses.
2. **Do not change a backend API or its response to suit the mobile app.** Adapt the app instead: its data layer and models read the Java response as it is (field names, wrapper, empty-list behaviour). New or changed app screens read Java fields directly. `LegacyCallAdapter` / `SharedLookups` (which turn Java answers into the old .NET row shapes) are a transition step: when a screen is reworked, move its model to the Java fields and drop its mapping.
3. **When no Java API exists, write a new one by migrating the .NET code** (controller, service, SQL, stored procedure) into Java properly: the module structure, bound parameters, one transaction, company scoping, tests. Keep the .NET business behaviour; fix a .NET defect only when it is clear, and write it down in the OpenSpec change. Read the .NET source in `MalevaWeb-develop` (the workspace folder next to this repository: `Maleva/AppControllers`, `Services`, `IServices`, `ViewModel`, `Controllers`) or the stored procedure; never guess business rules. The new API is a normal shared API (React can use it), not a mobile-only one.
4. **No new .NET-shaped mobile bridge endpoints** (`/api/mobile/app/*`). Mobile-only endpoints exist only for what is truly mobile: sign-in, session, push token (`/api/mobile/auth/*`). The existing `StockApp` bridge is to be replaced by a shared stock API.
5. **Access, not shape:** when a driver screen needs a shared API, the backend may open that endpoint to driver tokens explicitly, with the driver's limits enforced on the server (own records, own company). That is the only backend change made for the app.
6. Plan with OpenSpec in the repository you change, and record which .NET code a new API was migrated from.
