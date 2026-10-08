## Why

Every employee should see their unread company mail in the app and get a phone notification when mail waits
too long (backend `maleva-backend/openspec/changes/add-my-unread-mail-notice`).

## What changes

- Read `GET /api/mail-monitor/my-unread` as the Java API answers it (rule: the app adapts, the API is shared).
- ~~An "Unread mail" bar on every dashboard~~ removed at the owner's request (2026-10-08): the phone notification
  and the "My unread mail" screen it opens are enough.
- The push notice (`type=MAIL_UNREAD`) is shown by the existing `LocalNotificationService`; tapping it (app open,
  in the background, or started from it) opens a "My unread mail" screen. Today taps do nothing
  (`onMessageOpenedApp` / `getInitialMessage` are empty in `main.dart`).

## Impact

`lib/core/mailmonitor/` (model + API), `lib/features/mail_monitor/mine/` (cubit, card, screen), `main.dart` tap
routing, the dashboard screens. No backend change for the app. Owner tests on a device.
