Depends on `maleva-backend/openspec/changes/add-my-unread-mail-notice`. Needs the owner's approval before applying.

## 1. Data
- [x] 1.1 Model and API for `/api/mail-monitor/my-unread`. Verify: model test with a Java-shaped JSON.
## 2. UI
- [x] 2.1 `MyUnreadMailCubit` and the "My unread mail" screen. Verify: cubit and widget tests. (The dashboard bar was built, then removed at the owner's request, 2026-10-08.)
- [x] 2.2 Push tap routing for `MAIL_UNREAD` in `main.dart`. Verify: unit test of the routing function.
## 3. Verify
- [x] 3.1 `flutter analyze`, `flutter test`. Device test by the owner.

## Result (2026-10-08)
- `core/mailmonitor/my_unread_models.dart`, `MailMonitorApi.myUnread()`, `features/mail_monitor/mine/` (cubit, `MyUnreadMailPage`, `push_route.dart`). The router adds `/my_unread_mail`; the dashboards are unchanged. `main.dart`: a tapped MAIL_UNREAD notice opens the screen (background tap at once, a cold start once a dashboard shows, through a router listener); local notifications carry the push type as payload.
- Checks: `flutter test` mail monitor 26 passed (5 new); full suite 642 passed, 1 failed (the known `bluetooth_page_test`, not this change); `flutter analyze` no errors. Device test by the owner.
