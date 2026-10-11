# Tasks

## 1. Data and rules

- [x] 1.1 `response_report_models.dart` and the four `MailMonitorApi` calls; tests reading Java JSON
      (nulls kept) and the PDF bytes / JSON-error path
- [x] 1.2 `response_rules.dart` ported from `responseBands.ts`; tests from the web's cases (bands, minutes,
      order, spotlight, presets in Malaysia time)

## 2. State

- [x] 2.1 `ResponseReportCubit` (range, order, report, summary) and `LateMailCubit`; cubit tests: range change
      reloads and clears the summary; summary error kept on the card

## 3. Screen

- [x] 3.1 `MailResponseTab` page and widgets in the app's tokens, phone and tablet; widget tests for both widths,
      bands shown, order switch, error states (403/503/other)
- [x] 3.2 Late mail sheet; tap opens `MailMessagePage`; widget test
- [x] 3.3 AI card with Write summary and Read aloud / Stop through `SummarySpeaker` (`flutter_tts`); widget
      test with a fake speaker
- [x] 3.4 View / Share PDF (temp file, `open_file`, `share_plus`)

## 4. Dashboard

- [x] 4.1 Mail Response tab after Mailbox Monitor for role 100 in `adminTabs`; update the tab test (35 / 32)
- [x] 4.2 `flutter analyze` on changed folders; `flutter test test/features/mail_monitor test/features/dashboard`

## 5. Owner check

- [ ] 5.1 Owner on tablet and phone as Super Admin: numbers match the web for Today / Last 7 days / This month;
      late sheet and mail open; AI summary written and read aloud; PDF opens and shares
