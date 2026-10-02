## 1. Shared

- [x] 1.1 `ApiFailure` (with `LegacyApiException` extending it) and `JavaResponse.data/fromDio`; `describeError` in both features reads `ApiFailure`. Verify: unit tests for an ApiResponse success, `IsSuccess` false, an `ApiError` with details, and a timeout.

## 2. IR

- [x] 2.1 `IrRemoteDataSource` on `JavaApiClient` with the mapping in the design; `IrJson` reads and writes Java's camelCase; `documentRemarks` (edited on the web) is carried through an edit so the app never clears it. Verify: data-source tests with a fake adapter for every call (path, query, body, parsed result) and a refused save.
- [x] 2.2 Injection uses `JavaApiClient`. Verify: the existing IR bloc tests pass unchanged.

## 3. Truck Location

- [x] 3.1 `TruckLocationRemoteDataSource` on `JavaApiClient`; `TruckLocationJson` in camelCase. Verify: data-source tests for week, save and order, and a 400 with a message.
- [x] 3.2 Injection uses `JavaApiClient`. Verify: the existing Truck Location tests pass unchanged.

## 4. Checks

- [x] 4.1 Analyzer and full test suite. Verify: no new failures.
- [ ] 4.2 On a test environment, list, add, edit and delete an IR and save a truck week from the app; check the same rows on the web screens. Keep open until a test environment is available.
