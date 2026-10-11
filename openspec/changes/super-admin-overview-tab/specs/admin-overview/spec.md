## Purpose

The Super Admin's Overview tab: one first tab on the admin dashboard that gathers the day's numbers of
sales orders, job orders, mailboxes, incident reports, vessel planning, truck planning and truck location,
with a button to open each area.

## ADDED Requirements

### Requirement: Overview is the Super Admin's first tab
The admin dashboard SHALL show an Overview tab as its first tab when the signed-in user is the Super Admin
(role 100), and SHALL NOT show it to any other role. The other tabs SHALL keep their order after it.

#### Scenario: Super Admin opens the dashboard
- **WHEN** a role 100 user opens the admin dashboard
- **THEN** the first tab is Overview and it is the tab shown first

#### Scenario: Admin opens the dashboard
- **WHEN** a role 200 user opens the admin dashboard
- **THEN** there is no Overview tab and the first tab is SO, as before

### Requirement: Quick-open buttons
The Overview tab SHALL offer a button for SO, JO, Mailbox Monitor and IR Report that switches to that tab
of the same dashboard, and a button for Vessel Planning, Truck Planning and Truck Location that opens the
same screen the side menu opens. A screen button SHALL appear only when the user's menu has that entry, and
SHALL open the screen with the add, edit and delete rights that menu entry carries.

#### Scenario: Open job orders
- **WHEN** the Super Admin taps JO on the Overview tab
- **THEN** the dashboard switches to the JobOrders tab

#### Scenario: Screen not in the menu
- **WHEN** the user's menu has no Truck Location entry
- **THEN** the Overview tab shows no Truck Location button

### Requirement: Overall numbers
The Overview tab SHALL show, from the shared Java endpoints the app already uses: sale orders today and this
month with the month amount; job orders that are not finished, by status; total unread mail and overdue
mailboxes; incident reports still open in the last 30 days with their total amount; today's truck planning
jobs; vessel planning jobs in the next 7 days; and this week's trucks with today's location filled and
trucks in workshop. The numbers SHALL match the screen each one comes from for the same day.

#### Scenario: Numbers match their screens
- **WHEN** the Overview shows 12 unread mails and 2 overdue mailboxes
- **THEN** the Mailbox Monitor tab shows the same totals at the same moment

### Requirement: Each area loads and fails on its own
Each area of the Overview tab SHALL show its own loading state, and when its data cannot be loaded SHALL
show the server's message with a retry on that area only, leaving the other areas shown. Pull-to-refresh
and the refresh button SHALL reload every area.

#### Scenario: Mail monitor down
- **WHEN** the mail monitor endpoint fails and the others answer
- **THEN** the mail area shows the error with Retry and the other cards show their numbers

### Requirement: Layout and colours
The Overview tab SHALL use the app's existing colour tokens only, SHALL lay out in one column on a phone and
SHALL use the wider layout (four number cards across, sections in two columns) on a tablet.

#### Scenario: Tablet
- **WHEN** the Overview opens on a screen 600 points wide or more
- **THEN** the four number cards sit in one row and the sections in two columns
