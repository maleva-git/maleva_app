## ADDED Requirements

### Requirement: Office-hours report in the app
The Mail Response tab SHALL show the office hours, each mailbox's category and reasons, after-office arrivals, the
backend's spotlight, and the AI summary as points linked to mailboxes; a Not enough data mailbox SHALL NOT be shown
as slow.

#### Scenario: Few mails
- **WHEN** nancy@ is Not enough data with reason TOO_FEW_MAILS
- **THEN** its card is grey with "Only 2 mails", and it is not in Needs attention
