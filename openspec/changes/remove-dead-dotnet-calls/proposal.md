# Proposal

## Why

`LoginApp/SelectLoginUser` was the last `/api/*App/*` .NET address in `ApiConstants`, but nothing
called it:
- `LegacyApiRepository.SelectUser` had no callers;
- `AppGlobals.UserList` was never read;
- `UserLoginModel` was used only there.

Under the owner's rule there is nothing to migrate, so it is removed. The same check found seven more
.NET addresses with no callers.

## What Changes

- **Removed:**
  - `LegacyApiRepository.SelectUser`, `AppGlobals.UserList` and `features/auth/models/user_login_model.dart` (with its export in `core/models/model.dart`);
  - `ApiConstants.apiSelectUser`;
  - the unused `apiUploadPdfFile`, `apiEditPassword`, `apiGetReceipt`, `apiGetReceiptView`, `apiPettyCashview`, `apiLicenseViewRecords` and `apiInsertAppLog`.
- **Network tests.** `java_route_test` and `legacy_call_adapter_test` needed a .NET-host address to prove such a URL stays on the legacy client. They now use a literal example (`/api/LegacyApp/Example`), not an app constant.
- **What remains in `ApiConstants`:** only the lookup addresses that `LegacyCallAdapter` answers from Java (customers, job types and statuses, agents, agent companies, products, addresses, trucks, drivers).

## Still on .NET (found while checking; not in this change)

- **`transport/updatertidetails/view/add_rti_page.dart`** (Add / Edit RTI) calls .NET **web** routes on the .NET host directly: `/RTI/EditRTI`, `/RTI/MaxRTINo`, `/RTI/SearchJobNo`, `/RTI/RTIView` with `/Reports/ReportViewer.aspx`, `/RTI/ReviseRTI`, `/RTI/DeleteRTI` and `/RTI/InsertRTI`. These are not `/api/` paths, so earlier counts missed them. They are the next migration.
- **Image and document links** are built as the .NET host plus `/Upload/...`. These are file links into the shared Upload tree, not API calls.

## Capabilities

### Modified Capabilities
- `api-integration`: no unused .NET addresses remain in the app.

## Impact

`legacy_api_repository.dart`, `app_globals.dart`, `core/models/model.dart`, `api_constants.dart`,
`user_login_model.dart` (deleted) and the two network tests. No backend change.
