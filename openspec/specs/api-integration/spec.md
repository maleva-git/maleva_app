# API transport and response handling

## Purpose

Describe the distinct client HTTP conventions, common file upload behavior, and structured response handling used by MALEVA.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/core/config/app_config.dart](../../../lib/core/config/app_config.dart)
- [lib/core/network/api_constants.dart](../../../lib/core/network/api_constants.dart)
- [lib/core/network/api_client.dart](../../../lib/core/network/api_client.dart)
- [lib/core/network/dio_client.dart](../../../lib/core/network/dio_client.dart)
- [lib/core/network/legacy_api_repository.dart](../../../lib/core/network/legacy_api_repository.dart)
- [lib/core/network/legacy_api_exception.dart](../../../lib/core/network/legacy_api_exception.dart)
- [lib/features/ir_report/data/datasources/ir_remote_data_source.dart](../../../lib/features/ir_report/data/datasources/ir_remote_data_source.dart)
- [lib/features/truck_location/data/datasources/truck_location_remote_data_source.dart](../../../lib/features/truck_location/data/datasources/truck_location_remote_data_source.dart)

## Requirements

### Requirement: Preserve endpoint-specific wire contracts

The client SHALL use the method, endpoint spelling, query names, body keys, and response interpretation implemented by each integration rather than infer HTTP methods from action names.

#### Scenario: Incident selection
- **WHEN** the client selects incident reports
- **THEN** it uses POST with the search body even though the endpoint reads records.

#### Scenario: Truck location save
- **WHEN** the client saves a week
- **THEN** the JSON contains CompanyRefId, UserRefId, WeekStart, Cells, and DoneTicks.

### Requirement: Use client-specific authentication headers

The shared HTTP client SHALL add Bearer authorization, Userid, and Profile when its token is nonempty; the Dio interceptor SHALL instead add a Token header when its session token is nonempty.

#### Scenario: No HTTP token
- **WHEN** the shared HTTP client has no stored token
- **THEN** its default headers contain JSON content type without those token-dependent headers.

#### Scenario: Additional headers
- **WHEN** a caller supplies extra shared-HTTP headers
- **THEN** those values are merged after the default headers.

### Requirement: Report shared HTTP failures

The shared JSON HTTP client SHALL enforce its 30-second request timeout and map 401, 406, and server error statuses to its configured exception messages.

#### Scenario: Concurrent login status
- **WHEN** the shared HTTP response has status 406
- **THEN** the client raises its already-logged-in-on-another-device message.

#### Scenario: Empty successful body
- **WHEN** the shared HTTP response has status 200 and an empty body
- **THEN** it returns an empty list.

### Requirement: Upload files with storage metadata

Common upload helpers SHALL use multipart POST requests and pass company, record, folder, filename, and subfolder metadata required by their call path.

#### Scenario: Shared file helper
- **WHEN** the shared file/PDF helper uploads a file
- **THEN** it uses a MyFiles0 part and its 60-second upload timeout; other upload paths can differ.

## Clarifications

Q03, Q04, Q07 and Q12 cover authorization, inconsistent transport/error semantics, and certificate handling. See baseline/api-interactions.md for the integration matrix and endpoint inventory. See [the clarification register](../../baseline/clarifications.md).
