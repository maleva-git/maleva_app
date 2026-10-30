# Design
- **Same design as the other forms** (shared parts); the Bills step is a tap-to-pay list (no line editor), each row
  showing balance and paid, highlighted when an amount is on it, red when it is more than the balance.
- **Draft** `paybill/data/paybill_draft.dart` = web `insertPayment` body + `handleSave` checks.
- **Edit** uses the edit answer's `paymentDetails` (the whole open list with this payment's amounts) as the web does;
  choosing another supplier reloads with `excludePaymentId`.
- **Supplier bank / tax details** from `/api/suppliers/select` by id, shown and sent as on the web (not edited in the app).
- **Files**: the paid bills' `BillMaster` files are offered (new payment only, as the web's carried documents) and
  copied to `PayBills`.
- **Amount sheet** is its own widget that owns its text box (disposing it while the sheet closed broke the layout — found
  by the tests).

## Risks
- `/api/payments/save` is `@PermitAll` with the company from the request (existing gap; plan note).
