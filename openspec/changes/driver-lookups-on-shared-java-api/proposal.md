# Proposal

## Why

The driver list (`DriverApp/GetDriver`) was the last lookup still posted to a .NET address and answered
by `LegacyCallAdapter`. With it moved, the transition layer that the owner's rule 2 called a step can
go: `LegacyCallAdapter` and `SharedLookups`.

## What Changes

- **`DriverApi.combo(type)`**: `GET /api/driver-combo`, `{isSuccess, data1}` with `{Id, AccountName = "name-mobile"}` rows. The Java model names them so, which `GetTruckModel.fromJava` reads.
- **Callers moved:**
  - `LegacyApiRepository.SelectDriverList` (the Driver picker);
  - `MasterApi.getDrivers` (Fuel entry);
  - the IR report, on its own Dio.
- **Removed: the transition layer.**
  - `lib/core/network/legacy_call_adapter.dart` and `lib/core/lookups/shared_lookups.dart`, with its DI registration;
  - their hooks in `DioClient`, `ApiClient` (`postRequest`, `getString`) and `LegacyApiRepository._routedPost`;
  - `GetTruckModel.fromJson`;
  - `ApiConstants.apiGetDriverList`, the last .NET address. `ApiConstants` now holds only the host (`port`), used for `/Upload/...` file links and the routing checks.
- **Tests:** `legacy_call_adapter_test.dart` and `shared_lookups_test.dart` are removed with their code. `java_route_test.dart` still proves a .NET-host URL is left to the legacy client.

## Behaviour changes

None intended. The app no longer has any code path that turns an old .NET address into a Java call. Every call is a typed shared-Java API.

## Where the migration stands

- The app calls no .NET API: no `/api/*App/*` path is left in `lib/`.
- The only remaining use of the .NET host is image and document links built as host + `/Upload/...`. These are files in the shared Upload tree, not API calls.

## Capabilities

### Modified Capabilities
- `api-integration`: every lookup reads the shared Java API directly; the .NET-shaped adapter is removed.

## Impact

`lib/core/fleet/driver_api.dart`, `get_truck_model.dart`, `legacy_api_repository.dart`, `master_api.dart`,
`dio_client.dart`, `api_client.dart`, `api_constants.dart`, `auth_injection.dart`, the IR report data source,
`legacy_call_adapter.dart` and `shared_lookups.dart` (deleted), and the network, lookup and driver API
tests. No backend change.
