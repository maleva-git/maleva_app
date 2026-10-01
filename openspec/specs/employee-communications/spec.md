# Employee records and communication settings

## Purpose

Describe the employee record, employee email configuration, and Google Review record interfaces provided by the client.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/dashboard/common_tabs/employeemaster/data/employee_repository.dart](../../../lib/features/dashboard/common_tabs/employeemaster/data/employee_repository.dart)
- [lib/features/dashboard/common_tabs/emailinbox/data/emailinbox_repository.dart](../../../lib/features/dashboard/common_tabs/emailinbox/data/emailinbox_repository.dart)
- [lib/features/dashboard/common_tabs/googlereview/data/googlereview_repository.dart](../../../lib/features/dashboard/common_tabs/googlereview/data/googlereview_repository.dart)

## Requirements

### Requirement: Maintain employee records

The employee repository SHALL provide load, save, and delete requests for employee records using the selected company and record context.

#### Scenario: Save employee
- **WHEN** the repository receives an employee save payload
- **THEN** it sends that payload to InsertEmployee.

### Requirement: Load and save employee email data

The email screen repository SHALL load employee choices and load/save email rows with company headers.

#### Scenario: Save email rows
- **WHEN** the email repository is asked to save rows
- **THEN** the client posts the supplied row list to InsertMailMaster with Comid.

### Requirement: Maintain review records

The review repository SHALL provide employee lookup and save, list, and delete operations for its Google Review records.

#### Scenario: Review list
- **WHEN** the repository is asked to load review records
- **THEN** it requests SelectGoogleReview using the provided filters.

## Clarifications

Q06 covers the business meaning of review records and email settings. These API names do not establish access to an external mailbox or direct Google review publication. See [the clarification register](../../baseline/clarifications.md).
