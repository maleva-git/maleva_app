# Proposal

## Why

The HR Admin dashboard's driver License tab called .NET `DriverApp/SelectDriver`
(`DriverServices.SelectDriver`). Java already has its port, `GET /api/driver-masters/search`, which
React's driver list uses, so **no backend change** is needed.

| .NET | Java (existing) |
|---|---|
| `SelectDriver?Comid&Startindex=0&PageCount=100&Keyword=&Column=` | `GET /api/driver-masters/search?companyId&startIndex=0&pageCount=100&keyword=&column=All` |

The Java search keeps .NET's filters:
- company;
- not deleted (`Active != 2`);
- keyword by DriverName, MobileNo or Id;
- paging by id;
- the account code from `AccountsGroupMaster`.

It uses a LEFT join, so a driver without an account group is still listed; .NET's inner join dropped them.

## What Changes

- **New** `DriverApi` (`lib/core/fleet`), registered in `auth_injection.dart`. It answers the search's `items`.
- **`LicenseViewModel.fromJava` reads the Java driver:** `id`, `driverName`, `licenseNo`, `licenseExp`, `joiningDate`, `accountCode`, `active`, `gdlNo`, `gdlExp`, `mobileNo`, `email`. The .NET `fromJson` is removed.
- **The licence expiry warnings read the Java date.** Java sends `yyyy-MM-dd`, and the warnings ("expired" and "expiring within 30 days") parsed only .NET's `MM/dd/yyyy HH:mm:ss`, so they would have stopped showing.
- **Removed:** `ApiConstants.apiDriverViewRecords`. The network tests now use `apiSelectLocation` as their example of a call still on .NET.

## Behaviour changes

- **Drivers without an account group now appear.**
- **The list is ordered by driver id.** .NET re-sorted the page by created date.

## Capabilities

### Modified Capabilities
- `api-integration`: the License tab uses the shared Java driver search.

## Impact

`lib/core/fleet/driver_api.dart` (new), `license_view_model.dart`,
`dashboard/common_tabs/license/{data,view}`, `api_constants.dart`, `auth_injection.dart` and the network
tests. No backend change.
