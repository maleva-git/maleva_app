# Proposal

## Why
The payable team (role 1100) asked for the petty cash form on the phone, with Read with AI and the running petty
cash book balance (plan S6, `docs/payable/s6-petty-cash-ai-design.md` §2–§3, §6 Q4). The web form and the Java APIs
already exist; the app has no petty cash form today.

## What Changes
- New petty cash form page in the payable desk: date, Requested by (searchable drop-down, the signed-in employee by
  default on a new sheet), Employee type (drop-down), Status (the web's payment status list), Remark.
- Balance block as on the web (`PettyCashBalanceBlock.tsx`): Last balance (from the person's last sheet on a new
  sheet, with "from PTCxxx, dd/MM/yyyy" or "No earlier sheet: type the opening balance"; a pencil to type it by hand),
  Cash received, Total, This balance (= last + received − total, red with "More spent than cash in hand" below 0, save
  still allowed). Only Total shows while the server says the balances are not ready.
- Lines: item, notes, amount and an account (drop-down) whose e-Invoice classification is taken from the account.
- Editing a saved sheet shows the saved balances and, when the sheet before ends on another balance, the yellow note
  "Last balance changed: was RM x, now RM y" with **Update** (`POST /api/petty-cash-book/{id}/follow`).
- **Read with AI** from a camera or gallery photo (`POST /api/ai/petty-cash/extract`): asks before replacing a filled
  form, fills everything the web's way (`pettyCashAi.ts`), shows "Filled by AI — please check" with the warnings and
  the closest names to tap; the photo is attached to folder `PettyCash` after the first save.
- Photos can be added before saving and the saved files are listed on an edit (shared `/api/attachments`).
- No backend change: the app reads the Java answers as they are (PascalCase `ApiResponse` wrapper).

## Capabilities
### New Capabilities
- `payable-pettycash-form`: create and edit a petty cash sheet in the app, with its balance and AI reading.

### Modified Capabilities
(none)

## Impact
New `lib/features/dashboard/payable_dashboard/pettycash/` (draft, API, AI mapping, form page) and
`test/features/dashboard/payable_dashboard/payable_pettycash_test.dart`. Shared parts are reused, not changed
(`po/view/form_parts.dart`, `po/view/po_pickers.dart`, `records/view/record_style.dart`, `core/files`). The entry
button in Records is not added in this change (the Records files are being edited by someone else); it is a follow-up.
