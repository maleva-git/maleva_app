# Forwarding operations

## Purpose

Describe updating forwarding references, seal assignments, SMK records, and forwarding salary requests.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/operations/forwarding/bloc/forwarding_bloc.dart](../../../lib/features/operations/forwarding/bloc/forwarding_bloc.dart)
- [lib/features/operations/forwardingsmk/bloc/forwardingsmk_bloc.dart](../../../lib/features/operations/forwardingsmk/bloc/forwardingsmk_bloc.dart)
- [lib/features/operations/forwardingsalary/bloc/forwardingsalary_bloc.dart](../../../lib/features/operations/forwardingsalary/bloc/forwardingsalary_bloc.dart)
- [lib/core/network/api_services/operations_api.dart](../../../lib/core/network/api_services/operations_api.dart)
- [lib/features/dashboard/common_tabs/unrelease/data/unrelease_repository.dart](../../../lib/features/dashboard/common_tabs/unrelease/data/unrelease_repository.dart)

## Requirements

### Requirement: Update forwarding sections

The forwarding form SHALL submit the selected sale-order context and the three sections of seal/break employees, entry/exit references, and SMK numbers.

#### Scenario: Save forwarding
- **WHEN** the user saves a loaded forwarding form
- **THEN** the client posts section-specific values to the forwarding update service, using null for empty SMK text.

#### Scenario: Successful forwarding response
- **WHEN** the service reports IsSuccess=true
- **THEN** the form emits success and resets to its default loaded state.

### Requirement: Edit forwarding SMK information

The SMK flow SHALL load a selected job and submit its edited forwarding fields and date/checkbox selections.

#### Scenario: SMK save
- **WHEN** the loaded SMK form is saved
- **THEN** the client posts its constructed master payload to UpdateForwarding.

### Requirement: Submit forwarding salary data

The forwarding salary API wrapper SHALL provide insert and select requests for forwarding salary records.

#### Scenario: Salary insert
- **WHEN** the caller submits a forwarding salary payload
- **THEN** the client posts it to InsertForwardingSalary.

### Requirement: Select unreleased forwarding records

The unrelease repository SHALL request company-scoped records from the K8 endpoint for type 1 and the general unrelease endpoint for other types.

#### Scenario: K8 selection
- **WHEN** unreleased records are requested with type 1
- **THEN** the client posts company context to LoadK8UnReleaseNo and converts returned rows to maps.

## Clarifications

Q06 covers status/reference meaning and screen overlap; Q03 covers enforcement outside the client. No payroll formula is inferred from endpoint names. See [the clarification register](../../baseline/clarifications.md).
