## ADDED Requirements

### Requirement: The driver adds fuel in a few taps
The driver dashboard SHALL open on a Fuel tab with one ADD FUEL button. The fuel form SHALL ask only for the date
(default today), litres and amount in RM, with optional remarks, and SHALL refuse to send when litres or amount is
missing or above 1,000 L / RM 5,000. The tab SHALL list the driver's own fills of the chosen month with their totals.

#### Scenario: Driver fills the tank
- **WHEN** the driver taps ADD FUEL, types 250 litres and RM 537.50 and taps SAVE
- **THEN** the form shows "RM 2.15 per litre", the entry is saved for the driver's own truck and appears in this month's list

### Requirement: The driver dashboard shows only the driver's tabs
The driver dashboard SHALL show the tabs Fuel, Maintenance, Truck License, Salary and Driver Leave, and SHALL NOT show
TRANSPORT, SummonEntry or PDO.

#### Scenario: Driver signs in
- **WHEN** a driver signs in
- **THEN** the tab bar shows Fuel, Maintenance, Truck License, Salary, Driver Leave, with Fuel open
