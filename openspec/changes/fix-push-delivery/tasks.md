## 1. App

- [x] 1.1 `LocalNotificationService.createAlertChannel`, called in `main()`; `AppGlobals.channelId` = `com.kassapos.maleva.urgent`.
- [x] 1.2 `backgroundHandler`: `@pragma('vm:entry-point')`, null-safe.
- [x] 1.3 `onMessage`: local copy on Android only.
- [x] 1.4 `flutter analyze` (no new issues) and `flutter test` (718 pass; 1 unrelated failure in `bluetooth_page_test`).
- [ ] 1.5 Device check (owner): app closed, an unread-mail push pops up with a sound; on iPhone with the app open it shows once.
