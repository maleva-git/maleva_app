# Design

## Context

The web page is `maleva-front-end/src/features/mail-monitor/report/pages/MailResponseReportPage.tsx`; its
rules live in `model/responseBands.ts` (bands, minutes text, ordering, spotlight, presets). The Java API
(`MailResponseReportController`, DTOs in `ResponseReportDtos`) is already shared; answers come in the usual
wrapper read by `JavaResponse.data`. The app's `MailMonitorApi` already sends `companyId`; the mail page
`MailMessagePage(api, mailboxId, uid)` already opens one mail read-only.

## Goals / Non-Goals

**Goals:** the web page's numbers and rules in the app's design; read aloud; PDF view/share.

**Non-Goals:** settings editing, after-hours report, CSV; any backend change.

## Decisions

- **Models in `core/mailmonitor/response_report_models.dart`**, read from the Java fields as sent (camelCase
  records); null percentages and minutes stay null.
- **Rules ported one-to-one from `responseBands.ts`** into `features/mail_monitor/report/response_rules.dart`
  (`bandOf`, `minutesText`, `pctText`, `ranked`, `spotlight`, `rangeOf` with Malaysia date = UTC+8,
  `rangeText`), with tests copied from the web's cases so both apps agree.
- **API calls added to `MailMonitorApi`** (`responseReport`, `responseLate`, `responseSummary`,
  `responsePdf` as bytes). The PDF call asks for bytes; a JSON error body becomes the server's message.
- **`ResponseReportCubit`**: range, order, report state; summary state kept apart (written only on tap,
  cleared when the range changes). Late list in its own small cubit per sheet.
- **Read aloud** through a `SummarySpeaker` interface with a `flutter_tts` implementation, so tests use a
  fake. Speaks the points joined; stops on Stop, on dispose, and when the range changes.
- **PDF**: bytes saved to the temp folder as `Mail-Response-Report-<from>-to-<to>.pdf`; View opens it with
  `open_file`, Share with `share_plus` (both already in the app).
- **Look**: the app's tokens, as the Overview tab: blue gradient header with the range chips and PDF
  buttons; spotlight cards green (fastest), rose (attention), white (company); white number tiles with a
  coloured value for the within-target share; daily bars in `statusSuccess` over `surfaceBorder`; AI card
  `brandLight` with brand buttons; mailbox cards (not a table) with rank, owner, address, band pill
  (`StatusPill`), share within target, average, waiting and mini bars. Phone one column; tablet spotlight
  three across, tiles four across, mailbox cards two across.

## Risks / Trade-offs

- [New package `flutter_tts`] → small, well-used; owner runs the device build (`pod install` on iOS).
- [Device has no TTS voice] → the speaker reports failure and the card shows "Read aloud is not available on
  this device".
- [AI provider slow or off] → the server's message on the card only.

## Migration Plan

App-only. Roll back by removing the tab entry and the package.
