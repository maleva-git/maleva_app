Depends on backend change `add-mail-monitor` (deployed, with its key set and `db/mail-monitor.sql`
run on the database). No backend change.

## 1. Data layer

- [x] 1.1 `lib/core/mailmonitor/mail_monitor_models.dart`: typed models with `fromJava`. Unknown status or level reads as neutral. Verify: `mail_monitor_models_test.dart` with the Java JSON shapes.
- [x] 1.2 `lib/core/mailmonitor/mail_monitor_api.dart`: list, preview, unread page, message, remind, check-now. Uses `JavaResponse`. Verify: `mail_monitor_api_test.dart` (QueueAdapter checks paths, `companyId`/`page`/`size`/`q`, and that an `ApiFailure` carries the server message for 403, 404, 409, 429 and 503).
- [x] 1.3 `lib/core/mailmonitor/mail_text.dart`: `htmlToText`. Verify: `mail_text_test.dart` (script and style removed, line breaks kept, entities decoded).
- [x] 1.4 Register `MailMonitorApi` in `auth_injection.dart`. Verify: `flutter analyze`.

## 2. Screens (Requirements: tab, refresh, detail, unread, open as text)

- [x] 2.1 `MailboxListBloc`: load, 60 s refresh, check now. `MailMonitorTab` + `MailboxCard`: summary, overdue first, level look. Verify: `mailbox_list_bloc_test.dart`.
- [x] 2.2 `MailboxDetailPage`: latest 5, people, limits, reminder rules. Verify: widget test for the no-owner hint and the 429 message.
- [x] 2.3 `UnreadMailBloc` + `UnreadMailPage`: paging and search. Verify: `unread_mail_bloc_test.dart` (page 1 appended, search restarts at 0).
- [x] 2.4 `MailMessageCubit` + `MailMessagePage`: headers, attachment chips, text body, 404 message. Verify: widget test for an HTML-only mail showing text only.

## 3. Entry point (Requirement: Super Admin tab)

- [x] 3.1 Admin dashboard: add the "Mailbox Monitor" tab and view only when `roleId == 100`, and size the TabController from the same list. Verify: `mail_monitor_tab_test.dart` (role 100 sees it, role 200 doesn't).

## 4. Verify

- [x] 4.1 `flutter analyze` and `flutter test` pass.
- [ ] 4.2 Owner on devices:
  - phone and tablet;
  - Super Admin sees the tab and Admin doesn't;
  - counts match the web;
  - open a mail and check it stays unread in Gmail;
  - send a reminder;
  - search, and scroll past 50.

## Result (2026-10-07)

- **Built.** Cubits from flutter_bloc are used (simpler than event-based blocs for these screens).
- **Tests.**
  - `flutter analyze` on the new and changed files: no issues. The whole app has 675 older issues in other files.
  - `flutter test test/core/mailmonitor test/features/mail_monitor`: 21 passed.
- **Full suite:** 635 run, 1 failure: `test/features/bluetooth/bluetooth_page_test.dart` ("auto-connect without printer…"). It fails the same way when run alone. It imports only Bluetooth code, which this change does not touch, so it is an existing failure.
- **Tab test.** The role rule is tested through `mailMonitorAllowed`. The full dashboard widget needs every tab's bloc, so the tab itself is checked on devices (task 4.2).
