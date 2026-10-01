# MALEVA OpenSpec

This is the baseline for the existing MALEVA Flutter client, established on
2026-10-01. Start here when planning a feature, bug fix, or refactor.

## What is documented

- [Capability index](baseline/module-inventory.md): all feature families, dashboard
  folders, common tabs, and the baseline spec that owns each area.
- [Architecture and workflows](baseline/architecture.md): startup, application
  organization, and the principal cross-module flows.
- [Permissions](baseline/permissions.md): role routing, client action restrictions,
  and Android/iOS permission declarations.
- [API interactions](baseline/api-interactions.md): transport conventions and
  reviewed request/response contracts.
- [Endpoint inventory](baseline/endpoint-inventory.md): endpoint constants,
  source references, and inline API paths outside the constants file.
- [Clarification register](baseline/clarifications.md): observed inconsistencies
  and questions requiring a product, backend, or device answer.
- [Validation record](baseline/validation.md): checks performed for this setup.

`specs/<capability>/spec.md` contains the baseline requirements and WHEN/THEN
scenarios. `changes/<change-name>/` is for future proposals and requirement
deltas. The baseline is written directly as main specs because it describes
existing behavior; there is no fictitious completed implementation change.

## Evidence standard

**Code-verified** means that the behavior is visible in the inspected client
source. It does not mean it passed a live test. Tests cited in specs were read
for context; their presence is not a passing test result.

**Inventoried** means a module, declaration, method, or reference exists. Module
inventory rows do not certify every field, error branch, route, or deployed role
configuration. The major workflows have behavioral specs; smaller report and
utility tabs are covered at their integration boundary and listed individually.

**Needs clarification** covers backend enforcement and semantics, device behavior,
production reachability, and conflicting client paths. Such claims are outside
the normative requirements until confirmed. Existing defects or risky behavior
are recorded as observations, not requirements to preserve forever.

No backend source or live API responses were used. No app launch, device test,
server write, notification, email, or support upload was performed for this setup.

## Future change workflow

The project-local [schema](schemas/maleva-spec-driven/schema.yaml) requires this
order for behavior changes:

```text
proposal.md → specs/<capability>/spec.md → design.md → tasks.md
                 complete plan → user asks to apply → implementation
```

The schema requires a design even for small changes and lists all four artifacts
as prerequisites for apply. File presence is not content validation or approval.
The [project instructions](../AGENTS.md) and [config](config.yaml) establish the
review/apply boundary. These are agent workflow rules, not a security boundary
preventing someone from editing source directly.

1. Read the relevant baseline specs, source evidence, and clarification IDs.
2. Propose a named change using the configured schema. Keep unchanged requirements
   out of the delta and use the existing capability names.
3. Write the proposal, requirement deltas, design, and verifiable task checklist.
4. Resolve material open questions and validate the plan. Present it for review.
5. Implement only when the user explicitly asks to apply it. Run checks appropriate
   to the changed behavior and record actual results.
6. After completion, sync/archive when requested so main specs reflect the change.

Pure documentation/tooling/refactoring changes with no requirement change use
the explicit `skip_specs: true` marker, with the rationale in the proposal.
Proposal, design, and tasks are still required. Never invent product behavior to
make a documentation-only change pass validation.

Example planning prompt:

> Use OpenSpec to propose [the change]. Read the relevant MALEVA baseline specs
> and code. Create the proposal, requirement deltas, design, and tasks for review.
> Keep application code unchanged until I ask you to apply the plan.

Example implementation prompt after reviewing those files:

> Apply OpenSpec change [change-name] and report the verification results.

## Local commands

OpenSpec 1.14.0 was found in the existing npm-global installation. In this setup
shell it is not on PATH. Use `$HOME/.npm-global/bin/openspec` in place of `openspec`
below if needed; no reinstall or shell configuration change is required.

```sh
openspec list --specs
openspec new change <change-name>
openspec status --change <change-name> --json
openspec instructions proposal --change <change-name> --json
openspec instructions specs --change <change-name> --json
openspec instructions design --change <change-name> --json
openspec instructions tasks --change <change-name> --json
openspec validate <change-name> --strict --no-interactive
openspec schema validate maleva-spec-driven
openspec validate --all --strict --no-interactive
```

The schema is a project-local fork of the installed `spec-driven` schema. Future
OpenSpec upgrades should be checked against this fork; generated skill updates
do not imply its instructions or templates have been upgraded automatically.
