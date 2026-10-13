## ADDED Requirements

### Requirement: A vessel change notice opens the vessel changes screen

A tapped push with data `type=VESSEL_ETA_CHANGED` SHALL open the "Vessel changes" screen: at once
when the app is open or in the background, and after the person reaches their dashboard when the
tap started the app. A foreground push of this type SHALL be shown through local notifications with
the type as payload, and tapping that SHALL open the same screen. Other push types SHALL keep their
current behaviour.

A vessel ETA notice SHALL never pass unnoticed: the app SHALL create Android channel
`com.kassapos.maleva.vessel.vibrate` ("Vessel alerts") at maximum importance with a long vibration
(0, 1000, 500, 1000, 500, 1500, 500, 2000 ms) and NO sound (owner, 2026-10-13: "only vibration is enough"),
separate from the normal alert channel, delete the earlier vessel channels `com.kassapos.maleva.vessel` and
`com.kassapos.maleva.vessel.alarm`, and hold the VIBRATE permission. While the app is open, a vessel notice
SHALL be shown on that channel as insistent (the vibration repeats until it is opened or swiped away). On
iPhone, which vibrates only together with a sound, vessel pushes keep the default sound (vibration only when
the ringer switch is on silent).

#### Scenario: Phone in a pocket
- **WHEN** a vessel ETA notice arrives while the app is closed
- **THEN** it pops up on the Vessel ETA alerts channel and vibrates long

#### Scenario: Background tap
- **WHEN** the app is in the background and the user taps "MAERSK RIO NEGRO 641S: ETA moved ..."
- **THEN** the app opens the Vessel changes screen

#### Scenario: Cold start
- **WHEN** the tap starts the app and the user signs in
- **THEN** the Vessel changes screen opens once the dashboard shows

#### Scenario: Other notices unchanged
- **WHEN** a `MAIL_UNREAD` or `FORWARDING_*` notice is tapped
- **THEN** it opens the same screen as before this change

### Requirement: In-app notifications with vessel alerts pinned until handled

