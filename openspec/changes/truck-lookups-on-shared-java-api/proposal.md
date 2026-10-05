# Proposal

## Why

Three truck calls still posted old .NET addresses: `TruckApp/GetTruck` (picker list),
`TruckApp/SelectTruck` (one truck, for License Update) and `TruckApp/InsertTruck` (License Update's
save). `LegacyCallAdapter` answered them from Java and rebuilt the .NET shapes: `TruckDetailsModel` with
`MM/dd/yyyy HH:mm:ss` date text, and the save's .NET field names mapped back to Java. Under rule 2 they
move to the Java fields.

## What Changes

- **New** `TruckApi` (`lib/core/fleet`), registered in `auth_injection.dart`:
  - `combo(type)`: `GET /api/truck-combo`, `{isSuccess, data1}` with `{Id, AccountName}` rows. The Java model names them so, which `GetTruckModel.fromJava` reads.
  - `byId(id)`: `GET /api/truck-masters/search?column=Id`. The Java `TruckMasterDto`, with dates as `yyyy-MM-dd`.
  - `update(id, changes)`: reads the truck and writes the changes over it under the truck's own key spelling, then `POST /api/truck-masters/process`. The web API saves a whole truck, so the rest is kept. A refusal (plain text `Error: …`) is an `ApiFailure` with the reason.
- **License Update** loads the Java truck directly. Each date shows as `yyyy-MM-dd`; one it does not have is shown as today, unticked, as before. It saves its fields and the 12 expiry dates with Java names; an unticked date is cleared, as before. A refused save shows the reason and keeps the form. It used to fail silently.
- **Truck pickers moved:**
  - `LegacyApiRepository.SelectTruckList` (the Truck picker, Planning, Spare Parts, Summons);
  - `MasterApi.getTrucks` (Job Orders, Fuel entry);
  - the IR report, on its own Dio.
- **Removed:**
  - `LegacyApiRepository.EditTruckList`;
  - `TruckDetailsModel.fromJson`;
  - the three adapter entries;
  - `SharedLookups.trucks` / `truckDetails` / `saveTruck` and their date / key helpers and tests;
  - `ApiConstants.apiGetTruckList` / `apiEditTruckDetails` / `apiUpdateTruckDetails`.
- **Adapter tests** use the driver list, the last lookup on the adapter.

## Behaviour changes

- **A refused License Update save shows the server's reason** instead of silently reverting.
- **Dates come straight from the Java truck**, with no round trip through .NET date text.

## Left on the adapter

Drivers (`DriverApp/GetDriver`), the last one.

## Capabilities

### Modified Capabilities
- `api-integration`: truck pickers and License Update read and save trucks on the shared Java API directly.

## Impact

`lib/core/fleet/truck_api.dart` (new), `lib/core/lookups/shared_lookups.dart`, `get_truck_model.dart`,
`truck_details_model.dart`, `legacy_api_repository.dart`, `legacy_call_adapter.dart`, `master_api.dart`,
`api_constants.dart`, `auth_injection.dart`, `transport/licenseupdate/bloc`, the IR report data source,
the lookup, adapter and route tests. No backend change.
