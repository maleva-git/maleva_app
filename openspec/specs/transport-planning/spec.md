# Transport planning

## Purpose

Describe loading, editing, saving, and opening documents for transport planning and its assigned jobs.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/transaction/planning/data/planning_repository.dart](../../../lib/features/transaction/planning/data/planning_repository.dart)
- [lib/features/transaction/planning/bloc/planning_bloc.dart](../../../lib/features/transaction/planning/bloc/planning_bloc.dart)
- [lib/features/transaction/planning/view/add_planning_page.dart](../../../lib/features/transaction/planning/view/add_planning_page.dart)

## Requirements

### Requirement: Search planning records

Transport planning SHALL load records by company, date range, planning search text, and employee filter.

#### Scenario: Planning search
- **WHEN** the user requests planning records
- **THEN** the client posts the filter body to SelectPLANING and interprets the returned list.

### Requirement: Edit assignments and save planning details

The planning editor SHALL let users update truck/driver assignments, pickup/delivery dates and addresses, and submit the assembled planning master/detail payload.

#### Scenario: Save edited rows
- **WHEN** the user saves loaded planning records
- **THEN** the request includes each master and its SaleDetails with truck, driver, dates, addresses, package, weight, and remarks.

### Requirement: Open generated planning document

The planning flow SHALL request a planning document with the selected record and company, then open the returned URL when the response indicates success.

#### Scenario: Document available
- **WHEN** the document response reports IsSuccess=true
- **THEN** the returned document URL is launched in the browser.

## Clarifications

Q07 covers save responses treated as success when merely nonempty and errors treated as empty search results. Backend assignment constraints remain unverified. See [the clarification register](../../baseline/clarifications.md).
