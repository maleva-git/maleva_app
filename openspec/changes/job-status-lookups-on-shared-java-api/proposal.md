# Proposal

## Why

Two job-status lookups still posted old .NET addresses, which `LegacyCallAdapter` answered from Java in
.NET row shapes:
- `JobStatusApp/SelectJobStatus`: the company's statuses.
- `JobTypeApp/SelectJobAllData`: a job type's steps and status order, as `[{JobTypeDetails, JobStatusDetails}]`.

Several screens then read those rows as raw maps (`s['Status']`, `item['Description']`). Under rule 2 they move to the Java fields.

## What Changes

- **New** `JobStatusApi` (`lib/core/lookups`), registered in `auth_injection.dart`:
  - `statuses()`: `GET /api/job-status-master/select/{companyId}/`, which uses the `{success, data}` wrapper (read by `MasterResponse`). A 404 means none.
  - `steps(jobTypeId)`: `POST /api/job-type-master/select-all-data`, `ApiResponse`. It returns a typed `JobSteps`: `details` (`JobTypeDetailsModel`), `statuses` (`JobAllStatusModel`) and `statusName(status)`. Job type 0 asks nothing; a 404 means none.
- **Model readers:** `JobStatusModel.fromJava`, `JobAllStatusModel.fromJava` and `JobTypeDetailsModel.fromJava` read the Java fields. The .NET `fromJson` readers are removed.
- **Callers moved:**
  - `LegacyApiRepository.SelectJobStatus` / `SelectAllJobStatus`;
  - `MasterApi.getJobStatuses` (Vessel report);
  - Sales Order add and view;
  - Enquiry TR (add and view);
  - Spot Sale, Job Status Update, Stock-in entry and Stock update;
  - Sale Order details, whose status name and field-visibility lookups now use the models instead of map keys.
- **Removed:**
  - the adapter entries `jobstatusapp/selectjobstatus` and `jobtypeapp/selectjoballdata`;
  - `SharedLookups.jobStatuses` / `jobSteps` and their tests;
  - the old map helper `JobSteps.statuses/details` and its test;
  - `ApiConstants.apiSelectJobStatus` / `apiSelectAllJobStatus`.
- **Tidy-up made necessary by the move:** three repositories no longer use the legacy `DioClient` (`EnquiryTrRepository`, `SalesOrderViewRepository`, `StockInEntryRepository`). Its constructor argument and the DI registrations are updated.
- **Adapter test:** the adapter's "legacy DioClient with alias parameters" test now uses the agents lookup (`AgentCompanyRefId`), which still goes through the adapter.

## Behaviour changes

- **Sales Order add no longer keeps another job type's lists.** Picking a job type used to keep the previous type's statuses and steps when the new load came back empty or failed. It now shows the new type's.
- **A failed load carries the server's message.**

## Left on the adapter

7 lookup addresses: agents and agent companies, products, addresses (2), trucks (3) and drivers.

## Capabilities

### Modified Capabilities
- `api-integration`: job statuses and job-type steps are read from the shared Java APIs directly.

## Impact

`lib/core/lookups/{job_status_api,job_steps,shared_lookups}.dart`, `job_status_model.dart`,
`job_all_status_model.dart`, `job_type_details_model.dart`, `legacy_api_repository.dart`,
`legacy_call_adapter.dart`, `api_constants.dart`, `master_api.dart`, `core/di/injection.dart`,
`auth_injection.dart`, the sales order, enquiry TR, spot sale, job status update, stock-in, stock
update and sale order details features, and the lookup and adapter tests. No backend change.
