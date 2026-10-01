# Fleet operations and reports

## Purpose

Describe fuel records, maintenance summaries, vehicle/driver reports, and related fleet record operations exposed by the client.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart](../../../lib/features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart)
- [lib/features/dashboard/common_tabs/maintenance/data/maintenance_repository.dart](../../../lib/features/dashboard/common_tabs/maintenance/data/maintenance_repository.dart)
- [lib/features/dashboard/common_tabs/spareparts/data/spareparts_repository.dart](../../../lib/features/dashboard/common_tabs/spareparts/data/spareparts_repository.dart)
- [lib/features/dashboard/common_tabs/summonentry/data/summonentry_repository.dart](../../../lib/features/dashboard/common_tabs/summonentry/data/summonentry_repository.dart)
- [lib/core/network/api_services/reports_api.dart](../../../lib/core/network/api_services/reports_api.dart)
- [lib/features/transport/licenseupdate/bloc/licenseupdate_bloc.dart](../../../lib/features/transport/licenseupdate/bloc/licenseupdate_bloc.dart)

## Requirements

### Requirement: Load active fuel entries

The dashboard fuel-entry repository SHALL request entries by company and date range and omit rows whose Active or FStatus is 2.

#### Scenario: Excluded fuel row
- **WHEN** the fuel response contains a row marked Active=2 or FStatus=2
- **THEN** that row is omitted from the returned model list.

### Requirement: Save and delete fuel records

The dashboard fuel-entry repository SHALL submit a one-element model list on save and identify the selected record and company on delete.

#### Scenario: Fuel save
- **WHEN** a fuel entry is saved
- **THEN** the client assigns the current company, sends the model list, and treats a nonnull response as success.

### Requirement: Display maintenance summaries

The maintenance repository SHALL expose pending records, date-filtered summary records, and counts/amounts for breakdown, repair, service, and spare-parts categories.

#### Scenario: Maintenance statistics
- **WHEN** statistics rows are returned for the selected dates
- **THEN** recognized category rows populate their corresponding count and amount fields.

### Requirement: Request fleet reports

Fleet report wrappers SHALL submit caller filters to the truck, driver, speeding, fuel-fillings, engine-hours, and driver-salary report endpoints.

#### Scenario: Engine-hours report
- **WHEN** the caller requests the engine-hours report
- **THEN** the client sends its filter body to SelectEngineHours and returns the response rows.

### Requirement: Submit spare parts and summons

Fleet record repositories SHALL provide selection and submission calls for spare parts and summons with their caller-provided record data.

#### Scenario: Submit summon
- **WHEN** the summon repository is asked to submit a record
- **THEN** the client posts the record to InsertSummon.

### Requirement: Update truck license and expiry information

The license-update flow SHALL load the assigned truck when its stored truck reference is nonzero, otherwise allow truck selection, and save truck details with enabled expiry dates or null for disabled dates.

#### Scenario: Disabled expiry date
- **WHEN** a truck update is saved with an expiry checkbox disabled
- **THEN** the corresponding expiry field is null in the submitted truck payload.

#### Scenario: Assigned truck
- **WHEN** the license-update screen starts with a nonzero assigned truck reference
- **THEN** it loads that truck and uses its non-admin form mode; this is not proof of server authorization.

## Clarifications

Q06 covers duplicate fuel/maintenance/license screens and record semantics; Q07 covers nonnull-response success interpretation. Device telemetry collection is not established by these report endpoints. See [the clarification register](../../baseline/clarifications.md).
