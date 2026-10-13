# Proposal

## Why

Same as backend change `mail-report-office-hours-fair-ranking` (owner, 2026-10-11): office-hours reply time,
fair rule-based categories, structured AI summary. The app's Mail Response tab must show the same.

## What Changes

- Mail Response tab: office-hours line; category badge and reasons per mailbox card ("Not enough data" grey,
  never slow); after-office arrivals tile; spotlight from the backend; AI points as cards linked to mailbox cards,
  read aloud per language as today; late sheet shows office and clock time.
- Models read the new Java fields as sent; no mapping to old shapes.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `mail-response-report`: office hours, categories, structured AI points (added requirement; the capability is in
  the unarchived change `mail-response-report-tab`).

## Impact

`core/mailmonitor/response_report_models.dart`, `features/mail_monitor/report/*`, tests.
