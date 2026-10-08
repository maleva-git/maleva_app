## Decisions

- Model fields read as Java sends them (`mailboxes[].address|unread|oldestUnreadAt|level|status`, `total`,
  `latestNotice`). Cubit `MyUnreadMailCubit` with `sl` registration; refresh on open, on pull-to-refresh and when
  a `MAIL_UNREAD` push arrives.
- Tap routing: one handler for `onMessageOpenedApp`, `getInitialMessage` and the local notification's payload;
  only `type=MAIL_UNREAD` is routed, other pushes keep today's behaviour.
- No dashboard bar (removed 2026-10-08, owner's decision). A notice that starts the app is opened by a router listener (`installPendingPushRouteOpener`) once an employee dashboard shows, after sign-in.
