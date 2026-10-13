## ADDED Requirements

### Requirement: Show who the mail was for
The reply report SHALL show for each mailbox how many customer mails needed its reply and how many did not, by reason,
when the server sends the sorting, and SHALL show nothing extra when it does not.

#### Scenario: Sorted mailbox
- **WHEN** the server sends sorting 100 customer mails, 10 needed a reply, 60 copied in, 20 to a colleague, 10 answered by a colleague
- **THEN** the mailbox shows "10 of 100 customer mails needed a reply" and the 90 others with their reasons

### Requirement: Open the mails behind the numbers
The Super Admin SHALL be able to open, for a mailbox, the list of mails that needed its reply and the list of mails
that did not, each with time, sender domain, reply time or "No reply", and the reason; a mail SHALL open read-only.

#### Scenario: Not theirs list
- **WHEN** the Super Admin opens "Not theirs" of shalini@
- **THEN** each mail shows "Copied in", "Written to a colleague" or "Answered by a colleague"
