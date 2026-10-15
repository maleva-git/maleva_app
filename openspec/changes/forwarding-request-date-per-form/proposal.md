## Why

The web Request FW dialog now gives each ticked form type (K1, K2, K3, K8) its own estimated date, and the
shared Java API takes them as `items` (backend change `forwarding-request-date-per-form`). K1 may be due on a
different day from K8, so one date for every form is not enough. The app adapts to that API (workspace rule:
the app follows the Java API, the API is never reshaped for the app).

## What changes

- `ForwardingRequestApi.create` sends `{saleOrderId, items: [{formType, estimatedDate}], remarks}` instead of
  `formTypes` + one `estimatedDate`. Dates stay `yyyy-MM-dd HH:mm:ss` (`toJavaDateTime`).
- The Request FW sheet shows one date-time picker per ticked form. The first ticked form starts at tomorrow
  09:00; a newly ticked form starts with the date of the last ticked form before it (K1, K2, K3, K8 order),
  as the web's `requestForms.ts` does. Request stays disabled until every ticked form has a date.
- Still one request per form type; remarks are shared.

Depends on `maleva-backend/openspec/changes/forwarding-request-date-per-form` (deployed before the app ships).
Modifies the requirement "Request FW from the sale order" of `forwarding-requests-app`
(change `forwarding-requests-on-shared-java-api`, not yet archived: archive that one first).

## Exclusions

- No backend change. No change to the list, edit page, filter or push routing.
