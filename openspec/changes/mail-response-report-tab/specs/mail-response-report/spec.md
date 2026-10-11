## Purpose

The Super Admin's Mail Response tab: how fast each monitored mailbox replies to customer mail against its
target, as the web's Mail response report shows it, with an AI statement that can be read aloud.

## ADDED Requirements

### Requirement: Super Admin tab
The admin dashboard SHALL show a Mail Response tab after Mailbox Monitor for the Super Admin (role 100) only.

#### Scenario: Super Admin
- **WHEN** a role 100 user opens the admin dashboard
- **THEN** the tab after Mailbox Monitor is Mail Response

#### Scenario: Admin
- **WHEN** a role 200 user opens the admin dashboard
- **THEN** there is no Mail Response tab

### Requirement: Same numbers as the web for a date range
The tab SHALL read the shared Java response report for the chosen range (Today, Last 7 days - the default -,
This month, or a custom From/To in Malaysia dates) and SHALL show the same numbers as the web page for that
range: the fastest replier, the mailbox needing attention, the whole company, customer mails, replied
within target, average reply time, still waiting, mail per day and every mailbox with its band.

#### Scenario: Default range
- **WHEN** the tab opens on 11 Oct 2026
- **THEN** it shows 5 Oct 2026 to 11 Oct 2026 (7 days) and the web shows the same numbers for those dates

#### Scenario: Bands
- **WHEN** a mailbox replied to 75% of customer mail within its target
- **THEN** it shows Close; 90% or more shows On target, under 70% Behind, no mail No mail, and no Sent
  folder No sent mail found

### Requirement: Ordering
The mailbox list SHALL be shown slowest first by default and fastest first on request, using the web's order.

#### Scenario: Switch order
- **WHEN** the user picks Fastest first
- **THEN** the mailbox with the highest share within target is first and mailboxes without numbers stay last

### Requirement: Late mail
Tapping a mailbox SHALL show its slowest replies and its mails still waiting for the range, and tapping one
of them SHALL open that mail read-only.

#### Scenario: Waiting mail
- **WHEN** the user taps a mailbox with 2 mails waiting
- **THEN** the sheet lists them under Still waiting with "No reply", oldest first

### Requirement: AI summary read aloud
The tab SHALL ask the server for the AI summary only when the user taps Write summary, SHALL show it as
points, and SHALL read it aloud on the device when the user taps Read aloud, stopping on Stop or when the
tab is left. No mail content is sent; the tab says so.

#### Scenario: Read aloud
- **WHEN** the summary is shown and the user taps Read aloud
- **THEN** the device speaks the summary and the button changes to Stop

#### Scenario: AI not available
- **WHEN** the server answers the summary with an error
- **THEN** the card shows the server's message and the rest of the report stays

### Requirement: PDF
The tab SHALL open the server's PDF report for the shown range on the device, and SHALL share it with the
device's share sheet.

#### Scenario: Share
- **WHEN** the user taps Share PDF
- **THEN** the device share sheet opens with the report PDF for the shown range

### Requirement: Errors
When the report cannot be loaded the tab SHALL show the server's message with Retry; a 403 SHALL say only the
Super Admin can see the report and a 503 that the monitor is not set up.

#### Scenario: Not set up
- **WHEN** the server answers 503
- **THEN** the tab shows the server's message and no numbers
