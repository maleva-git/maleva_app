# Design

## Flow

```
screen / bloc  ->  ApiClient | LegacyApiRepository | DioClient   (unchanged call sites)
                      |  LegacyCallAdapter.handles(url)?
                      v
                 SharedLookups  ->  JavaApiClient (session token, refresh on 401)  ->  web Java API
                      |
                      v  rows in the old shape ({Id, AccountName}, {Id, Name, ...}, ...)
```

A handled call never goes to .NET or the bridge. A failure becomes the .NET 500 envelope
(`{IsSuccess: false, Message}`), so each helper's existing error handling applies.

## Mapping

| Old call | Web API | Notes |
|---|---|---|
| TruckApp/GetTruck | GET /api/truck-combo | `{Id, AccountName}` as is |
| TruckApp/SelectTruck (Column=Id) | GET /api/truck-masters/search | dates as .NET's `MM/dd/yyyy HH:mm:ss` text for License Update |
| TruckApp/InsertTruck | POST /api/truck-masters/process | the stored truck with the screen's fields over it |
| DriverApp/GetDriver | GET /api/driver-combo | `name-mobile` |
| CustomerApp/GetCustomer | GET /api/customers/options | `label` as AccountName |
| AddressApp/SelectDistinctAddress | GET /api/addresses/company/{id}/active | distinct names, sorted |
| AddressApp/SelectAddress | GET /api/addresses/company/{id}/search | |
| JobTypeApp/SelectJobType | GET /api/job-type-master/jobtypes/{id} | 404 = none |
| JobTypeApp/SelectJobAllData | POST /api/job-type-master/select-all-data | one-element .NET shape; `Jobid` / `JobMasterRefId` / `JobId` |
| JobStatusApp/SelectJobStatus | GET /api/job-status-master/select/{id}/ | trailing slash; 404 = none |
| AgentApp/SelectAgentAll | POST /api/agents/select-all | `Name` as AgentName; no password |
| AgentCompanyApp/SelectAgentCompany | GET /api/agent-companies/company/{id} | 204 = none; sorted by name |
| ItemApp/GetProductList | GET /api/item-masters/company/{id}/products | missing prices as 0.0 |
| FuelEntryApp/Select/Insert/Delete/MaxNo | /api/fuel-entries | DP = patron - actual, DG = the list's diff; save recomputed on the server |

## Behaviour that changes on purpose

- Fuel amounts are recomputed by the server: DP is patron minus actual (the web's rule; the
  maintenance screen computed actual minus patron).
- A driver cannot save trucks on License Update; a driver's long-press on the transport list does
  nothing.
