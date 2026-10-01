# Baseline validation record

Date: 2026-10-01 (user timezone: Asia/Kolkata).
Source revision inspected: `3dddb4ce1e878e1a19739d9d5a5c26b163acf174`.
OpenSpec CLI: `1.14.0`, using the existing npm-global installation.

## Delivered scope

- 21 main capability specs with 78 requirements and 104 WHEN/THEN scenarios.
- Module inventory including every feature family and all 58 common-tab folders.
- API interaction matrix and inventory of 143 endpoint constants plus 15 distinct
  inline API path fragments outside the constants file.
- Role routing, client permissions, device declarations, and 12 clarification IDs.
- A project-local `maleva-spec-driven` schema, project rules, and root `AGENTS.md`.

## Checks performed

| Check | Result |
| --- | --- |
| `openspec validate --all --strict --no-interactive` | 21 specs passed, 0 failed. |
| `openspec schema validate maleva-spec-driven` | Schema and templates valid. |
| Default schema selection in an isolated temporary project containing this config/schema | A new change resolved `maleva-spec-driven` without an explicit schema override. |
| Artifact dependency progression | Proposal first; specs require proposal; design requires proposal/specs; tasks require specs/design. |
| Apply prerequisite check | All four artifacts are listed in applyRequires. Writing tasks early still leaves apply blocked when design is missing. Completing all four makes the fixture ready. |
| Design instruction and config loading | The fixture's instructions include mandatory design and project context. |
| Strict change validation | Completed temporary fixture passed. |
| No-behavior-change exception | Separate temporary fixture with explicit `skip_specs: true`, proposal, design, and tasks passed and became ready. |
| Local Markdown references | All non-template local links resolve to existing files/directories. |
| Application scope | SHA-256 comparison found all 950 tracked files outside the allowed documentation scope unchanged. Git status contains only `openspec/` changes and root `AGENTS.md`. |

Workflow fixtures were created in a temporary directory and removed after the
checks. There is no example or pretend implementation change left in the real
project's `openspec/changes/` folder.

## Limits of these checks

Strict OpenSpec validation checks artifact structure, not whether every source
claim is correct or a backend supports the client. Source evidence was reviewed
separately and unresolved behavior is recorded in the clarification register.

Flutter analysis, Flutter tests, native builds, live API calls, notification
delivery, and physical printer/permission checks were not run: application code
was not changed. Existing tests were inspected and inventoried, not reported as
passing. The baseline is a starting contract for future changes, not a runtime
certification of the app or a backend specification.
