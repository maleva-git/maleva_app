# Proposal

## Why
The owner asked for Bill, Pay bill and Payment voucher in the app with Push and AI read (2026-10-30). Plan step S4,
built in parts; this change is **4a: the supplier bill** (`docs/payable/payable-app-plan.md`).

## What Changes
- **New bill** (Records → Bill chip) and **Edit** on a bill open a 3-step form like the PO form (Supplier · Items ·
  Check & save): supplier → its term, currency rate and due date; invoice no.; bill / invoice / due dates; Credit or
  Cash; expense type; truck, driver; status Completed / Cancel; remarks; items (account, qty × rate + tax); photos.
- **Read with AI** on a new bill: the shared `POST /api/ai/bills/extract` (`LlmGateway` task `bill-extraction`) fills
  it the web's way (`useBillAiReading.ts`); the person checks and saves.
- **Push to Bill** on a PO's page: the bill is filled from the PO (web `useBillOpen.ts`), the PO's files are listed
  with ticks to carry, and they are copied with `copyFromPaths` after the save. The confirm says the PO will be marked
  INVOICE MADE (the server does that on a new bill from a PO).
- Saves as the web: `POST /api/bills/save?companyId` with header `Comid` and the web body; checks in the web's order
  (supplier, term, invoice no., expense type, accounts, qty > 0, invoice no. not on another bill for a new one, total
  not below what is already paid for an edit). When the server answers that the same bill exists (`duplicate`), the
  app says so and uploads nothing.
- Shared form parts moved to `po/view/form_parts.dart` (steps header, item sheet, date field, banners, totals);
  `AttachmentsApi.copyFrom` added; Records detail buttons become a list (Edit, Push to Bill).
- No backend change.

## Capabilities
### New Capabilities
- `payable-bill-form`: create, edit and push a supplier bill in the app.

## Impact
`payable_dashboard/bill/` (draft, API, AI mapping, form), `po/view/form_parts.dart`, `records` (FormRequest /
OpenForm, RecordAction), `core/files/attachments_api.dart` (`copyFrom`); tests `payable_bill_test.dart`.
