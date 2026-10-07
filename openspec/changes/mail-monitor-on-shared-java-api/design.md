# Design

## Facts checked (code-verified, 2026-10-07)

**Backend access works for the app as it is.**
- A mobile employee token's subject is the plain user name (`PrincipalKind.subject`) and it
  carries `roleId`, so `JwtAuthenticationFilter` grants `ROLE_SUPERADMIN` exactly as for the web.
- `MailMonitorAccess` looks up the user's companies from `EmployeeMaster.UserName` and accepts
  role `100,SUPERADMIN`.
- Driver tokens get `ROLE_DRIVER` and are refused.

So no backend change is needed. Device check: confirm with a real Super Admin app login.

**App building blocks.**
- `JavaApiClient` (Dio, bearer token, one refresh on 401) and `JavaResponse.data/fromDio` (reads
  `Data1`, throws `ApiFailure(Message)`).
- `AppSession.roleId/companyId`, BLoC + get_it (`sl`).
- Shared widgets: `SkeletonList`, `EmptyState`, `ErrorState`, `StatusPill`, `CountTile`,
  `DetailSection`, `KeyValueRow`, `showSnack`.
- There is no WebSocket client and no HTML package.

**Admin dashboard.** `admin_dashboard_ui.dart` builds a fixed tab list driven by an external
`TabController`. Roles 100 and 200 both use it (`dashboard_routes.dart`).

## Layout

```
lib/core/mailmonitor/
  mail_monitor_api.dart        MailMonitorApi(Dio, companyId: int Function())
  mail_monitor_models.dart     MailboxRow, MailboxMember, MailMonitorSummary, MailboxList,
                               PreviewItem, UnreadPage, MailMessage, MailAttachment,
                               ReminderResult - each with fromJava(Map)
  mail_text.dart               htmlToText(String) - pure, no package
lib/features/mail_monitor/
  bloc/  mailbox_list_bloc.dart (+event/state), unread_mail_bloc.dart, mail_message_cubit.dart
  view/  mail_monitor_tab.dart, mailbox_card.dart, mailbox_detail_page.dart,
         unread_mail_page.dart, mail_message_page.dart, level_look.dart
test/core/mailmonitor/  mail_monitor_api_test.dart, mail_monitor_models_test.dart, mail_text_test.dart
test/features/mail_monitor/  mailbox_list_bloc_test.dart, unread_mail_bloc_test.dart, mail_monitor_tab_test.dart
```

## API payloads (the Java fields as they are)

- **List.** `Data1 = {summary:{totalUnread, withUnread, overdue, errors, mailboxes,
  lastFullCheckAt}, mailboxes:[{id, address, displayName, kind, department, enabled, warnMinutes,
  overdueMinutes, members:[{employeeId, name, role, getsReminders, active}], credentialSet,
  credentialSetAt, unread, oldestUnreadAt, newestUnreadAt, lastCheckedAt, lastOkAt, status, level,
  errorMessage}]}`
- **Preview.** `{mailboxId, checkedAt, items:[{uid, sender, subject, receivedAt}]}`
- **Unread page.** `{mailboxId, total, page, size, query, fetchedAt, items:[…same…]}`
- **Message.** `{mailboxId, uid, from, to, cc, subject, sentAt, receivedAt, html, text, truncated,
  attachments:[{name, contentType, size}]}`
- **Reminder.** `{sentTo:[…], nextAllowedAt}`

Notes:
- Times are ISO-8601 UTC strings, shown in local time as `d MMM yyyy, HH:mm` (intl).
- `status` is one of `OK`, `AUTH_FAILED`, `ERROR`, `NO_SECRET`, `DISABLED`, `PENDING`.
- `level` is one of `CLEAR`, `NEW`, `AGEING`, `OVERDUE`, or null.
- Unknown values show as neutral, so a new server value never crashes the screen.

## Behaviour

**Tab (Super Admin only).**
- The tab entry and its view are added only when `AppSession.roleId == 100`. The tab count is
  computed from the same list, so the `TabController` length always matches. The external
  controller is created with that length.

**Live data.**
- `MailboxListBloc` loads on open and refreshes every 60 s while the tab is visible (a Timer,
  cancelled on close).
- Pull-to-refresh also reloads.
- "Check now" calls the endpoint. A 409 shows "A check is already running", and the list reloads
  after 20 s.

**Detail page.**
- Shows counts, oldest age, last check, the hint for `AUTH_FAILED`/`NO_SECRET`, the latest 5
  (tap to open), people, the limits, and "View all unread (n)".
- The "Email <owner>" button shows only with an active OWNER and unread > 0. A 429 shows the
  server's message.

**Unread page.**
- Infinite scroll of 50-item pages, newest first, plus a search field (server search on submit).

**Mail page.**
- Shows From, To, Cc, Sent, Received, and attachment chips (name · size, not tappable).
- Body: `text` when present, otherwise `htmlToText(html)`. `htmlToText`:
  - removes `<script>`/`<style>` blocks;
  - turns `<br>`, `</p>`, `</div>`, `</tr>` and `<li>` into line breaks;
  - strips all other tags;
  - decodes the common entities (`&amp; &lt; &gt; &quot; &#39; &nbsp;` and numeric ones);
  - collapses blank lines.
- The body is shown in a `SelectableText`. Nothing is fetched from inside the mail.
- A note says "Stays unread · opening is recorded".

**Errors.** `ApiFailure.message` is shown through `ErrorState` / `showSnack`. A 503 explains that
the monitor is not set up on the server.

**Privacy.** Previews, pages and messages live only in bloc state. Nothing is written to
SharedPreferences, files or logs.

## Compatibility

- No existing screen, route or API is changed. The only edit to existing code is the admin
  dashboard tab list and the DI registration.
- The web and the app use the same endpoints, so the audit log shows app opens the same way as web
  opens.

## Risks

- **Large unread totals** (20,000+): paging keeps the app light, but each page is a live mailbox
  read (about 0.5–1 s).
- **Plain text loses formatting.** Tables in operational mails become lines of text. Owner
  accepted this.
