# Proposal

## Why

The customer and job type pickers still posted the old .NET addresses: `CustomerApp/GetCustomer` and
`JobTypeApp/SelectJobType`. `LegacyCallAdapter` answered them from Java and turned the rows back into
.NET shapes (`{Id, AccountName}`, `{Id, Name, DFlag, Active}`). The owner's rule 2 calls this a
transition step: move each screen's model to the Java fields and drop its mapping. These two lookups
are the most used of the 13 left, so they move first.

## What Changes

- **New** `CustomerApi` (`GET /api/customers/options`) and `JobTypeApi` (`GET /api/job-type-master/jobtypes/{companyId}`) in `lib/core/lookups`, registered in `auth_injection.dart`.
- **`MasterResponse`** reads these controllers' `{success, statusCode, message, data}` wrapper as it is, per rule 2. `LocationApi` now uses it too. A job-type list answers 404 when a company has none; that is read as an empty list.
- **Model readers:**
  - `CustomerModel.fromJava` reads `id` and `label` (the name with its code, as the picker showed), falling back to `customerName`.
  - `JobTypeModel.fromJava` reads `id`, `name`, `dFlag` and `active`.
  - The .NET `fromJson` readers are removed.
- **Callers moved:**
  - `LegacyApiRepository.SelectCustomer` / `SelectJobType` (the Customer and Job Type pickers);
  - Sales Order add and view;
  - the Inventory report;
  - Spot Sale;
  - Sale Order details, which now looks the names up in the models.
- **Removed:**
  - the adapter entries `customerapp/getcustomer` and `jobtypeapp/selectjobtype`;
  - `SharedLookups.customers` / `jobTypes` and their tests;
  - `ApiConstants.apiSelectCustomer` / `apiSelectJobType`.

## Behaviour changes

None intended. The same Java endpoints, the same labels and the same order. A failed load now carries the server's message.

## Left on the adapter

11 lookup addresses: job statuses (`SelectJobStatus`, `SelectJobAllData`), agents and agent companies, products, addresses (2), trucks (3) and drivers.

## Capabilities

### Modified Capabilities
- `api-integration`: the customer and job type pickers read the shared Java APIs directly.

## Impact

`lib/core/lookups/{customer_api,job_type_api,master_response,location_api,shared_lookups}.dart`,
`customer_model.dart`, `job_type_model.dart`, `legacy_api_repository.dart`, `legacy_call_adapter.dart`,
`api_constants.dart`, `auth_injection.dart`, the sales order add/view, inventory report, spot sale and
sale order details features, and the lookup and adapter tests. No backend change.
