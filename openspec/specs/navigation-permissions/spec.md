# Navigation and client permissions

## Purpose

Describe dashboard selection, server-provided menus, and the specific permission boundaries visible in the client.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/core/router/app_router.dart](../../../lib/core/router/app_router.dart)
- [lib/features/auth/presentation/pages/login_page.dart](../../../lib/features/auth/presentation/pages/login_page.dart)
- [lib/splash/splashscreen.dart](../../../lib/splash/splashscreen.dart)
- [lib/menu/menulist.dart](../../../lib/menu/menulist.dart)
- [lib/features/ir_report/presentation/ir_permissions.dart](../../../lib/features/ir_report/presentation/ir_permissions.dart)
- [lib/features/ir_report/presentation/ir_report_routes.dart](../../../lib/features/ir_report/presentation/ir_report_routes.dart)
- [lib/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart](../../../lib/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart)

## Requirements

### Requirement: Choose dashboard after manual login

Manual login SHALL send driver sessions to the driver dashboard and employee sessions to the role-mapped dashboard.

#### Scenario: Sales employee
- **WHEN** manual login completes with role 300
- **THEN** the sales dashboard opens.

#### Scenario: Unmapped manual role
- **WHEN** manual login completes with an unmapped role
- **THEN** the unauthorized page opens.

### Requirement: Search supplied menu entries

The drawer SHALL build root groups from supplied menu rows and filter them by matching group or child label text.

#### Scenario: Child label search
- **WHEN** the user searches for text found in a child menu label
- **THEN** the matching parent group remains eligible for display.

### Requirement: Restrict incident report actions

Incident report client actions SHALL allow admins with roles 100 or 200 to edit/delete any report, other users to edit their own report only with a nonzero employee ID, and menu flags to narrow these rights.

#### Scenario: Menu denies edit
- **WHEN** an otherwise eligible user has PageEdit disabled for the IR menu entry
- **THEN** editing through that entry is unavailable.

#### Scenario: Driver has no employee identity
- **WHEN** the session is a driver login
- **THEN** the IR employee identity is 0, so ownership alone does not grant edit rights.

### Requirement: Limit selected sales form fields

The transaction sales form SHALL apply its hard-coded employee restrictions to editable fields.

#### Scenario: Restricted employee
- **WHEN** the signed-in employee is in the form restriction list
- **THEN** the generated permission map enables only the two boarding officers, their amounts, SAVE, and VIEW from the listed fields.

## Clarifications

See Q01 for the complete role-route mismatch, Q03 for server enforcement, Q05 for employee-specific restrictions, and baseline/permissions.md for device declarations. These checks do not establish global authorization. See [the clarification register](../../baseline/clarifications.md).
