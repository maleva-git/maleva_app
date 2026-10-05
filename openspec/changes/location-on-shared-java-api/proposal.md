# Proposal

## Why

The Location picker (Add Enquiry TR's origin and destination) called .NET
`LocationApp/SelectLocation` (`LocationServices.SelectLocation`). Java already has the same read,
declared in React's endpoints:

| .NET | Java (existing) |
|---|---|
| `SelectLocation?Comid` → `select Id, Location, Active from LocationMaster where CompanyRefId = @Comid and Active != 2` | `GET /api/location-master/company/{companyId}/active` → `findByCompanyRefIdAndActiveNot(companyId, 2)` |

So **no backend change** is needed.

## What Changes

- **New** `LocationApi` (`lib/core/lookups`), registered in `auth_injection.dart`.
- **Response shape.** This controller answers the `agentcompany` wrapper `{success, statusCode, message, data}`, not the usual `ApiResponse`. Per rule 2 the backend is not changed for the app; `LocationApi` reads that shape as it is.
- **`LocationModel.fromJava` reads `id`, `companyRefId`, `location` and `active`.** The .NET `fromJson` is removed.
- **`LegacyApiRepository.SelectLocation` fills `AppGlobals.LocationList` from Java**, so the picker is unchanged.
- **Removed:**
  - the unused `MasterApi.getLocations`;
  - `ApiConstants.apiSelectLocation`.

  The network tests now use `apiPostFile` as their example of a call still on .NET.

## Noted, not changed

`LocationMasterController` is `@PermitAll` at class level and its other endpoints are not
company-scoped. That is a backend security item, outside this change.

## Capabilities

### Modified Capabilities
- `api-integration`: the Location picker uses the shared Java location list.

## Impact

`lib/core/lookups/location_api.dart` (new), `location_model.dart`, `legacy_api_repository.dart`,
`api_services/master_api.dart`, `api_constants.dart`, `auth_injection.dart` and the network tests. No
backend change.
