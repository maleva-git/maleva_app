## ADDED Requirements

### Requirement: Show team credit
The report SHALL show who replied to a mail answered from a colleague's mailbox, the mails a mailbox handled for other
mailboxes, and per mailbox how many it handled with their median, when the server sends them.

#### Scenario: Replied by a colleague
- **WHEN** a mail of operation@ was answered from santhia@ in 12 office minutes
- **THEN** operation@'s list shows "replied by santhia@maleva.com.my" and santhia@'s list shows the mail "handled for operation@maleva.com.my" with 12 minutes

### Requirement: Correct a mail
The Super Admin SHALL be able to mark a listed mail as needed or not needed by the mailbox, or send it back to the rule,
and the report SHALL show the new numbers.

#### Scenario: Mark not needed
- **WHEN** the Super Admin chooses "It did not need its reply" on a counted mail
- **THEN** the correction is sent and the report reloads with the mail under not theirs, marked "Corrected"
