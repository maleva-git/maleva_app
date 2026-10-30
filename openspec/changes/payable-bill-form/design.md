# Design
- **Same design as the PO form**: shared parts moved to `po/view/form_parts.dart`; lines reuse `PoLine` (same maths).
- **Draft** `bill/data/bill_draft.dart` = web `billsApi.ts` buildSavePayload + `billCalculations.ts` + `useBillSave.ts`.
  `fromPo` gives every line id 0 (the web keeps the PO line id, which the server treats as new on a new bill).
  The PO's own status words (ASSIGNED…) are not bill statuses, so a pushed bill starts as Completed.
- **API** `bill/data/bill_api.dart` wraps `PoApi` for the shared lookups; own calls: next number, supplier currency,
  invoice exists, paid amount, edit, save, AI extract. Expense types come from `bills-order/select-description` (the
  web bill form uses that, not `/api/bills/descriptions`).
- **AI** (playbook): existing task `bill-extraction`, shared endpoint, person checks and saves; the photo read is kept
  and attached. AI is not offered on a pushed bill (the PO already fills it).
- **Files**: `AttachmentsApi.copyFrom` posts `copyFromPaths` (repeated keys, `ListFormat.multi`) with an empty form,
  as the web's separate copy request; then new photos with `add`.
- **Phone width**: Credit/Cash chips and Camera/Gallery buttons wrap (found by the 390 px tests; PO form too).

## Risks
- `/api/bills/save` is `@PermitAll` with the company from the request (existing gap, plan note).
- Saving a new bill from a PO changes the PO on the server (INVOICE MADE); the confirm says so.
