# Design

## Source followed
- **Web form**: `maleva-front-end/src/features/levi-entry/leviEntryConfig.ts` (folder `LeviEntry`, number `LE…`),
  behaviour in `features/pass-entry/pages/PassEntryFormPage.tsx`, `api/passEntryApi.ts`, `types/passEntry.ts`,
  `model/passLinkOptions.ts` (enter `IN`/`OUT`, exit `1ST LINK`/`2ND LINK`).
- **Java API**: `maleva-backend/.../module/fleet/controller/LeviEntryController.java` (`/api/levi-entries`, routes in
  `AbstractPassEntryController`), `service/impl/AbstractPassEntryService.java` + `LeviEntryServiceImpl.java`
  (`SP_LeviEntry`, sequence `LeviEntry`, prefix `LE`). Save body `PassEntrySaveRequest`: `id` (absent/0 = new),
  `companyRefId`, `truckRefId`, `driverRefId`, `rtiRefId` (all required), `employeeRefId`, `saleDate` (`yyyy-MM-dd`),
  `amount` (≥ 0), `remarks` (≤ 2000), `enterLink`, `exitLink`. Answer `ApiResponse` `{IsSuccess, Data1}` with
  `PassEntryDetailDto` (`id`, `cNumberDisplay` — Jackson may write `cnumberDisplay`, read without case).
- Truck and driver lists are the web's (`truckApi.getTruckCombo`, `driverApi.getDriverCombo`): name = `accountName`
  or `truckName`; driver name = `accountName`, else `driverName-mobileNo`, else `driverName`; drivers active only and
  sorted by name, as the web filters.

## Layout
One page (the levy is one short record, no lines): a number banner, a **Levy** panel (date, truck, driver, RTI,
enter link, exit link), an **Amount** panel (amount, remarks), a **Files** panel (saved files on edit with
`RecordFilesGrid`, new photos with Camera / Gallery), a bottom bar with the amount and Save. Choices use
`PickField` / `TextPickField` (searchable sheet); enter and exit link have a "Not set" choice (sent as absent, as the
web sends `undefined`). On edit, a truck / driver / RTI no longer in the list is kept with its saved name (web does the same).

## Rules (web order)
Choose the truck → Choose the driver → Choose the RTI number → Type the amount → amount not below zero → remarks at
most 2000 letters. Save asks to confirm, then `POST /api/levi-entries`; photos are uploaded with
`AttachmentsApi.add(folder: 'LeviEntry', recordId: saved id)`. If the upload fails the levy stays saved and the
message says so. Employee id = signed-in employee (`AppPreferences.getEmpRefId`), omitted when 0, as the web.

## Differences from the web
- The web stays on a blank form after saving; the app closes the page with `true` (the caller reloads).
- Push to Payment Voucher, file delete, the list and the printed report stay on the web.

## Risks
- `/api/levi-entries` is `@PermitAll` with the company from the request (existing gap; not changed here).
