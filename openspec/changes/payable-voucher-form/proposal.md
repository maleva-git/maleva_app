# Proposal

## Why
Plan step S4, part **4b**: the payment voucher in the app, with **Push to PV** from a purchase order (owner,
2026-10-30: "bill, pay bill and payment voucher … the push option"). `docs/payable/payable-app-plan.md`.

## What Changes
- **New voucher** (Records → Voucher chip) and **Edit** on a voucher open a 3-step form (Pay · Lines · Check & save):
  pay to (with past names), payment by (bank, required), pay from (with past names), date, reference, bank charges,
  expense head (the company's heads + the web's fixed list), status (Send for approval by default, Pending documents,
  Accepted, Rejected, Completed — as on the web, no role limit); lines (account, what it is for, amount); photos.
- **Push to PV** on a PO's page: the voucher is filled from the PO (PO link, pay to, pay from, expense head, one line per
  PO line with its amount), the PO's files are offered with ticks and copied after the save; the confirm says the PO
  will be marked PAYMENT COMPLETED (the server does that on a new voucher for a PO).
- Saves as the web: `POST /api/payment-voucher-masters/save?companyId`, header `Comid`; checks in the web's order
  (expense head, bank, ≥ 1 line, every line an account, amounts ≥ 0). Server answers (closed period, levy already paid,
  overpaid monthly bill, duplicate) are shown; a duplicate uploads nothing.
- **Edit keeps every line's links** (levy entry, pending monthly payment, sub-expense), because the server replaces all
  lines on each save; such a linked line shows 🔗 and cannot be removed in the app.
- `PoApi.accounts` also reads the account's classification (a voucher line carries it).
- No AI read on vouchers (no shared AI endpoint for vouchers exists); no backend change.

## Capabilities
### New Capabilities
- `payable-voucher-form`: create, edit and push a payment voucher in the app.

## Impact
`payable_dashboard/voucher/` (draft, API, form), `records` (New voucher, Edit, Push to PV), `po/data/po_api.dart`;
tests `payable_voucher_test.dart`.
