# Proposal

## Why

The product picker (`mastersearch/Product.dart` through `LegacyApiRepository.SelectProductList`) still
posted the old .NET address `ItemApp/GetProductList`. `LegacyCallAdapter` answered it from Java in the
.NET `ProductModel` row shape. Under rule 2 it moves to the Java fields.

## What Changes

- **New** `ProductApi` (`lib/core/lookups`), registered in `auth_injection.dart`. It calls `GET /api/item-masters/company/{companyId}/products`, which answers the list itself: `{id, productName, productCode, saleRate, purRate, mrp}`, the company's active products by name.
- **`ProductModel.fromJava`** reads those fields, with every price as a number. Java has no print name, wholesale rate, GST, category or image, so those are '' / 0, as the adapter gave them. The .NET `fromJson` is removed.
- **`SelectProductList`** fills `AppGlobals.ProductList` from `ProductApi`.
- **Removed:**
  - the adapter entry `itemapp/getproductlist`;
  - `SharedLookups.products` and its now-unused `_num` helper;
  - the products part of the shared lookups test;
  - `ApiConstants.apiGetProductList`.

## Behaviour changes

None intended. The same endpoint and order. A failed load is logged, as before.

## Left on the adapter

Addresses (2), drivers, and trucks (3: list, details, save).

## Capabilities

### Modified Capabilities
- `api-integration`: the product picker reads the shared Java API directly.

## Impact

`lib/core/lookups/{product_api,shared_lookups}.dart`, `product_model.dart`, `legacy_api_repository.dart`,
`legacy_call_adapter.dart`, `api_constants.dart`, `auth_injection.dart`, the lookup and adapter tests. No
backend change.
