## Why
Backend change `fuel-tank-card-engine` (owner 2026-10-28): the fuel card and engine on / off become fields instead of Remarks text.
## What Changes
- Driver Fuel form: chips **Engine off / Engine on** and **Fuel card** (No card / cash + the most used cards from
  `GET /api/fuel-entries/cards`). Optional; a choice not made is not sent (the server keeps the saved value).
- `FuelEntryModel.cardCode` / `engineOn` (`fromJava`, `toJava` only when chosen); `FuelEntryApi.cards()`.
- Test: driver_fuel_tab_test (4).
