# Proposal

## Why

Backend change `mail-team-credit-and-corrections`: a colleague's reply now counts for a shared mailbox and is credited
to the colleague, and the Super Admin can correct who a mail was for. This client shows both, reading the Java fields
as sent.

## What Changes

- Whoever replied gets the credit (owner, 2026-10-12): a mail answered from a colleague's mailbox shows "answered by a
  colleague · replied by santhia@maleva.com.my" in the mailbox that received it, and is listed under the replier's
  "Needed a reply" as "handled for operation@maleva.com.my".
- Each mailbox shows "Includes 5 mails handled for other mailboxes (median 12 m)" when it did.
- Mails marked not needed are counted with the other not-theirs mails ("2 marked not needed").
- On every mail of the lists: **Wrong?** - "It needed this mailbox's reply", "It did not need its reply", or "Back to the
  rule" for a corrected mail, through `PUT /api/mail-monitor/response-report/mails/{id}/correction`; the report
  reloads; a corrected mail shows "Corrected". The server's message is shown when its script has not been run.
- The corrections review list stays on the web page.
