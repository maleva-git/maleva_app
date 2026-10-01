# Vessel planning

## Purpose

Describe vessel planning searches, saved planning records, job updates, and generated planning documents in the client.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/transaction/vesselplanning/bloc/vesselplanning_bloc.dart](../../../lib/features/transaction/vesselplanning/bloc/vesselplanning_bloc.dart)
- [lib/features/dashboard/common_tabs/vesselplanningweb/data/vesselplanningweb_repository.dart](../../../lib/features/dashboard/common_tabs/vesselplanningweb/data/vesselplanningweb_repository.dart)
- [lib/features/dashboard/common_tabs/vesselreport/data/vessel_report_repository.dart](../../../lib/features/dashboard/common_tabs/vesselreport/data/vessel_report_repository.dart)

## Requirements

### Requirement: Filter vessel jobs

The web-style vessel planning client SHALL request vessel jobs using date range, ETA type, port search, delivery-done flag, employee, and company context.

#### Scenario: Vessel job search
- **WHEN** the vessel job search is submitted
- **THEN** VESSELPLANINGSearch receives the selected filters in its JSON body.

### Requirement: Manage saved vessel planning

The vessel planning repository SHALL provide requests to save planning rows, load saved planning records, edit a selected record, and delete a selected record.

#### Scenario: Load saved planning
- **WHEN** the saved-planning response contains masters and details in its recognized envelope
- **THEN** the client attaches details to masters using their VESSELPLANINGMasterRefId.

### Requirement: Retrieve vessel planning document

The vessel planning client SHALL request a document for the selected planning number with record and company context.

#### Scenario: Document success
- **WHEN** the document response reports IsSuccess=true
- **THEN** the repository returns its document URL for the caller.

## Clarifications

Q06 covers overlapping vessel screens and entry points. Q07 records optimistic success fallbacks and search errors converted to empty results; no reliable backend success guarantee is inferred. See [the clarification register](../../baseline/clarifications.md).
