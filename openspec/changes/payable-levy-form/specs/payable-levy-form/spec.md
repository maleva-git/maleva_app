## ADDED Requirements

### Requirement: Levy form saves as the web
The levy form SHALL save with `POST /api/levi-entries` and the web's body (`companyRefId`, `truckRefId`,
`driverRefId`, `rtiRefId`, `saleDate` as `yyyy-MM-dd`, `amount`, and `id`, `employeeRefId`, `remarks`, `enterLink`,
`exitLink` only when set). It SHALL refuse, listing the reasons in the web's order: no truck, no driver, no RTI
number, no amount, an amount below zero, remarks over 2000 letters. After a successful save the page SHALL close
answering `true`.

#### Scenario: Missing choices
- **WHEN** Save is pressed on a new levy with nothing chosen
- **THEN** the app lists "Choose the truck", "Choose the driver", "Choose the RTI number", "Type the amount" and
  nothing is sent

#### Scenario: New levy saved
- **WHEN** truck, driver, RTI and amount 25 are given and Save is confirmed
- **THEN** the body has no `id`, `amount` 25 and today's date, and the page closes with `true`

### Requirement: Levy edit keeps its record
Editing a levy SHALL load `GET /api/levi-entries/{id}`, show its saved number, choices (with the saved name when the
choice is no longer in the list), links, amount and remarks, list its files from folder `LeviEntry`, and save with
the same `id`.

#### Scenario: Edit saved with its id
- **WHEN** levy 41 is opened, its amount changed and saved
- **THEN** the body carries `id` 41 and the new amount

### Requirement: Levy photos
The form SHALL let the user add photos (camera or gallery) and SHALL upload them to folder `LeviEntry` against the
saved levy id after the save succeeds. A failed upload SHALL NOT undo the save and SHALL be reported.

#### Scenario: Upload fails
- **WHEN** the levy is saved and the photo upload fails
- **THEN** the message says the levy is saved but the files did not upload

### Requirement: Levy form fits a phone
The form SHALL show without overflow on a 360 px wide phone, with every choice in a drop-down box.

#### Scenario: Narrow phone
- **WHEN** the form opens at 360 px width
- **THEN** no layout overflow is reported
