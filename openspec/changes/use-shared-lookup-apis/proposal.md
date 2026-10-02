# Proposal

## Why

The owner decided on one Java API per feature, shared by the web and the app (2026-10-02). The
app's lookups (truck, driver, customer, address, job type and steps, job status, agent, agent
company, product), License Update's truck read and save, and Fuel Entry went to a Java bridge
that repeated the web APIs' SQL; a new column or a fixed rule would reach one client only. About
60 live call sites read these lists through five HTTP helpers into twelve models.

## What Changes

- **New** `SharedLookups`: calls the web's Java APIs (`/api/truck-combo`, `/api/driver-combo`,
  `/api/customers/options`, `/api/addresses/...`, `/api/job-type-master/...`,
  `/api/job-status-master/...`, `/api/agents/select-all`, `/api/agent-companies/...`,
  `/api/item-masters/.../products`, `/api/truck-masters/search|process`, `/api/fuel-entries`)
  and answers in the row shape the app's models read. Their different wrappers and their 404/204
  for an empty list are handled there.
- **New** `LegacyCallAdapter`: the shared HTTP helpers answer the old .NET lookup and fuel calls
  from `SharedLookups`, so call sites, models and screens stay unchanged; a refusal reads like the
  .NET one. IR's pickers call `SharedLookups` directly.
- The bridge list (`JavaRoute.moved`) keeps only `StockApp`.
- Fuel entries save through the web's rules (amounts recomputed, GPS re-matched); a driver's entry
  is stamped on the server (backend change `share-lookup-apis-with-app`).
- Bug fixes found on the way: the driver fuel screen now loads its number; four screens read the
  job-steps answer in its real shape; the RTI driver filter applies; License Update treats a
  driver as a driver (not "admin when no truck"); a driver's transport long-press no longer opens
  Sale Order Add (an office screen whose lists are not open to drivers).
- Dead helpers for these calls removed.

## Capabilities

### Modified Capabilities
- `api-integration`: lookups and fuel entries use the shared Java APIs.

## Impact

`lib/core/lookups`, `lib/core/network` (adapter in `ApiClient`, `LegacyApiRepository`,
`DioClient`), IR data source, five feature fixes. Backend change `share-lookup-apis-with-app`
must be deployed first.
