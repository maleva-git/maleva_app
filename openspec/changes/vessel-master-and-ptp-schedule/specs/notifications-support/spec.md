## ADDED Requirements

### Requirement: A vessel change notice opens the vessel changes screen

A tapped push with data `type=VESSEL_ETA_CHANGED` SHALL open the "Vessel changes" screen: at once
when the app is open or in the background, and after the person reaches their dashboard when the
tap started the app. A foreground push of this type SHALL be shown through local notifications with
the type as payload, and tapping that SHALL open the same screen. Other push types SHALL keep their
current behaviour.

A vessel ETA notice SHALL never pass unnoticed: the app SHALL create Android channel
`com.kassapos.maleva.vessel` ("Vessel ETA alerts") at maximum importance with sound and a long
vibration (0, 1000, 500, 1000, 500, 1500, 500, 2000 ms), separate from the normal alert channel, and
the VIBRATE permission. While the app is open, a vessel notice SHALL be shown on that channel as
insistent (sound and vibration repeat until it is opened or swiped away).

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
(`/notifications?tab=vessel`), with a pulsing red badge of the open alerts, or an amber badge of the
unread vessel notices when no alert is open. The bell and ship SHALL load on show, when the app
returns to the foreground, on every push that arrives while the app is open, and after jobs are
updated or dismissed on Vessel changes.

The notifications page SHALL have two tabs, each with its own count in its label: **Vessel** (a ship;
a red badge of the open alerts, or, with none, an amber badge of the unread vessel notices) and
**Other** (a bell; a red badge of the unread other notices). It SHALL load the vessel notices
(`mine?group=vessel`), the other notices (`mine?group=other`) and the alerts at once; a list that
fails SHALL show its error with a retry on its own tab and SHALL not hide the other tab. `?tab=vessel`
or `?tab=other` SHALL pick the tab it opens on; without one it SHALL open on Vessel when alerts are
open, cannot be checked, or vessel notices are unread, and on Other otherwise. The Vessel tab SHALL
show, on top, an "Action needed"
section with one card per open vessel alert (the caller's own first, then team members' alerts
escalated to the caller): vessel and voyage, PTP's ETA (with "est."), the jobs not updated, since
when, the reminders sent, a "Team: <employee>" chip when `mine` is false, and "Update jobs", which
opens Vessel changes (on "My team" for a team alert). An alert SHALL stay pinned until the server no
longer returns it (jobs updated to PTP's ETA or dismissed). With no open alerts the section SHALL say
"No vessel alerts – all jobs match PTP"; when the alerts cannot be checked it SHALL say so with a
retry, never "no alerts". Below, "Vessel notices" SHALL list only the vessel kinds (`VESSEL_ETA_CHANGED`,
`VESSEL_LINK_NEEDED`, `PTP_SCHEDULE_STALE`). The
Other tab SHALL list every other notice and never a vessel notice (the app also filters by kind, in
case the server answers one there). In each tab the notices SHALL be grouped "Today" and "Earlier",
unread ones bold with a dot on a tinted background, with an icon per kind (a ship for
`VESSEL_ETA_CHANGED`, red for "Not handled", amber for "Reminder"; a document for `FORWARDING_*`; a
bell otherwise) and a relative time. Tapping a notice SHALL mark it read
(`PUT /api/employee-notifications/{id}/read`) in the tab that holds it and open it by kind and link
(Vessel changes in the link's scope; the forwarding list; nothing otherwise). Each tab SHALL have its
own "Mark all read" ("Mark all vessel notices read" on Vessel), which SHALL use
`PUT /api/employee-notifications/mine/read-all?group=vessel|other` and SHALL never mark the other
tab's notices. Each tab SHALL support pull-to-refresh, an error state with retry and its own empty
state ("No vessel ETA notices yet." / "No other notices yet.").

While the caller has open alerts of their own, the dashboard SHALL show a red, non-dismissible
banner at the top of its body ("2 vessel ETA changes need action", Open → Vessel changes); for team
members' alerts an amber banner ("1 team vessel alert not handled (SHALINI)", Open → Vessel changes
on "My team"). A banner SHALL disappear once the server no longer returns those alerts.

A tapped `VESSEL_ETA_CHANGED` push (or its local notification) whose `link` carries `scope=team`
SHALL open Vessel changes on "My team".

The app SHALL read the Java responses as they are; no backend endpoint or response is changed for
this.

#### Scenario: Push swiped away
- **WHEN** a vessel ETA push for 2 of the employee's jobs was swiped away and the employee opens the app
- **THEN** the dashboard shows the red banner "1 vessel ETA change needs action", the ship button beside the bell shows the pulsing red badge "1", and the notifications page's Vessel tab shows the alert pinned on top with "2 jobs not updated"

#### Scenario: Alert handled
- **WHEN** the employee updates the jobs to PTP's ETA on Vessel changes
- **THEN** the bell, the banner and the pinned card refresh and the alert is gone

#### Scenario: Leader escalation
- **WHEN** SHALINI's alert is not handled in time and her team leader opens the notifications page
- **THEN** the leader sees the alert with a "Team: SHALINI" chip, the dashboard shows the amber team banner, and "Update jobs" opens Vessel changes on "My team"

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

#### Scenario: Mark all read on one tab only
- **WHEN** the employee taps "Mark all vessel notices read" on the Vessel tab
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
alert SHALL show its own pinned card "Pick the PTP voyage: job <jobNo>" with the job's vessel name and
PTP's suggested voyage and arrival ("No PTP voyage suggested" when null), "Open job" (the sale order
screen; hidden without `saleOrderId`) and "Not this vessel", which SHALL call
`POST /api/vessel-changes/alerts/{id}/close`, drop the card and reload the bell, banner and page, and
on a refusal show the server's message in a snackbar and keep the card. An ETA alert with
`unassigned: true` SHALL show a "No employee" badge, and "Update jobs" SHALL open the job when the
alert names one. The dashboard banner SHALL show the caller's own LINK alerts on their own row ("Pick
the PTP voyage: job <jobNo>", opening that job; for several "<n> jobs need their PTP voyage picked",
opening the Vessel tab), not counted as ETA changes.

#### Scenario: Link notice tapped
- **WHEN** the employee taps the push "Pick the PTP voyage: job MY002605357" (`link=/sale-order/edit/51234`)
- **THEN** the job's sale order screen opens, and the push vibrated long on the vessel channel

#### Scenario: PTP schedule stale
- **WHEN** a Super Admin taps "PTP schedule not updating since 13 Oct 10:05"
- **THEN** Vessel changes opens, where "Read PTP now" can be pressed

#### Scenario: Not this vessel
- **WHEN** the employee presses "Not this vessel" on the LINK card and the server answers true
- **THEN** the card goes and the bell and banner reload; when the server refuses, a snackbar shows its message and the card stays

#### Scenario: Job without employee
- **WHEN** a Super Admin opens the Vessel tab with an ETA alert whose `unassigned` is true for job 51300
- **THEN** the card shows "No employee" and "Update jobs" opens that job
