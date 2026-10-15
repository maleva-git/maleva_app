# Design

- The models read the Java response as it is: `Data1.vehicle` (`truckId`, `truckNumber`,
  `truckNumber1`, `capacity`, `sealType`, `bondNo`, `bondExp`, `driverRefId`) and `Data1.driver`
  (`driverId`, `driverName`, `nricNo`, `mobileNo`, `passportNo`). No legacy row mapping.
- Truck and driver are fetched separately (`?truckId=` / `?driverId=`), so changing one does not
  reload the other. Choosing a truck fills in its usual driver when no driver is chosen.
- The PDF is built on the phone with the `pdf` package (A4 landscape, same layout as the web
  jsPDF download), written to the temporary folder and handed to the share sheet, from which the
  user saves it to Files or sends it on WhatsApp.
- Read only: values are edited on the web Truck Master / Driver Master forms.
- The PDF uses the built-in Helvetica font, which only covers Latin characters; names in Maleva's
  data are Latin.
- Three buttons (2026-10-14): Truck PDF, Driver PDF, Download Both. A half-sheet is titled and
  named for what it holds (`Vehicle-Details-*.pdf`, `Driver-Details-*.pdf`).
- Letterhead: the Maleva emblem (`assets/company/maleva_emblem.png`, cropped from `roundlogo.png`),
  company name, document title and date; brand blue #233F94 and a footer (no signature lines, owner 2026-10-14). Same
  design as the web PDF.
