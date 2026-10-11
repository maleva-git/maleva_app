# Proposal

## Why

The web has a Mail response report (`/mail-monitor/response-report`): how fast each mailbox replies to
customer mail against its target, the fastest and slowest repliers, and an AI-written statement on the
numbers. The owner asked (2026-10-11) for the same page as a tab in the app for the Super Admin, in the
app's design, with the AI statement also read aloud.

## What Changes

- New Super Admin tab **Mail Response** on the admin dashboard, right after Mailbox Monitor (tab count
  34 to 35 for role 100; Admin 200 unchanged).
- The tab reads the existing shared Java endpoints the web uses, unchanged:
  `GET /api/mail-monitor/response-report`, `GET /api/mail-monitor/response-report/late`,
  `POST /api/mail-monitor/response-report/summary`, `GET /api/mail-monitor/response-report/pdf`.
- It shows: date presets (Today, Last 7 days, This month) and a custom range; the fastest replier, the one
  needing attention and the whole company; four numbers (customer mails, replied within target, average
  reply time, still waiting); mail per day; the AI summary (written on request, with **Read aloud**);
  every employee's mailbox, slowest or fastest first, with its band (On target / Close / Behind / No mail /
  No sent mail found).
- Tapping an employee opens their late mail: slowest replies and mails still waiting; tapping one opens the
  mail read-only (the existing Mailbox Monitor mail page).
- **View PDF** and **Share PDF** of the server's report for the range.
- Not in the app: editing the reply target (web only), the after-hours report, CSV export.
- New package `flutter_tts` for Read aloud. No backend, API or database change.

## Capabilities

### New Capabilities

- `mail-response-report`: the Super Admin's Mail Response tab in the app.

### Modified Capabilities

None.

## Impact

`core/mailmonitor/` (report models and API calls), new `features/mail_monitor/report/` (cubit, page,
widgets, late sheet, PDF and speech helpers), `admin_dashboard_ui.dart` (one tab entry), `pubspec.yaml`
(`flutter_tts`), tests under `test/features/mail_monitor/report/`.
