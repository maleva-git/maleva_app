## ADDED Requirements

### Requirement: Email inbox on the shared API

The Email Inbox tab and TransportDB's mail section SHALL read an employee's unanswered mail from
`/api/email-inboxes/unanswered`, and SHALL keep ticked mails through `/api/email-inboxes/entries`,
with the session token.

#### Scenario: Keep a mail
- **WHEN** a mail is ticked and saved
- **THEN** the app posts it as an active entry of the employee, and it is not listed again
