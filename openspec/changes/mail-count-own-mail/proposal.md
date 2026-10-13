# Proposal

## Why

The owner (2026-10-12) wants an employee judged only on the mails that need their reply, and every number provable.
The backend change `mail-count-own-mail` now counts only those mails and lists the mails behind the numbers.

## What Changes

- The app Mail Response tab reads the new Java fields as sent: `sorting` per mailbox and company (customer mails, needed a reply,
  copied in, written to a colleague, answered by a colleague) and `relevance` per listed mail.
- Each mailbox shows "10 of 100 customer mails needed a reply · 90 did not (60 copied in, 20 to a colleague, 10
  answered by a colleague)".
- The mailbox view gets three lists: Late (as today), **Needed a reply** and **Not theirs** with the reason of each
  mail, from `GET /api/mail-monitor/response-report/mails`; a mail opens read-only as today.
- No backend change for this screen; same shared Java API as the other client.
