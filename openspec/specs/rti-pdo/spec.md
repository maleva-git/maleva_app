# RTI records and PDO verification

## Purpose

Describe RTI record selection, document retrieval, proof images, and multipart PDO verification requests.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/features/dashboard/common_tabs/pdo/data/pdo_repository.dart](../../../lib/features/dashboard/common_tabs/pdo/data/pdo_repository.dart)
- [lib/features/dashboard/common_tabs/rtiview/data/rtiview_repository.dart](../../../lib/features/dashboard/common_tabs/rtiview/data/rtiview_repository.dart)
- [lib/features/dashboard/common_tabs/rtistatus/data/rti_status_repository.dart](../../../lib/features/dashboard/common_tabs/rtistatus/data/rti_status_repository.dart)
- [lib/features/transport/updatertidetails/bloc/updatertidetails_bloc.dart](../../../lib/features/transport/updatertidetails/bloc/updatertidetails_bloc.dart)

## Requirements

### Requirement: Filter RTI records

RTI/PDO selection SHALL include company, date range, driver, truck, employee, and search values where provided by its caller.

#### Scenario: PDO search
- **WHEN** the PDO repository is called with selected filters
- **THEN** the SelectRTI request contains those query parameters.

### Requirement: Submit proof with selected details

PDO verification SHALL post the receipt payload and company as multipart fields and attach available selected-detail images by detail ID.

#### Scenario: Details with photos
- **WHEN** checked details include image files
- **THEN** the request contains objReceipt JSON, Comid, and file parts named Files_<detail ID>.

#### Scenario: HTTP response
- **WHEN** the multipart request completes
- **THEN** the repository reports success only when the HTTP status is 200; application-level envelope checks are not performed there.

### Requirement: Retrieve RTI document and status evidence

The RTI flows SHALL request a generated document for the selected RTI and support fetch/upload/delete of status images and a status-mail request.

#### Scenario: Document response
- **WHEN** the RTI document response indicates success
- **THEN** the update-RTI flow opens the returned URL.

## Clarifications

Q06 covers RTI/PDO business terminology and screen reachability; Q07 covers server acceptance and mail delivery guarantees. See [the clarification register](../../baseline/clarifications.md).
