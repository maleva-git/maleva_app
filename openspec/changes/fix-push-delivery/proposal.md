# Proposal

## Why

Pushes that arrive while the app is in the background or closed do not pop up on Android.
The manifest names `com.kassapos.maleva.urgent` as Firebase's default channel, but the app never
creates that channel. Android therefore files these pushes under a silent "Miscellaneous" channel.

Two smaller faults:

- The background handler lacks `@pragma('vm:entry-point')` and reads `message.notification!`.
- On iOS a push received in the foreground shows twice: once from the system
  (`setForegroundNotificationPresentationOptions(alert: true)`) and once from the local copy.

The backend half of this change (the Firebase key on live, high priority, and the channel id) is
the maleva-backend change `fix-push-delivery`.

## What Changes

- On start-up the app creates the `com.kassapos.maleva.urgent` channel ("Maleva alerts") at
  `Importance.max` with sound. Foreground notices use the same channel (`AppGlobals.channelId`).
- The background handler is a vm entry point and is null-safe.
- In the foreground, the app shows the local copy only on Android.
- No API or model change.
