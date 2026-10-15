## Context

The sheet held a set of form types and one `yyyy-MM-ddTHH:mm` string. The web keeps a map form type → date.

## Decisions

- **State**: `ForwardingFormEstimates` (`Map<String, DateTime?>`); a key means ticked, null means the date was
  cleared. Pure helpers in `forwarding_request_models.dart` (`toggleForwardingForm`, `tickedForwardingForms`,
  `forwardingFormsReady`, `forwardingRequestItems`) mirror `requestForms.ts` and are unit tested.
- **Item**: `ForwardingRequestItem(formType, estimatedDate)` with `toJava()`; the cubit and API take a list of
  them. Items are sent in K1, K2, K3, K8 order.
- **"Last ticked form"** follows the web: the last ticked form in K order, not the one ticked most recently.
  A cleared previous date falls back to tomorrow 09:00 (web: `previous || defaultEstimate`).

## Risks

- An app built with this change needs the backend `items` support; the backend still accepts the old shape,
  so older app builds keep working.
