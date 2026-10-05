# Proposal

## Why

All the app's calls now go to the shared Java API. Code that only served the old .NET API, or that
nothing uses any more, should go, so that the app holds only what the Java implementation needs.

## What Changes

- **Removed 15 unused models**, with their exports in `lib/core/models/model.dart`:
  `company_model`, `driver_view_model`, `employee_type_model`, `menu_master_load_model`,
  `menureturn`, `petty_cash_details_model`, `petty_cash_master_model`, `product_view_model`,
  `query_response`, `review_model`, `subscription_key` (`core/models/shared`),
  `auth/models/appuser_model`, `dashboard/models/dashboard_model`,
  `operations/models/forwarding_salary_model`, `transaction/salesorder/models/sale_order_model`.
- **Removed `MasterApi.getWarehouses`**, which had no callers, and its unused imports.
- Comments that still named the removed .NET clients (`ApiClient`, the .NET host) are reworded.

No behaviour changes: nothing called the removed code. Firebase, notifications and Bluetooth stay,
because the Java backend sends the FCM pushes and printing is local to the phone.

## Capabilities

### Modified Capabilities
- `api-integration`: the app holds no .NET API code.

## Impact

`lib/core/models/**`, `lib/core/network/api_services/master_api.dart`,
`lib/core/network/java_api_client.dart`, three bloc comments.
