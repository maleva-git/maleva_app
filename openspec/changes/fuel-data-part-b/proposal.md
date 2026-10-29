# fuel-data-part-b (app) — owner 2026-10-29
- Driver Fuel tab: a receipt photo is required for a new fill (and an old fill without one), with a step-by-step guide
  in English / BM (the Today tab's language choice). TAKE PHOTO (camera) or gallery; the fill is saved, then the photo is
  sent (folder FuelEntry, filePathTable FuelEntry); if the photo fails the fill stays saved and the button says TRY AGAIN.
- "Second fill today?" question when the driver already saved fuel that day.
- List: receipt icon green (sent) / red (missing). FuelEntryModel.filePath read only (never sent).
- iOS camera / photo permission text now names fuel receipts.
- [x] dart analyze clean for the change; flutter test (driver_fuel_receipt_test 5, driver_fuel_tab_test 4) incl. 360 px EN + BM.
- [ ] owner: device test (camera on Android + iPhone), after the backend deploy.
