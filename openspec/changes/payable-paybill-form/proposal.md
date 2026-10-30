# Proposal

## Why
Plan step S4, part **4c**: pay a supplier's bills from the phone (owner, 2026-10-30). `docs/payable/payable-app-plan.md`.

## What Changes
- **Pay bills** (Records → Pay bill chip), **Edit** on a pay bill, and **Pay this bill** on a credit bill's page open a
  3-step form (Supplier · Bills · Check & save):
  - Supplier: pay to, the supplier's bank / account (shown, sent as on the web), bank (payment by), date, reference no.,
    bank charges, description, status (default Send for approval), "send to the voucher queue" (PV status), remarks.
  - Bills: the supplier's open documents (bills, purchases, opening balance) with balance and paid; tap one to enter an
    amount, **Full balance** or **Not paying**; **Pay all**; live total.
  - Check & save: summary, the paid bills' files offered with ticks (copied after the save, new payment only), photos.
- Saves as the web: `POST /api/payments/save?companyId`, header `Comid`; only documents with an amount; checks in the
  web's order (supplier, bank, reference, status, description, ≥ 1 amount, total > 0, no amount above its balance).
  Duplicate answer → told, nothing uploaded.
- "Pay this bill" chooses the bill's supplier and puts the bill's full balance on it; not offered on a CASH bill.
- Step header shared by all forms now shrinks its step names on a narrow phone (was 4.6 px too wide at 390 px).
- No backend change.

## Capabilities
### New Capabilities
- `payable-paybill-form`: pay a supplier's bills in the app.

## Impact
`payable_dashboard/paybill/` (draft, API, form), `records` (Pay bills, Edit, Pay this bill),
`po/view/form_parts.dart` (StepHeader); tests `payable_paybill_test.dart`.
