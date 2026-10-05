# Proposal

## Why

The Add / Edit RTI page (Update RTI, and "push to RTI" from Planning) called .NET **web** routes on the
.NET host. They were not `/api/` paths, so earlier counts missed them. Backend change
`share-rti-entry-api` completes the shared Java RTI API that React's RTI page uses.

## What Changes

| Action | Before (.NET web) | Now (shared Java) |
|---|---|---|
| Next number (preview) | `/RTI/MaxRTINo` | `GET /api/sequence-masters/company/{id}` (RTIMaster + 1, as React) |
| Load for edit | `/RTI/EditRTI` | `GET /api/rti-masters/{id}?companyId` + `GET /api/rti-details/rti-master/{id}` |
| Add job by number | `/RTI/SearchJobNo` | `GET /api/rti-masters/company/{id}/job-search?jobNo` |
| Save | `/RTI/InsertRTI` | `POST /api/rti-masters` (new; the server numbers it) / `PUT /api/rti-masters/{id}?companyId` |
| Revise from sales orders | `/RTI/ReviseRTI` | `GET /api/rti-masters/{id}/revise?companyRefId` |
| Delete | `/RTI/DeleteRTI` | `DELETE /api/rti-masters/{id}?companyId` |
| PDF | `/RTI/RTIView` + `ReportViewer.aspx` | `RtiApi.reportUrl` (`/{id}/report-ticket`) |

- **New** `RtiEntryApi` (`lib/core/rti`), registered in `auth_injection.dart`. The page reads the Java fields directly: `cnumberDisplay`, `elink`, `exLink`, `exitYN`, `manpw`; on lines `saleOrderMasterRefId`, `jobNo`, `customerName`, `pickupDateD`, and so on.
- **The save sends what React sends:**
  - the master fields;
  - the lines (`saleOrderMasterRefId`, salary, PIC, type, origin, destination, dates);
  - the allowance amounts by React's rule (`RtiEntryApi.amounts`): sleeping 50, empty pickup and delivery 80/50, manpower 50/100, pickups and drops 30 each.
  - It omits `routeActivities`, so an edit keeps the route stops set on the web.
- **An edit keeps what the form does not show:**
  - each line's stored pickup and delivery addresses and lists;
  - the stored time of an unchanged date;
  - the web's pickup and drop counts.

  This matters because the server replaces every line on save.

## Behaviour changes (app defects fixed)

- **Link values.** The app stored `LINK 1` / `LINK 2`, where the web and React use `1ST LINK` / `2ND LINK`. The app now uses those, and reads its old values as them.
- **EXIT dropdown.** It offered EMPTY 50 / 80, but it is the exit **link** (`exLink`). It now offers the links.
- **Empty pickup and delivery codes.** They loaded inverted (1 shown as EMPTY 50). They now match the save: 1 = EMPTY 80, 2 = EMPTY 50.
- **Manpower.** It is NO / 1 / 2 (50 / 100), as the web, instead of YES / NO.
- **Total.** It now follows React's rule. It used to add the EXIT link value instead of the empty pickup, and ignored manpower.
- **New RTI number.** The server assigns it, and the form shows it after the save.
- **Job date.** The job search fills it on a new line.
- **Validation.** A save needs at least one job, as React requires.
- **Errors.** A refusal shows the server's reason.
- **Other company's RTIs.** Another company's RTI cannot be opened, saved or deleted.

## Still on .NET (found while checking)

Driver Leave (`dashboard/common_tabs/driverleave`) calls .NET `/api/LeaveRequestApp/*`: save, list, update status, leave types and leave status. It builds the URL from the host directly, so the earlier counts missed it too. It is next.

## Capabilities

### Modified Capabilities
- `api-integration`: the Add / Edit RTI page uses the shared Java RTI API.

## Impact

`lib/core/rti/rti_entry_api.dart` (new), `transport/updatertidetails/view/add_rti_page.dart`,
`auth_injection.dart`. Ships with backend change `share-rti-entry-api`.
