# Design
- **Same design as the PO and bill forms** (`po/view/form_parts.dart`, pickers, Panel); steps named Pay · Lines ·
  Check & save; a simpler line sheet (account, description, amount: vouchers have no qty × rate).
- **Draft** `voucher/data/voucher_draft.dart` = web `buildSavePayload` + `PaymentVoucherFormPage.tsx` checks; the body is
  camelCase (the server binds without case; the web sends PascalCase).
- **Links**: the server deletes and re-inserts lines on save and re-opens the bills the old lines settled; the app
  therefore always sends `leviEntryRefId`, `pendingPaymentRefId`, `subExpenseRefid` back and does not let a person drop
  a linked line (edit it on the web).
- **Lookups**: banks `/api/banks/company/{id}`, pay to / from `select-payment-to|from` (`{data:[{accountName}]}`),
  heads `/descriptions` merged with the web's fixed list; one tolerant envelope reader.
- **Status**: offered to everyone as on the web (no role rule exists on web or server).
- **No AI**: no shared voucher extraction endpoint; adding one is a separate AI change (playbook §9), not done here.

## Risks
- `/api/payment-voucher-masters/save` is `@PermitAll` with the company from the request (existing gap; plan note).
- A new voucher for a PO marks the PO PAYMENT COMPLETED; the confirm says so.
