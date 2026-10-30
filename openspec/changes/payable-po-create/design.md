# Design

- **Draft model** `po/data/po_draft.dart` holds the web form's fields and rules (`utils/purchaseOrderForm.ts`,
  `hooks/usePurchaseOrderSave.ts`): line maths, totals, problems in the web's order, `toJson` = the web's whitelist.
- **API** `po/data/po_api.dart`: one tolerant envelope reader (`{IsSuccess,Data1}`, `{isSuccess,data1}`, `{ok,data}`),
  as the lookups use all three. Save with header `Comid` (the controller reads it there).
- **AI** `po/data/po_ai.dart`: the web's mapping (`usePurchaseOrderAiReading.ts`, `purchaseOrderAi.ts`). AI playbook:
  existing task `purchase-order-extraction` through `LlmGateway`, shared endpoint (web + app), structured output,
  supplier/account matched against the company's lists, **a person checks and saves** (§6); no new prompt, no new
  data sent (the photo the person chose, as on the web).
- **Photos only** (image_picker, already in the app); `file_picker` is not enabled, so PDFs stay on the web.
- **Job-order POs** are not edited in the app: their `jobOrderDetailIds` links are not returned by the edit call,
  and saving without them would break the workshop link.
- **Lookups fail softly**: each failing list shows a warning line; the form still opens.
- Push to Bill / Push to PV wait for the Bill and Voucher forms (step S4).

## Risks
- `/api/bills-order/insert` is `@PermitAll` with the company from the `Comid` header (existing; the app sends the
  signed-in company). To close in the backend before more write screens (plan note).
