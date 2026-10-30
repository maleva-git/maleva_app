# Design

## Sources (web reference, no .NET migration: every API already exists in Java)
- Form: `maleva-front-end/src/features/petty-cash/pages/PettyCashFormPage.tsx`.
- Rules: `utils/pettyCashBalance.ts` (money rounding, This balance), `utils/pettyCashLines.ts` (rows with data,
  incomplete rows, total), `utils/pettyCashAccounts.ts` (account → classification), `utils/pettyCashAi.ts` (AI fill),
  `hooks/usePettyCashBalance.ts` (which Last balance shows), `api/pettyCashApi.ts` (`buildSavePayload`, edit read),
  `api/pettyCashBookApi.ts` (last balance, follow, extract).
- Java: `module/pettycash/controller/PettyCashMasterController` (`next-number`, `save`, `edit?companyId&id`),
  `module/pettycash/book/PettyCashBookController` (`last-balance`, `{id}/follow`),
  `module/ai/pettycashextraction/PettyCashExtractionController` (`extract`), employees `company/{id}/all?type=ALL`
  (bare list) and `employees/types?all=true` (`{id, customerName}`), accounts `payment-vouchers/select-coa-expense`.

## Data
- `PettyCashDraft` holds the header, lines and balance state as typed text (blank stays blank), like the web.
  `typedBefore == null` means Last balance follows the server; a text means the pencil is on.
- Last balance shown = typed text, else the saved figure on an opened sheet that has one, else the server's last
  balance when found, else blank. This balance = round2(last + received − total) with blanks as 0; an opened sheet
  shows its saved This balance until an amount is changed (`dirty`).
- Save body = web `buildSavePayload`: employee = Requested by (else the signed-in employee), date `yyyy-MM-dd`,
  balances only when ready (else null/null/false), lines with an item or amount, amount as a number, account 0 /
  classification 0 when none.
- Checks in the web order: employee type, at least one row, each row needs an item and a valid amount.

## Page
- One scrolling page (not steps): the sheet is short. Panels: Read with AI card (new sheet), Sheet, Balance, Items
  (tap a row → bottom sheet: item, notes, amount, account drop-down), Files, sticky bottom bar with Total and Save.
- Last balance is refreshed from `last-balance` when the person or date changes on a new sheet, and once on open for
  an edit (with `excludeId`), so an old sheet without saved balances starts from the last sheet as on the web.
- Update (follow): calls follow, shows "Updated n sheet(s)" (and where it stopped), reloads the sheet.
- AI: `PhotoPicker` (camera or gallery, file_picker is off). Tests replace the picker through a
  `@visibleForTesting` static so the page constructor stays `(api, files, editId)`.
- 360 px: balance boxes in a 2-column grid of `Expanded`; long texts ellipsis; tested at 360 × 800.

## Risks / not done
- The Records tab has no button to open the page yet (shared file owned by another person right now).
- Push to Payment Voucher and Delete stay on the web.
