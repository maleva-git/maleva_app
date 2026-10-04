# Proposal

## Why

The fuel screens still called the old .NET `FuelEntryApp` URLs. `LegacyCallAdapter` /
`SharedLookups` answered them from the Java API and rebuilt the .NET rows. That adapter was meant as
a temporary step (change `use-shared-lookup-apis`). The owner's rule (2026-10-02) says that when a
screen is reworked, it reads the Java fields directly and its mapping is dropped.

The shared Java `/api/fuel-entries` (the web's API) already exists and already accepts driver
tokens, limited to the driver's own entries. So **no backend change is needed**.

## What Changes

| Screen | Before (.NET URL, via the adapter) | Now (shared Java) |
|---|---|---|
| Maintenance dashboard → Fuel Entry tab (list, add/edit, delete, next number) | `SelectFuelEntry`, `InsertFuelEntry`, `DeleteFuelEntry`, `MaxFuelEntryNo` | `GET /api/fuel-entries`, `POST /api/fuel-entries`, `DELETE /api/fuel-entries/{id}`, `GET /api/fuel-entries/next-no` |
| Driver → Fuel Entry (add) | `InsertFuelEntry`, `MaxFuelEntryNo` | `POST /api/fuel-entries` (`fStatus` 1), `GET /api/fuel-entries/next-no` |
| Driver → Fuel Entry (list, delete) | `SelectFuelEntry`, `DeleteFuelEntry` (Mobile=1) | `GET /api/fuel-entries` (own truck and driver), `DELETE /api/fuel-entries/{id}?mobile=true` |
| Fuel Difference report tab | `SelectFuelEntry` | `GET /api/fuel-entries` |
| Customer dashboard → fuel section | `SelectFuelEntry` | `GET /api/fuel-entries` |

- **New** `FuelEntryApi` (`lib/core/fuel`), registered in `auth_injection.dart`.
- `FuelEntryModel.fromJava` / `toJava` and `FuelselectModel.fromJava` read the Java camelCase
  fields. Field names are matched without case, using the new `JsonRead.field`. The .NET `fromJson`
  readers are removed. The difference columns are worked out as the adapter did (the web's rule):
  patron minus actual (`DP`), and the server's `diffLiter` / `diffAmount` (`DG`).
- The driver list rows are the Java maps. The list view reads `aliter`, `aAmount` and `saleDate`.
- **Removed**: the four `fuelentryapp/*` adapter mappings, the `SharedLookups` fuel methods, the
  `ApiConstants` fuel URLs, and their tests.

## Not changed

- The look of every screen, its filters, and its default dates.
- The maintenance tab still hides `FStatus = 2` rows.
- The driver form still sends no remarks and no patron or GPS figures.
- The maintenance form's patron, GPS and difference amounts are still worked out on screen. The
  server ignores them and recomputes its own, as it already did through the adapter.

## Capabilities

### Modified Capabilities
- `api-integration`: the fuel screens use the shared Java `/api/fuel-entries` directly.

## Impact

`lib/core/fuel/fuel_entry_api.dart` (new), `lib/core/utils/json_read.dart`,
`lib/core/network/legacy_call_adapter.dart`, `lib/core/lookups/shared_lookups.dart`,
`lib/core/network/api_constants.dart`, `lib/features/auth/auth_injection.dart`,
`dashboard/common_tabs/fuelentry`, `dashboard/common_tabs/fuel`, `custdashboard_bloc`,
`transport/fuelentry`, `transport/models/fuelselect_model.dart`. No backend change.
