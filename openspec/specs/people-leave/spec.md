# Leave requests and staff reporting

## Purpose

Describe leave submission and review, applicant filtering, and the associated employee/driver salary reporting interfaces.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/dashboard/common_tabs/driverleave/data/leave_repository.dart](../../../lib/features/dashboard/common_tabs/driverleave/data/leave_repository.dart)
- [lib/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart](../../../lib/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart)
- [lib/features/dashboard/common_tabs/driverleave/view/employee_leave_request_tab.dart](../../../lib/features/dashboard/common_tabs/driverleave/view/employee_leave_request_tab.dart)
- [lib/features/dashboard/common_tabs/driverleave/view/driver_leave_request_tab.dart](../../../lib/features/dashboard/common_tabs/driverleave/view/driver_leave_request_tab.dart)
- [lib/features/dashboard/common_tabs/driverleave/view/admin_leave_approval_tab.dart](../../../lib/features/dashboard/common_tabs/driverleave/view/admin_leave_approval_tab.dart)
- [lib/features/dashboard/common_tabs/salary/data/salary_repository.dart](../../../lib/features/dashboard/common_tabs/salary/data/salary_repository.dart)
- [lib/features/dashboard/common_tabs/driversalary/data/driversalary_repository.dart](../../../lib/features/dashboard/common_tabs/driversalary/data/driversalary_repository.dart)

## Requirements

### Requirement: Filter leave requests

Leave loading SHALL request leave types and leave requests with the selected applicant type/reference and optional date filters.

#### Scenario: Applicant filter
- **WHEN** the caller supplies an applicant reference
- **THEN** the request includes that reference and the company context.

### Requirement: Submit leave request

Leave submission SHALL send applicant, leave type, dates, total days, reason, creator, company, Active=1, and initial StatusRefId=1.

#### Scenario: Successful submission
- **WHEN** SaveLeaveRequest returns IsSuccess=true
- **THEN** the leave flow reports successful submission.

#### Scenario: Submission error
- **WHEN** the repository catches an exception
- **THEN** it returns false and the flow reports failure rather than claiming submission.

### Requirement: Review leave status

Leave review SHALL submit the selected request ID, target status, reviewer, and review remark.

#### Scenario: Review accepted
- **WHEN** UpdateLeaveStatus returns IsSuccess=true
- **THEN** the flow reports that leave status was updated.

### Requirement: Request salary reports

The staff reporting repositories SHALL request boarding salary by employee and driver salary with their respective report filters.

#### Scenario: Salary report load
- **WHEN** a caller requests its salary report
- **THEN** the appropriate repository loads the report rows for its supplied context.

## Clarifications

Q03 covers reviewer authorization; Q06 covers applicant/status definitions, leave entitlement and salary rules, which cannot be established from these client calls. See [the clarification register](../../baseline/clarifications.md).
