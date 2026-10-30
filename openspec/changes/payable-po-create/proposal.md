# Proposal

## Why
The payable team's list (scan item 3, "Can open PO") — the owner confirmed it means **create a new PO** from the phone
(2026-10-30) — with "AI read" (owner's message). Plan step S3, `docs/payable/payable-app-plan.md`.

## What Changes
- **New PO** button on the Records tab (PO chip) and **Edit** on a PO's detail page open a full-screen form in three
  steps: **1 Supplier** (supplier, PO date, invoice no. and date, payment term → due date, expense type, pay to, truck,
  driver, job no., status, remarks) · **2 Items** (GL account, description, qty × rate + tax % = amount; add / edit /
  remove; live total) · **3 Check & save** (summary, problems list, photos to attach, Save).
- **Read with AI**: take a photo or pick one; the existing shared `POST /api/ai/purchase-orders/extract`
  (`LlmGateway` task `purchase-order-extraction`) fills the form; warnings and supplier candidates are shown; the
  person checks and presses Save (nothing is saved by the AI).
- Saves exactly as the web form (`POST /api/bills-order/insert`, header `Comid`, same fields and defaults: CREDIT,
  pay to DIRECT PAYMENT, status ASSIGNED, amounts = Σ lines); same checks (supplier, term, expense type, invoice no.,
  ≥ 1 line, every line an account, invoice no. not used before for a new PO). Photos upload to `BillOrderMaster` after
  the save with the new id.
- Photos only (camera / gallery); PDFs stay on the web (`file_picker` is not enabled in the app).
- Not in this step: Push to Bill / Push to PV (they open the Bill / Voucher forms of step S4); POs raised from a
  workshop job order are edited on the web (their job-order line links are not carried by the app).
- No backend change.

## Capabilities
### New Capabilities
- `payable-po-create`: create and edit a purchase order in the app, with AI read and photos.

## Impact
`payable_dashboard/po/` (draft model + rules, API, AI mapping, form page, pickers), Records tab and detail page
entry points; tests. Endpoints (all used by the web PO form): `bills-order/insert`, `edit-bills-order`,
`max-bills-order-no`, `check-invoice-no`, `select-description`, `select-payment-to`, `/api/suppliers/combo`,
`/api/suppliers/select`, `/api/payment-terms-master`, `/api/payment-terms/supplier-due`,
`/api/payment-vouchers/select-coa-expense`, `/api/truck-combo`, `/api/driver-combo`, `/api/ai/purchase-orders/extract`,
`/api/attachments`.
