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
