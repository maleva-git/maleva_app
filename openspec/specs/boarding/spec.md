# Boarding status and evidence

## Purpose

Describe boarding job selection, status and timestamp updates, image handling, and the follow-up status-mail request.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/boarding/updateboardingdetails/bloc/updateboardingdetails_bloc.dart](../../../lib/features/boarding/updateboardingdetails/bloc/updateboardingdetails_bloc.dart)
- [lib/features/dashboard/common_tabs/jobstatusupdate/data/job_status_update_repository.dart](../../../lib/features/dashboard/common_tabs/jobstatusupdate/data/job_status_update_repository.dart)

## Requirements

### Requirement: Load boarding job details

The boarding flow SHALL load the selected job status and existing boarding images, including a job supplied by a dashboard entry.

#### Scenario: Dashboard prefill
- **WHEN** the boarding flow starts with a job ID and job number
- **THEN** the client loads that job into the form.

### Requirement: Save boarding status and optional times

The boarding form SHALL request an update when a status name is set or a start/end time is enabled, sending null for disabled timestamps.

#### Scenario: Only start time enabled
- **WHEN** the start time is enabled and end time is disabled
- **THEN** the payload contains the parsed start timestamp and a null end timestamp.

### Requirement: Request mail after successful update with images

After a successful boarding update, the client SHALL request status mail when images are present and skip that request when none are present.

#### Scenario: Evidence images present
- **WHEN** the status update reports IsSuccess=true and the form contains images
- **THEN** a separate SendBoardingMail request carries the job, status, company, and boarding image URLs.

## Clarifications

Q07 covers partial success between status update and mail. Recipient selection, actual delivery, and server-side mail behavior require backend confirmation. See [the clarification register](../../baseline/clarifications.md).
