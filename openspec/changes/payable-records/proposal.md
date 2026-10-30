# Proposal

## Why

The payable team asked (hand-written list, 30 Oct 2026, items 1, 2, 7, 10) to see the details and the attached files
of purchase orders, bills, pay bills, payment vouchers, petty cash and levy on the phone. Today the app lists only
pending POs (the "Bills" tab) and petty cash, with no file viewer; bills, pay bills and vouchers are not in the app at
all. Plan: `docs/payable/payable-app-plan.md` step S1 (owner: "start Step 1", 2026-10-30).

## What Changes

- New Payable dashboard tab **Records** (after PO & Vouchers), replacing the "Bills" tab (which showed only pending POs):
  - Record chips: **PO · Bill · Pay bill · Voucher · Petty cash · Levy**.
  - Period chips: This month, Last month, Pick dates; a search box; status chips built from the statuses in the list.
  - A summary line: how many, total RM, how many with files.
  - One card per record: number, date, supplier / pay to / employee / truck, amount, status colour, 📎 file count.
- Tap a card → **detail page**: amount and status at the top, the facts (dates, supplier, invoice no, description,
  remarks, linked PO / voucher), the lines with their amounts and the total, and **Files**: photos as thumbnails that
  open full screen with zoom, PDFs and other files open in the phone's viewer; Share.
- Read only. No create, edit, delete or status change (steps S3, S4).
- No backend, API or database change: the same Java endpoints the web uses (`bills-order/select-bills-order` +
  `edit-bills-order`, `bills/search` + `edit`, `payments/search` + `edit`, `payment-voucher-masters/search` + `edit`,
  `petty-cash-masters/search` + `edit`, `levi-entries` + `/{id}`, `/api/attachments` + `/summary`).

## Capabilities

### New Capabilities

- `payable-records`: the Records tab and the record detail page.

### Modified Capabilities

- `payable-desk` (change `payable-desk-today`, not archived): tab order — Records takes the place of Bills.

## Impact

`lib/features/dashboard/payable_dashboard/records/` (api, models, cubit, list, detail, file viewer),
`payable_tabs.dart`, `payable_dashboard_ui.dart`, Today tab Open buttons; tests under
`test/features/dashboard/payable_dashboard/`. Existing packages only (`cached_network_image`, `url_launcher`, `share_plus`).
