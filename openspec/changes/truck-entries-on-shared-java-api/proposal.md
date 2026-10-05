# Proposal

## Why

The Spare Parts, Summon Entry and Spot Sale screens called .NET `TruckSparePartsAppController`.
Backend change `share-truck-entries-api` ports its lists and the spare parts save as shared Java
APIs.

## What Changes

| Screen | Before (.NET) | Now (shared Java) |
|---|---|---|
| Spare Parts view | `SelectSpareParts` | `GET /api/truck-spare-parts/entries` |
| Spare Parts add (image + PDF) | `InsertSpareParts` (raw multipart, no token) | `POST /api/truck-spare-parts/entries` (multipart `entry` + `files`, session token) |
| Summon view (admin, maintenance, **driver**) | `SelectSummon` | `GET /api/summons/entries` (a driver gets the truck on their record) |
| Spot Sale view | `SelectSpotSaleEntry` | `GET /api/sport-sale-orders/entries` |
| Summon add (admin, maintenance, **driver**) | `InsertSummon` | `POST /api/summons/entries` (a driver's own truck) |
| Spot Sale add | `InsertSpotSaleEntry` | `POST /api/sport-sale-orders/entries` |

- **New** `TruckEntriesApi` (`lib/core/fleet`), registered in `auth_injection.dart`.
- The three views read the Java fields (`id`, `truckName`, `spareParts`, `amount`, `entryDate`,
  `documentPath`, `summon`, `country`, `vehicleName`, `awbNo`, `port`, `quantity`, `totalWeight`,
  `statusName`).
- The spare parts add sends the truck id, parts, amount and date; the server refuses missing or
  invalid values with a message. Success is the saved id.
- **Removed**: every `TruckSparePartsApp` URL. No screen calls that .NET controller any more.

## Behaviour changes

- A driver's Summon view lists only their truck's summons; it used to list the whole company's.
  This was the owner's decision (2026-10-05).
- Entry dates show as `yyyy-MM-dd` (Java date) instead of .NET's date-time text.
- The Spot Sale view includes entries created later on the to-date.
- A refused spare parts save shows the server's reason, not "Server error".

## Not changed

- Documents still open at `ApiConstants.port + documentPath`. Java writes the same `/Upload/...`
  tree that .NET serves.

## Capabilities

### Modified Capabilities
- `api-integration`: the truck entry lists and the spare parts save use the shared Java APIs.

## Impact

`lib/core/fleet/truck_entries_api.dart` (new), `auth_injection.dart`, `api_constants.dart`, and the
`dashboard/common_tabs/{spareparts,summonentry,spotsaleorder}` repositories, blocs and views. Ships
with backend change `share-truck-entries-api`.
