## Why
Owner 2026-10-28: the driver does not need the TRANSPORT, SummonEntry and PDO tabs; fuel entry must be easy for a driver.
The driver's fuel entry already uses the shared Java `/api/fuel-entries` (DriverFuelPolicy: the server puts the driver's
own truck, the driver id and FStatus 1 on the row, and numbers it). No backend change.

## What Changes
- Driver dashboard tabs: **Fuel**, Maintenance, Truck License, Salary, Driver Leave (5; were 7). TRANSPORT, SummonEntry and
  PDO removed from the driver's tabs (the screens stay for the roles that use them; the RTI preview and status keep their
  own way in).
- New `DriverFuelTab` (`common_tabs/fuelentry/view/driver_fuel_tab.dart`), first tab: month with ◀ ▶, totals (fills,
  litres, RM), one big **ADD FUEL** button, the driver's own fills of the month (tap to change).
- Short form in a bottom sheet: date (today, up to 30 days back), **litres**, **amount (RM)** — big number fields — the
  price per litre shown, remarks optional. Refused before sending: no litres / amount, litres > 1,000, amount > RM 5,000.
  Saved as the app entry (`aliter`, `aAmount`) through the existing `FuelEntryBloc` / repository.
- Two unused-variable warnings removed from `driver_dashboard.dart`.
