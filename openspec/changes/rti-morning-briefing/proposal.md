## Why

The backend (maleva-backend change `rti-morning-briefing`) sends each forwarding agent a 06:00 bell + push notice,
kind `RTI_STOPS_TODAY`, listing the trucks coming to their route stops today. The app must open the right screen.

## What Changes

- `features/dashboard/forwarding_agent_dashboard/push_route.dart`: `rtiActivitiesPath = /rti_activities`,
  `RtiActivitiesPage` (the existing RTI Activities tab on its own page), `rtiActivitiesRouteForType`.
- `core/router/app_router.dart`: the `/rti_activities` route.
- `features/mail_monitor/mine/push_route.dart` (push tap, local notification) and
  `features/notifications/notification_routes.dart` (bell row): `RTI_STOPS_TODAY` opens RTI Activities.
- No change to the Java API (read as it is). Test: `test/features/dashboard/rti_morning_notice_route_test.dart`.

## Update 2026-10-23: alarm + change notice

- The 06:00 notice (`RTI_STOPS_TODAY`) rings: channel `com.kassapos.maleva.rti.alarm` (AppGlobals.rtiAlarm*,
  LocalNotificationService.rtiAlarmChannel / rtiAlarmDetails), 30-second tone `res/raw/rti_alarm.m4a` (kept by
  `res/raw/keep.xml`), iOS `Runner/rti_alarm.caf` (in the Runner resources build phase). Only this notice rings.
- `RTI_STOPS_CHANGED` (an RTI save moved the agent's stop today) is a normal notice and opens RTI Activities.

## Update 2026-10-23: "Got it"

- `view/morning_alarm_banner.dart` at the top of RTI Activities: when today's alarm was sent and not answered, an
  orange card "Today: 4 stops. Tap Got it ..." with a **Got it** button (`RtiApi.morningAlarmToday` /
  `morningAlarmGotIt`, Java `/api/rti-morning-briefing/today[/ack]` read as it is). After the tap: "Today's trucks
  seen at 06:04". Nothing shown when no alarm was sent or the read fails. Test `morning_alarm_banner_test.dart`.
