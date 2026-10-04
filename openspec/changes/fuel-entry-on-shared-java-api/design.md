# Design

## FuelEntryApi

`FuelEntryApi(Dio, {companyId})`, the same pattern as `JobOrderApi`. All calls carry the Java session
token, and a failure throws `ApiFailure` with the server's message.

| Method | Call |
|---|---|
| `list(fromDate, toDate, truckId, driverId)` | `GET /api/fuel-entries?companyRefId&fromDate&toDate[&truckRefId][&driverRefId]`; answers `Data1.items` |
| `nextNumber()` | `GET /api/fuel-entries/next-no?companyRefId` |
| `save(entry)` | `POST /api/fuel-entries` with the `FuelEntrySaveRequest` fields plus `companyRefId` |
| `delete(id, mobile)` | `DELETE /api/fuel-entries/{id}?companyRefId&mobile` |

Dates are cut to `yyyy-MM-dd`, as the adapter did. An empty date is not sent.

## Driver limits

These come from the server (`FuelEntryController` and its driver policy), not the app. A driver
token's list is limited to the driver's own entries. A save is stamped with the driver's truck and
the app flag. A delete must be one of the driver's own app entries. The app still sends its truck
and driver filter, as it did before.

## Field reading

Jackson may write Lombok names such as `aAmount` or `cNumberDisplay` in another case. So the models
read through `JsonRead.field`, which matches the exact name first and then ignores case.
