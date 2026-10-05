# Proposal

## Why

The address pickers still posted the old .NET addresses `AddressApp/SelectDistinctAddress` (names) and
`AddressApp/SelectAddress` (search). `LegacyCallAdapter` answered them from Java in .NET row shapes.
Under rule 2 they move to the Java fields.

## What Changes

- **New** `AddressApi` (`lib/core/lookups`), registered in `auth_injection.dart`. Both endpoints answer `{ok, message, data, count}`, read as they are (rule 2).
  - `names()`: `GET /api/addresses/company/{companyId}/active`, distinct names sorted without case, as before.
  - `search(keyword)`: `GET /api/addresses/company/{companyId}/search?keyword`, `{id, name, address, phone, active}`. The keyword is trimmed.
- **`AddressDetailsModel.fromJava`** reads those fields. The .NET `fromJson` is removed.
- **Callers moved:**
  - the Address picker (`mastersearch/AddressList.dart`);
  - Sales Order add: the address names, plus the three pickup / delivery / warehouse address fills.
- **Sale Order details** fetched the address names but never read them, so that request is removed.
- **`SalesOrderAddRepository`** no longer uses the legacy `DioClient` or the session, because every list it reads is now a shared Java API. Its constructor and DI registration are updated.
- **Removed:**
  - the two adapter entries;
  - `SharedLookups.addressNames` / `addresses` and their test;
  - `ApiConstants.apiSelectAddressList` / `apiSelectAddressDetails`.
- **Adapter test:** the legacy-DioClient test now uses the truck list (`type`), still on the adapter.

## Behaviour changes

- Sale Order details makes one request fewer when it opens.
- A failed address load carries the server's message.

## Left on the adapter

Drivers, and trucks (3: list, details, save).

## Capabilities

### Modified Capabilities
- `api-integration`: the address pickers read the shared Java APIs directly.

## Impact

`lib/core/lookups/{address_api,shared_lookups}.dart`, `address_details_model.dart`,
`mastersearch/AddressList.dart`, the sales order add (repository, view) and sale order details features,
`legacy_call_adapter.dart`, `api_constants.dart`, `core/di/injection.dart`, `auth_injection.dart`, the
lookup and adapter tests. No backend change.
