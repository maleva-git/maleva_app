# Proposal

## Why

The owner wants the Mailbox Monitor in the app for the Super Admin (2026-10-07). On the web it
shows which company mailboxes have unread mail, how much, and how old, and lets the Super Admin read
unread mail and remind the responsible employee.

The Java API already exists: backend change `add-mail-monitor`, used by React since 2026-10-06. This
is a **new** app capability. There is no baseline screen and no .NET code to migrate (CLAUDE.md
rule 3 does not apply). Per rules 1 and 2, the app reads the same Java endpoints and fields as the
web, and **no backend change** is made.

## What Changes

| App screen (new) | Shared Java API (unchanged) |
|---|---|
| Mailbox Monitor tab: summary + one card per mailbox | `GET /api/mail-monitor/mailboxes?companyId` |
| Mailbox detail: counts, latest 5 unread, people, reminder | `GET …/mailboxes/{id}/unread-preview`, `POST …/mailboxes/{id}/remind` |
| All unread: 50 a page, search | `GET …/mailboxes/{id}/unread?companyId&page&size&q` |
| Open a mail (stays unread) | `GET …/mailboxes/{id}/messages/{uid}?companyId` |
| Check now | `POST /api/mail-monitor/check-now?companyId` |

- **New** `MailMonitorApi` with typed models built from the Java fields (`lib/core/mailmonitor`),
  registered in `auth_injection.dart`.
- **New** screens under `lib/features/mail_monitor/` (bloc + view).
- **New** "Mailbox Monitor" tab on the admin dashboard, shown only when `roleId == 100`. Admin
  (200) uses the same dashboard and does not see it.

## Owner's decisions (2026-10-07)

- **Body as text only.** HTML mail is turned into readable text in the app. No new package: no
  images, no scripts, nothing loaded from outside. Tables and colours are lost.
- **Entry point** is a tab on the admin dashboard, Super Admin only.
- Earlier decisions carry over from the web (2026-10-06):
  - mail is read-only and an opened mail stays unread;
  - attachments are shown by name and size only, with no download;
  - every open is audited on the server;
  - reminders are manual.

## Scope and exclusions

- **In:** viewing counts and status, the unread list, opening mail, check now, sending a reminder.
- **Out:**
  - Settings (adding mailboxes, linking people, mailbox passwords) stays on the web. A password
    should not be typed on a phone.
  - No live push: the app has no STOMP/WebSocket client. The list refreshes every 60 s while the
    tab is open, and on pull-to-refresh.
  - No push notifications. No HTML rendering. No attachment download.

## User-visible outcome

A Super Admin opens the admin dashboard, taps **Mailbox Monitor**, and sees the same counts and
colours as the web. They can tap a mailbox for details, browse all unread mail, open a mail to read
it as text, and send the owner a reminder. Other roles never see the tab, and the server refuses
them in any case.

## Affected capabilities

- New spec `mail-monitor`.
- Related existing capability paths, not modified:
  - `navigation-permissions` (role-gated dashboard tabs)
  - `api-integration` (JavaApiClient + JavaResponse)
