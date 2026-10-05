# Design

**GpsApi.** It sends whole days as React does (`from=…T00:00:00`, `to=…T23:59:59`) with
`companyRefId`, and unwraps `Data1`. `GpsApi.display` formats a Java date-time as
`dd/MM/yyyy HH:mm:ss`.

**ExpiryApi.**
- `trucks(truckId, until, …)` and `drivers(driverId, until)` call the `/rows` endpoints.
- Truck Details asks for `until` = today + 5, as before. The maintenance screens ask for one truck
  with no window, as before (.NET `Expdate` null).
- For a driver token the server replaces the truck or driver id with the driver's own.
- `ExpiryApi.legacyDate` writes `yyyy/MM/dd` for the truck views, which compare and format those
  strings.

**Repositories.** They return typed lists. The blocs drop the .NET request bodies and envelope
parsing.
