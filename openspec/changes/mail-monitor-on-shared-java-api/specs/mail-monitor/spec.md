## ADDED Requirements

### Requirement: Super Admin Mailbox Monitor tab

The admin dashboard SHALL show a "Mailbox Monitor" tab, as the 4th tab (after Invoice), only when the logged-in role is 100
(Super Admin). It SHALL list every mailbox from `GET /api/mail-monitor/mailboxes` with its address,
people, unread count, oldest unread age and a status shown by colour, words and icon, with overdue
mailboxes first, plus the company summary.

#### Scenario: Super Admin opens the tab
- **WHEN** a role 100 user opens the admin dashboard and taps Mailbox Monitor
- **THEN** the summary and one card per mailbox are shown, with `cs1@maleva.com.my` marked Overdue when its oldest unread is past its red limit

#### Scenario: Admin does not see it
- **WHEN** a role 200 user opens the admin dashboard
- **THEN** there is no Mailbox Monitor tab

#### Scenario: Server refuses
- **WHEN** the server answers 403 or 503
- **THEN** the tab shows the server's message and no mailbox data

### Requirement: Refresh without live push

The tab SHALL reload the list every 60 seconds while it is open and on pull-to-refresh, and SHALL
offer "Check now", which starts a server check.

#### Scenario: Check already running
- **WHEN** Check now is tapped while a check runs
- **THEN** the server's 409 message is shown and nothing else changes

### Requirement: Mailbox detail and reminder

Tapping a mailbox SHALL open its detail with the latest five unread mails (sender, subject, full
date and time), its people and limits, and SHALL allow emailing its active owners through
`POST …/remind` when there is unread mail.

#### Scenario: Reminder too soon
- **WHEN** the server answers 429
- **THEN** the message saying when the next reminder is allowed is shown

#### Scenario: No owner
- **WHEN** the mailbox has no active owner
- **THEN** no reminder button is shown and a hint says to add an owner on the web

### Requirement: All unread mail

The detail SHALL open a list of all unread mail, 50 at a time, newest first, with server-side
search, from `GET …/unread`.

#### Scenario: Scroll to older mail
- **WHEN** the user scrolls to the end of the first 50
- **THEN** the next page is requested with `page=1` and appended

#### Scenario: Search
- **WHEN** "LYRIC POET" is searched
- **THEN** the list restarts at page 0 with `q=LYRIC POET`

### Requirement: Open a mail as text

Tapping a mail SHALL open it from `GET …/messages/{uid}` with From, To, Cc, sent and received date
and time, attachment names and sizes, and the body as plain text (the HTML body converted to text
when there is no text part). Nothing inside the mail SHALL be loaded or run, and attachments SHALL
NOT be downloadable.

#### Scenario: HTML-only mail
- **WHEN** a mail has only an HTML body with a script and a remote image
- **THEN** its readable text is shown and the script and image are not shown or loaded

#### Scenario: Mail gone
- **WHEN** the server answers 404
- **THEN** "This mail is no longer in the inbox" is shown

### Requirement: Nothing kept on the device

Mailbox previews, pages and opened mails SHALL be kept only in screen state. They SHALL NOT be
written to preferences, files or logs.

#### Scenario: Leave the screen
- **WHEN** the user leaves the mail page
- **THEN** the mail content is gone from memory and nothing was stored on the device
