# Proposal

## Why

The RTI screens still called .NET `RTIAppController`, with 8 calls in total. The owner's rule
(2026-10-02) says the app uses the shared Java API and reads its fields. Backend change
`share-rti-operations-api` ports the calls Java lacked. This is **phase 1**. `InsertRTIStatus` waits
for the `SP_RTIStatus` source.

## What Changes

| Screen | Before (.NET) | Now (shared Java) |
|---|---|---|
| RTI View tab: list and PDF | `SelectRTI`, `RTIVIEW` | `GET /api/rti-masters/with-jobs`, `GET /api/rti-masters/{id}/report-ticket` |
| PDO tab: list (admin, maintenance, transport, **driver**) | `SelectRTI` | `GET /api/rti-masters/with-jobs` |
| TransportDB tab: list | `SelectRTI` | `GET /api/rti-masters/with-jobs` |
| Update RTI (driver menu): list and PDF | `SelectRTI`, `RTIVIEW` | the same two |
| RTI Status page: "<status> Done" with photos | `SendStatusMail` | `POST /api/rti-masters/jobs/{id}/status` |
| Forwarding agent: route stops, status | `SelectRTIRouteActivities`, `UpdateRootactivity` | `GET /api/rti-route-activities`, `PUT /api/rti-route-activities/{id}/status` |
| Forwarding Salary: RTI number picker | `SelectRTINo` | `GET /api/rti-masters/company/{id}` |

- **New** `RtiApi` (`lib/core/rti`), registered in `auth_injection.dart`. Its list answers
  `RtiList(masters, details)`, flattening each RTI's jobs.
- `RTIMasterViewModel.fromJava`, `RTIDetailsViewModel.fromJava` and `RtiRouteActivity.fromJava`
  read the Java fields. The .NET `fromJson` readers are removed. Dates are still shown as
  `dd/MM/yyyy`.
- The PDF opens the Java report link: the host plus the answered `Url`. It no longer needs the RTI
  number.
- **Removed**: `LegacyApiRepository.SelectRTIViewList`, `SelectRTIDetailViewList` (it had no
  callers and a broken URL), and the five RTI `ApiConstants` URLs.

## Behaviour changes

- A **driver's** PDO and TransportDB lists now hold only their own RTIs. The server enforces this;
  the driver-dashboard PDO used to load the whole company.
- RTI lists include the whole of the to-date. They used to miss RTIs later on that day.
- The forwarding agent's list leaves out deleted stops and RTIs. "No data" is an empty list, not a
  404.
- A refused status update shows the server's reason.

## Phase 2 (2026-10-05)

- PDO verify and the TransportDB save post to `POST /api/rti-masters/job-statuses`, the Java port
  of `InsertRTIStatus` / `SP_RTIStatus`. It is multipart: `statuses` (Java field names) and
  `photo_<line id>` per photo. **No RTI call goes to .NET any more.**
- Each job line reads its latest status (`statusId`, `active`, `verify`, `imagePath`). PDO and
  TransportDB show what was saved before, and saving again updates that status instead of adding
  another.

## Capabilities

### Modified Capabilities
- `api-integration`: the RTI screens, including the PDO / TransportDB status save, use the shared
  Java RTI APIs.

## Impact

`lib/core/rti/rti_api.dart` (new), `lib/core/models/shared/r_t_i_*_view_model.dart`,
`lib/core/network/legacy_api_repository.dart`, `lib/core/network/api_constants.dart`,
`lib/features/auth/auth_injection.dart`, `dashboard/common_tabs/{rtiview,pdo,transportDB,rtistatus}`,
`dashboard/forwarding_agent_dashboard`, `transport/updatertidetails`. Ships with backend change
`share-rti-operations-api`.
