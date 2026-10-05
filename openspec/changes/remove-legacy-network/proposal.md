# Proposal

## Why

After the last lookup moved to Java (`driver-lookups-on-shared-java-api`), no screen sends anything
through the .NET client code any more. A scan found:
- no `/api/*App/*` path;
- no `ApiClient`, `apiAllinone*`, `post` or `postList` call outside the network layer;
- no direct `DioClient` use.

The plumbing was dead code that could still quietly send a call to .NET if someone used it again.

## What Changes

- **Deleted:**
  - `lib/core/network/dio_client.dart`: the legacy .NET Dio client, and its DI registration;
  - `lib/core/network/api_client.dart`: the static `ApiClient` (`postRequest`, `getString`);
  - `lib/core/network/java_route.dart`: the URL router, with nothing bridged since 2026-10-02;
  - `lib/core/network/legacy_json_transport.dart`: `JsonTransport`, `ExistingHttpTransport`, `LegacyArrayTransport`;
  - `lib/core/network/legacy_api_exception.dart`, used only by tests.
- **`LegacyApiRepository`** keeps only the picker helpers (`SelectCustomer`, `SelectTruckList`, ...), which call the typed Java APIs. It now takes no arguments. Its HTTP plumbing (`post`, `postList`, `apiAllinone*`, `apiGetString`, `_routedPost`, `_dioFor`, the list/map helpers) is removed.
- **`StockUpdateRepository`** loses its unused `transport` parameter.
- **Tests:**
  - `transport_contract_test.dart` and `java_route_test.dart` are removed with their code;
  - `session_contract_test.dart` closes the Java client;
  - the IR tests use `ApiFailure` instead of the removed `LegacyApiException`;
  - the legacy-exception case is dropped from `java_response_test.dart`.

## Kept

- **`ApiConstants.port` / `AppGlobals.port`:** the .NET host, still used for `/Upload/...` file links on six screens. These are files, not API calls. Where they point once .NET is retired is open.
- **`LegacyFeatureContext`:** a session helper (company, employee, driver from preferences), not network code.
- **`certificate_policy.dart`** (`HttpOverrides`): it applies to every HTTPS call, Java included.

## Behaviour changes

None. Nothing called the removed code.

## Capabilities

### Modified Capabilities
- `api-integration`: the app holds no .NET API client; every call goes through a typed shared-Java client.

## Impact

`lib/core/network/*` (5 files deleted, `legacy_api_repository.dart` reduced), `core/di/injection.dart`,
`stockupdate/data/stock_update_repository.dart`, and the network, session and IR tests. No backend change.
