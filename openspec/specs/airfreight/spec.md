# Air freight job updates

## Purpose

Describe selecting an air freight job and updating its status, air waybill number, and associated evidence in the client.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/airfreight/updateairfreight/bloc/airfreight_bloc.dart](../../../lib/features/airfreight/updateairfreight/bloc/airfreight_bloc.dart)

## Requirements

### Requirement: Check selected freight job type

When the selected job type can be resolved, the air freight update flow SHALL accept the configured AIR FRIEGHT IMPORT or AIR FRIEGHT EXPORT names and reject other resolved types.

#### Scenario: Wrong resolved type
- **WHEN** the job type lookup resolves to another name
- **THEN** the flow reports the type mismatch instead of loading it as an air freight job.

### Requirement: Submit freight status and waybill

The air freight form SHALL submit sale-order ID, company, job number, employee reference, status ID, and AWBNO to the air freight update endpoint.

#### Scenario: Freight update succeeds
- **WHEN** the update response reports IsSuccess=true
- **THEN** the form emits success and resets.

## Clarifications

Q06 covers the exact misspelled job-type names and behavior when the type is unresolved; backend acceptance and status transition rules are unverified. See [the clarification register](../../baseline/clarifications.md).