A vessel ETA notice SHALL not be lost when its push is swiped away. Vessel ETA notices SHALL be kept
separate from every other notice and never mixed with them (owner, 2026-10-13; the web has its own
ship bell). Every employee dashboard with an app bar SHALL show a bell that opens the notifications
page on its Other tab (`/notifications?tab=other`), with a red badge counting only the other notices
(`unreadCount` of the shared `GET /api/employee-notifications/mine?group=other`). Beside it, while
`GET /api/vessel-changes/alerts` returns open alerts or vessel notices are unread
(`mine?group=vessel`), the dashboard SHALL show a ship button that opens the Vessel tab
(`/notifications?tab=vessel`), with a solid red badge of the open alerts, or an amber badge of the
unread vessel notices when no alert is open; the badge SHALL NOT pulse, glow or animate (owner,
2026-10-13: calm like the web's vessel bell, "not make noise"). The bell and ship SHALL load on show, when the app
returns to the foreground, on every push that arrives while the app is open, and after jobs are
updated or dismissed on Vessel changes.

The notifications page SHALL have two tabs, each with its own count in its label: **Vessel** (a ship;
a red badge of the open alerts, or, with none, an amber badge of the unread vessel notices) and
**Other** (a bell; a red badge of the unread other notices). It SHALL load the vessel notices
(`mine?group=vessel`), the other notices (`mine?group=other`) and the alerts at once; a list that
fails SHALL show its error with a retry on its own tab and SHALL not hide the other tab. `?tab=vessel`
or `?tab=other` SHALL pick the tab it opens on; without one it SHALL open on Vessel when alerts are
open, cannot be checked, or vessel notices are unread, and on Other otherwise.

The Vessel tab SHALL look as calm as the web's vessel bell (owner, 2026-10-13; web `VesselAlertList`,
`VesselAlertRow`, `VesselLinkAlertRow`, `VesselNoticeList`, `VesselNoticeRow`): no banner, no big
tinted card, no shadow, no icon box, no filled button, no animation. On top, an "Action needed"
section: a small grey heading in normal case with a small grey count, then compact rows on the page's
surface split by thin dividers, the caller's own alerts first, then team members' alerts escalated to
the caller. A row's only colour SHALL be a thin (3 px) left border: red for the caller's own alert,
amber for a team member's, blue for a LINK alert. An ETA row SHALL show, on line 1, the vessel and
voyage in semibold ("EBBA MAERSK 640W") with a small neutral "No employee" label for jobs without an
employee, and the sent time muted on the right ("15:42" today, else "13 Oct 15:42"); on line 2, in
small grey text joined by " · ", "PTP ETA <d MMM HH:mm>" (with " (est.)"; "not given" without one), "<n>
job(s) not updated" and, for a team alert only, the team member's name (nothing when the name is
empty), at most two lines ending with "…". Tapping an ETA row SHALL open Vessel changes (on "My team"
for a team alert), or the job when the alert names one for jobs without employee. The first 5 rows
SHALL show, then a "Show all N" text button ("Show fewer" to collapse). An alert SHALL stay pinned
until the server no longer returns it (jobs updated to PTP's ETA or dismissed). With no open alerts
the section SHALL say "No vessel alerts – all your jobs match PTP." in a muted line; when the alerts
cannot be checked it SHALL say so with a retry, never "no alerts".

Below, "Vessel notices" (a small grey heading, "<n> unread" or "nothing unread" from the server's
count, and "Mark all read" while something is unread) SHALL list only the vessel kinds
(`VESSEL_ETA_CHANGED`, `VESSEL_LINK_NEEDED`, `PTP_SCHEDULE_STALE`, `PHONE_PUSH_DOWN`): the unread ones
only, at most 5, with a "Show all" / "Show unread only" toggle when more exist, "Nothing unread." when
none is unread and "No vessel notices yet." when there are none. Each notice row SHALL show a small
blue dot while unread, a small grey ship (red only for `PTP_SCHEDULE_STALE` and `PHONE_PUSH_DOWN`), the
title in medium weight while unread and normal once read, one line of body ending with "…", and a
muted relative time. A "Not handled: …" or "Still not handled: …" notice SHALL be left out while a team
alert row for a vessel named in its title is shown (web `withoutShownEscalations`); the tab's and the
ship's counts stay the server's.

The Other tab SHALL list every other notice and never a vessel notice (the app also filters by kind,
in case the server answers one there), grouped "Today" and "Earlier", unread ones bold with a dot on a
tinted background, with an icon per kind (a document for `FORWARDING_*`; a bell otherwise) and a
relative time. Tapping a notice SHALL mark it read
(`PUT /api/employee-notifications/{id}/read`) in the tab that holds it and open it by kind and link
(Vessel changes in the link's scope; the forwarding list; nothing otherwise). Each tab SHALL have its
own "Mark all read" (its tooltip "Mark all vessel notices read" on Vessel), which SHALL use
`PUT /api/employee-notifications/mine/read-all?group=vessel|other` and SHALL never mark the other
tab's notices. Each tab SHALL support pull-to-refresh, an error state with retry and its own empty
state ("No vessel notices yet." / "No other notices yet."). The Vessel tab SHALL fit a 360-wide phone
with long vessel, job and team member names without overflow.

The dashboards SHALL NOT show a vessel alert banner: the bell and the ship button are enough (owner,
2026-10-13).

A tapped `VESSEL_ETA_CHANGED` push (or its local notification) whose `link` carries `scope=team`
SHALL open Vessel changes on "My team".

The app SHALL read the Java responses as they are; no backend endpoint or response is changed for
this.

#### Scenario: Push swiped away
- **WHEN** a vessel ETA push for 2 of the employee's jobs was swiped away and the employee opens the app
- **THEN** the ship button beside the bell shows a solid red badge "1" (no banner, no animation), and the notifications page's Vessel tab shows the alert row pinned on top with "2 jobs not updated"

#### Scenario: Alert handled
- **WHEN** the employee updates the jobs to PTP's ETA on Vessel changes
- **THEN** the bell and the pinned row refresh and the alert is gone

#### Scenario: Leader escalation
- **WHEN** SHALINI's alert is not handled in time and her team leader opens the notifications page
- **THEN** the leader sees an amber-bordered row ending with "· SHALINI", the "Not handled: …" notice for that vessel is not listed under it, and tapping the row opens Vessel changes on "My team"

#### Scenario: Team push tapped
- **WHEN** the leader taps a push with `link=/vessel-changes?scope=team`
- **THEN** Vessel changes opens on "My team"

#### Scenario: Notice tapped
- **WHEN** the employee taps an unread "Reminder: ..." notice
- **THEN** it is marked read, the Vessel tab's and the ship's unread count drops (the bell's does not), and Vessel changes opens

#### Scenario: Alerts cannot be checked
- **WHEN** `GET /api/vessel-changes/alerts` fails
- **THEN** the page says the vessel alerts could not be checked, offers a retry, and still shows the notices

#### Scenario: Vessel and other notices in separate tabs
- **WHEN** the employee has 1 open vessel alert, 2 unread vessel ETA notices and 3 unread forwarding notices, and taps the bell
- **THEN** the bell's badge shows 3, the ship button's badge shows 1, the page opens on the Other tab with the 3 forwarding notices and no vessel notice, the Vessel tab label shows a red 1 and the Other tab label a red 3

#### Scenario: Calm Vessel tab
- **WHEN** the employee has 7 open alerts and 8 vessel notices, 6 of them unread
- **THEN** the Vessel tab shows 5 compact alert rows with thin coloured left borders and "Show all 7", then the first 5 unread notices with "Show all"; nothing pulses, glows or uses a filled button

#### Scenario: Mark all read on one tab only
- **WHEN** the employee taps "Mark all read" on the Vessel tab
- **THEN** only the vessel notices are marked read (`read-all?group=vessel`), the Vessel tab's unread count clears, and the Other tab's notices and count stay as they were

### Requirement: Vessel link and PTP schedule notices

The vessel notices SHALL be the kinds `VESSEL_ETA_CHANGED`, `VESSEL_LINK_NEEDED` and
`PTP_SCHEDULE_STALE` (owner, 2026-10-13). All three SHALL be shown only on the Vessel tab and counted by
the ship button, never on the Other tab (the app also filters by kind), and a push of any of them
(`data['type']`) SHALL be shown on the vessel channel with the long vibration. A tapped vessel notice,
push or local notification SHALL open by its React link: `/sale-order/edit/{id}` (or, for a notice
without that link, its `SALE_ORDER` ref) opens the app's sale order screen of that job
(`/sale_order_edit/{id}`, `SalesOrdersAdd`); `/ptp-schedule` and every `PTP_SCHEDULE_STALE` open Vessel
changes (which has "Read PTP now"); `/vessel-changes` opens Vessel changes in the link's scope; a
`VESSEL_LINK_NEEDED` without a job opens the Vessel tab. A `VESSEL_ETA_CHANGED` for jobs without an
employee (to Super Admins) with a `/sale-order/edit/{id}` link SHALL open that job.

`GET /api/vessel-changes/alerts` SHALL be read with `kind` (`ETA` | `LINK`; `ETA` when missing),
`saleOrderId`, `jobNo` and `unassigned` (false when missing), and a nullable `ptpVesselCallId`. A LINK
alert SHALL show its own pinned row (blue left border): line 1 "Pick PTP voyage · job <jobNo>" with the
sent time; line 2 "<job's vessel> → <voyage>, ETA <d MMM HH:mm> (est.)" or "<job's vessel> · No PTP
voyage suggested" when no voyage is suggested (the team member's name last for a team alert); and two
small text buttons, "Open job" (the sale order screen; hidden without `saleOrderId`) and "Not this
vessel", which SHALL call `POST /api/vessel-changes/alerts/{id}/close` (a small spinner while it runs),
drop the row and reload the bell and page, and on a refusal show the server's message in a snackbar
and keep the row. An ETA alert with `unassigned: true` SHALL show a small neutral "No employee" label,
and its row SHALL open the job when the alert names one.

#### Scenario: Link notice tapped
- **WHEN** the employee taps the push "Pick the PTP voyage: job MY002605357" (`link=/sale-order/edit/51234`)
- **THEN** the job's sale order screen opens, and the push vibrated long on the vessel channel

#### Scenario: PTP schedule stale
- **WHEN** a Super Admin taps "PTP schedule not updating since 13 Oct 10:05"
- **THEN** Vessel changes opens, where "Read PTP now" can be pressed

#### Scenario: Not this vessel
- **WHEN** the employee presses "Not this vessel" on the LINK row and the server answers true
- **THEN** the row goes and the bell reloads; when the server refuses, a snackbar shows its message and the row stays

#### Scenario: Job without employee
- **WHEN** a Super Admin opens the Vessel tab with an ETA alert whose `unassigned` is true for job 51300
- **THEN** the row shows a "No employee" label and tapping it opens that job
