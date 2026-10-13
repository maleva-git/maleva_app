# Design

- **One channel for every notice.** The manifest default, `AppGlobals.channelId` and the
  backend's `maleva.firebase.android-channel-id` all hold the same id. A channel's importance can
  only be set when it is created. The new id has never been created on any phone (Firebase does
  not create a missing default channel; it uses its fallback channel instead), so it is created
  at `Importance.max`. The old foreground channel "MALEVA" stays on phones that already have it,
  unused.
- The channel is created in `main()` right after `onBackgroundMessage`, before any page. Creating
  it again changes nothing. A failure only logs.
