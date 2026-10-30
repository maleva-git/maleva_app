# Proposal

## Why
The payable team (role 1100) files levy (levi entry) charges on the web only. The owner wants the payable desk in the
app to have every payable form, so a levy can be made or changed on the phone with a photo of the receipt.

## What Changes
- New **Levy form** page (`payable_dashboard/levy/`), new and edit, with the same fields and rules as the web form
  `maleva-front-end/src/features/levi-entry/` (`leviEntryConfig.ts` → generic `features/pass-entry/pages/PassEntryFormPage.tsx`):
  date (today by default), truck, driver, RTI no (all three required), enter link (IN / OUT / not set), exit link
  (1ST LINK / 2ND LINK / not set), amount (required, not below 0), remarks (up to 2000 letters).
- The levy number is shown: the next number on a new levy, the saved number on an edit.
- Every choice is a drop-down box (searchable sheet), not a chip list.
- Files: an edited levy lists its files (view / open); photos (camera or gallery) are added and uploaded after a
  successful save to the attachment folder `LeviEntry`, as the web does.
- The page closes with `true` after a successful save.
- No AI read, no Push to Payment Voucher (web only for now), no delete.
- **No backend change.** The app uses the Java API the web uses, as it answers:
  `GET /api/levi-entries/next-no`, `GET /api/levi-entries/rti-options`, `GET /api/levi-entries/{id}`,
  `POST /api/levi-entries` (`LeviEntryController` → `AbstractPassEntryController`, `PassEntrySaveRequest`,
  `PassEntryDetailDto`, `RtiOptionDto`), trucks `GET /api/truck-masters/alltruckdetatilcombo`, drivers
  `GET /api/driver-masters/selectalldriverDetails`, files `/api/attachments`.

## Capabilities
### New Capabilities
- `payable-levy-form`: create and edit a levy (levi entry) in the app.

## Impact
New folder `lib/features/dashboard/payable_dashboard/levy/` (draft, API, form page); test
`test/features/dashboard/payable_dashboard/payable_levy_test.dart`. Shared files (`records/`, `po/view/`, `lib/core/`)
are reused, not changed. Opening the form from the Records tab is wired separately (Records is being edited by
someone else).
