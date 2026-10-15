## ADDED Requirements

### Requirement: Truck & Driver Details sheet

The Transport and Sales dashboards SHALL show a "Truck & Driver Details" button in the app bar that
opens a screen with a truck picker and a driver picker. The screen SHALL read the chosen truck and
driver from the shared Java `GET /api/truck-driver-details` and show Vehicle Details (Truck No,
Capacity, Seal, Bond No, Bond Exp Date) and Driver Details (Driver Name, NRIC No, Contact No,
Passport No). Truck No SHALL be the head plate and trailer plate as `HEAD /T/TRAILER`, and dates
SHALL show as `dd-MM-yyyy`. The screen SHALL share the sheet as a PDF.

#### Scenario: Truck brings its driver
- **WHEN** the user picks a truck while no driver is chosen, and the truck has a usual driver
- **THEN** that driver is chosen and both blocks are shown

#### Scenario: Share the sheet
- **WHEN** a truck or a driver is shown and the user taps "Download / Share PDF"
- **THEN** a PDF named after the truck and driver opens in the share sheet
