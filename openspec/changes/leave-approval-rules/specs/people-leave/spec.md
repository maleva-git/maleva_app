## MODIFIED Requirements

### Requirement: Submit leave request

Leave submission SHALL send applicant, leave type, dates, total days, reason, creator, company, Active=1, and initial StatusRefId=1. The total days SHALL be the calendar days from the from-date to the to-date, both counted, and the length shown SHALL be read from the dates and times.

#### Scenario: Successful submission
- **WHEN** SaveLeaveRequest returns IsSuccess=true
- **THEN** the leave flow reports successful submission.

#### Scenario: Submission error
- **WHEN** the server refuses the request (for example overlapping leave)
- **THEN** the flow shows the server's reason rather than claiming submission.

#### Scenario: Submit again after a refusal
- **WHEN** the server refuses a request and the user corrects it and submits again
- **THEN** the second request is sent

#### Scenario: Leave for next week
- **WHEN** an employee requests leave for next week
- **THEN** it is listed in their requests after saving

#### Scenario: Hours on one day
- **WHEN** an employee requests leave from 09:00 to 09:30 on one day
- **THEN** the app sends total days 1 and shows "30 Mins".

### Requirement: Review leave status

Leave review SHALL submit the selected request ID, target status, reviewer, and review remark, SHALL NOT offer review of the signed-in employee's own request, and SHALL reload the list after a refused review.

#### Scenario: Review accepted
- **WHEN** UpdateLeaveStatus returns IsSuccess=true
- **THEN** the flow reports that leave status was updated.

#### Scenario: Own request
- **WHEN** the signed-in employee's own pending request is listed in the approval tab
- **THEN** no Review button is shown.

#### Scenario: Already reviewed
- **WHEN** the server answers that someone else already reviewed the request
- **THEN** the app shows the message and reloads the list.

## ADDED Requirements

### Requirement: Driver leave warning when choosing a driver

The Planning and RTI driver pickers SHALL warn with every pending or approved leave of the driver
today and in the next 3 days, saying when it starts, and SHALL still let the driver be chosen.

#### Scenario: Approved leave tomorrow
- **WHEN** a planner picks a driver with approved leave tomorrow
- **THEN** the driver shows in purple and the warning says "starts tomorrow"
