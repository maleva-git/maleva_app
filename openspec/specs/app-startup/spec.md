# App startup and session restoration

## Purpose

Describe how MALEVA initializes its services, restores a saved login, and presents the initial application screen.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/main.dart](../../../lib/main.dart)
- [lib/splash/splashscreen.dart](../../../lib/splash/splashscreen.dart)
- [lib/core/di/injection.dart](../../../lib/core/di/injection.dart)

## Requirements

### Requirement: Initialize application services

The app SHALL attempt to initialize Firebase, local preferences, and dependency registration before displaying its routed application.

#### Scenario: Normal startup
- **WHEN** initialization succeeds
- **THEN** the app displays its routed home and splash flow.

#### Scenario: Initialization exception
- **WHEN** the initialization block throws
- **THEN** the app attempts a bounded support-log upload, removes the native splash in finally, and proceeds to run the application; successful later operation is not guaranteed.

### Requirement: Restore saved credentials

The splash flow SHALL attempt server login when both saved username and password are present, and otherwise open login.

#### Scenario: No saved login
- **WHEN** either saved credential is empty
- **THEN** the login page opens.

#### Scenario: Connection failure during restoration
- **WHEN** the login request throws
- **THEN** the splash shows a connection error popup and stops that startup attempt.

## Clarifications

Q01 and Q02 track restoration inconsistencies; Q11 tracks initialization failure handling. See [the clarification register](../../baseline/clarifications.md).
