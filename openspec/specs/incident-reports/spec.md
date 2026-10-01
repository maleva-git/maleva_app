# Incident reports

## Purpose

Describe incident report search, form validation, party selection, persistence, deletion, and client permission behavior.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/ir_report/presentation/list/bloc/ir_list_bloc.dart](../../../lib/features/ir_report/presentation/list/bloc/ir_list_bloc.dart)
- [lib/features/ir_report/presentation/form/bloc/ir_form_bloc.dart](../../../lib/features/ir_report/presentation/form/bloc/ir_form_bloc.dart)
- [lib/features/ir_report/domain/entities/ir_draft.dart](../../../lib/features/ir_report/domain/entities/ir_draft.dart)
- [lib/features/ir_report/data/models/ir_json.dart](../../../lib/features/ir_report/data/models/ir_json.dart)
- [lib/features/ir_report/data/repositories/ir_repository_impl.dart](../../../lib/features/ir_report/data/repositories/ir_repository_impl.dart)
- [lib/features/ir_report/presentation/ir_permissions.dart](../../../lib/features/ir_report/presentation/ir_permissions.dart)
- [test/features/ir_report](../../../test/features/ir_report)

## Requirements

### Requirement: Search incident reports

The incident list SHALL support date, status, open-only, and trimmed text filters, debounce text search by 400 milliseconds by default, and reject reversed date ranges before requesting data.

#### Scenario: Invalid dates
- **WHEN** the from date is after the to date
- **THEN** the client reports the date-range error without issuing that search.

#### Scenario: Status lookup failure
- **WHEN** status choices fail to load
- **THEN** the incident list can still request reports without those choices.

### Requirement: Initialize new incident form

A new incident form SHALL default its occurrence time to now and select OPEN when available, otherwise the first returned status.

#### Scenario: No statuses
- **WHEN** the status lookup is empty
- **THEN** the new form has no status and still requires one before submission.

### Requirement: Validate incident fields

Incident save SHALL require date, status, department, and nonblank description; limit reason to 1000 and vessel/manual party names to 100 characters; and accept only nonnegative whole amounts when an amount is entered.

#### Scenario: Fractional amount
- **WHEN** the amount contains decimals
- **THEN** the form rejects submission with Whole ringgit only, no decimals.

#### Scenario: Blank amount
- **WHEN** the amount is blank and other fields are valid
- **THEN** the save request carries a null ActualAmount.

### Requirement: Represent selected and manual parties distinctly

The incident form SHALL send a selected party ID with an empty manual name, or a typed name with ID 0, and retain stored identity/name for an existing party absent from current choices.

#### Scenario: Outside driver
- **WHEN** the user types an external driver name
- **THEN** DriverRefId is 0 and DriverName is the trimmed typed name.

#### Scenario: Inactive saved truck
- **WHEN** an existing report references a truck missing from lookup choices
- **THEN** the form retains the stored truck ID and name.

### Requirement: Protect in-flight saves and preserve failed draft

The incident form SHALL ignore a second submit during an in-flight save and preserve the draft when saving fails.

#### Scenario: Repeated save tap
- **WHEN** a save request is already running
- **THEN** another submit does not start a duplicate save.

#### Scenario: Save failure
- **WHEN** the repository throws
- **THEN** the form retains its draft and displays a described error.

### Requirement: Reflect incident deletion result

After a successful delete request, the incident list SHALL remove the report and subtract its amount from the displayed total; failed deletes SHALL retain it and show an error.

#### Scenario: Delete rejected
- **WHEN** the delete request fails
- **THEN** the report remains listed and an error message is emitted.

## Clarifications

Client action permissions are specified in navigation-permissions. Q03 distinguishes them from unverified backend authorization; Q06 tracks master values and amount semantics. See [the clarification register](../../baseline/clarifications.md).
