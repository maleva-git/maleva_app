# Proposal

## Why

The owner asked (2026-10-11) to choose the language of the Mail Response tab's AI summary - English, Tamil,
Bahasa Melayu, Chinese, Spanish or Hindi - and to have it read aloud in that language.

## What Changes

- The AI card gets a **Language** picker: English, தமிழ் Tamil, Bahasa Melayu, 中文 Chinese, Español Spanish,
  हिन्दी Hindi (default English).
- The summary is asked for in that language (`language` on `POST /api/mail-monitor/response-report/summary`,
  backend change `mail-summary-language`). Changing the language while a summary is shown writes it again in
  the new language.
- **Read aloud** uses the device voice of that language (en-US, ta-IN, ms-MY, zh-CN, es-ES, hi-IN). When the
  device has no voice for it, the card says so and how to add it.
- Before the backend is deployed the server ignores the parameter and answers in English; nothing breaks.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `mail-response-report`: the AI summary has a language choice (added requirement; the capability is in the
  unarchived change `mail-response-report-tab`).

## Impact

`core/mailmonitor/mail_monitor_api.dart` (`language` on `responseSummary`), `features/mail_monitor/report/`
(`summary_language.dart`, speaker with a voice per language, cubit, AI card), tests.
