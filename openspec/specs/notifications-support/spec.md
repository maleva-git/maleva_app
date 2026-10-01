# Notifications and support diagnostics

## Purpose

Describe Firebase notification presentation and the client support-log upload workflow.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/main.dart](../../../lib/main.dart)
- [lib/core/firebase/local_notification_service.dart](../../../lib/core/firebase/local_notification_service.dart)
- [lib/features/troubleshoot/data/applog_api.dart](../../../lib/features/troubleshoot/data/applog_api.dart)
- [lib/features/troubleshoot/bloc/troubleshoot_bloc.dart](../../../lib/features/troubleshoot/bloc/troubleshoot_bloc.dart)
- [lib/core/logging/app_logger.dart](../../../lib/core/logging/app_logger.dart)

## Requirements

### Requirement: Present foreground notifications

For a supported foreground notification payload, the client SHALL display its title and body through local notifications and attempt to include a supplied platform image.

#### Scenario: Notification arrives
- **WHEN** the foreground Firebase listener receives a message with notification content
- **THEN** the local notification presentation routine is called.

### Requirement: Request notification permission

The client SHALL request Android notification permission through the local-notification plugin and iOS alert/sound permission with badges disabled in its initialization flow.

#### Scenario: iOS setup
- **WHEN** notification presentation is configured on iOS
- **THEN** alert and sound are enabled and badge presentation is disabled in that configuration.

### Requirement: Upload support log file

The support-log uploader SHALL write a temporary text file containing employee/company metadata, version, platform, navigation history, errors, and optional user note, then upload it to the common file service.

#### Scenario: Support upload
- **WHEN** a report is submitted to the uploader
- **THEN** a multipart POST to UploadFile2 includes the log and Troubleshoot folder metadata.

#### Scenario: Upload finishes or fails
- **WHEN** the upload attempt exits its try/catch
- **THEN** the uploader deletes its temporary file if it exists and rethrows caught failures.

## Clarifications

Q10 covers notification tap routing and data-only payloads; Q11 covers diagnostic coverage, retention, and logging behavior. No live notifications or logs were sent during baseline setup. See [the clarification register](../../baseline/clarifications.md).
