# Proposal

## Why

Backend change `booking-speed-insights` adds booking statistics, an AI summary and a waiting-booking list and alert.
The owner (2026-10-12) wants them on the Booking speed page, with the focus on clear statistics and the AI.

## What Changes

The Booking speed page (same shared Java API as the other client) gains:
- **Booking mails waiting now**: customer, mailbox, arrival, waiting office minutes (rose past the alert minutes),
  "alerted" when the owners got the push; a note when the server's script has not run.
- **AI summary of booking speed** (`POST /api/mail-monitor/booking-speed/summary`): written on request, in en / ta / ms
  / zh / es / hi, read aloud; points coloured by subject (Team, Employee, Slow spot, Data to fix, Waiting now) with the
  employee's name, "Why" and the suggestion; "plain figures" when the server replaced the AI's words.
- **Statistics**: where bookings get slow (cards with the median and "2.7x the team"), the spread (within 30 min ...
  over 4 h, with share), by arrival time, by weekday, top customers (bars of the median; slow groups in rose), and
  bookings per day with each day's median.

## Owner's follow-up (2026-10-12, from the live page)

- The waiting list shows the sender's **full address** (new column `MailResponse.BookingSender`, kept only for
  booking-like mails; added to `db/mail-booking-insights.sql` - run it again) and the alert names it too.
- One mail that reached several mailboxes (for example eswaran@, naga@, puviyarasu@) is **one row** listing them all.
- A waiting mail **opens read-only** (it stays unread) from the list.
- Web: the jobs grid **scrolls inside** itself with the header fixed (no "show all" paging).
- **The owner checks each booking-like mail** (2026-10-12): the waiting list shows its **subject** (new column
  `MailResponse.BookingSubject`, booking-like mails only) and two buttons - **Booking** / **Not a booking** (columns
  `BookingConfirmed`, `BookingConfirmedBy`, `BookingConfirmedAt`; `PUT /api/mail-monitor/booking-speed/mails/{id}/booking`,
  every copy of the mail, audited, undo). "Not a booking" leaves the waiting list, the alert and the booking numbers.
  New card **Booking mails**: mails, confirmed, not checked, median first reply, not a booking, and how often the word
  rule was right; in the AI facts too (prompt b2).
- **Confirmed bookings without a sale order** (2026-10-12): booking mails the Super Admin confirmed that no reply with
  a job number has answered yet (no `MailBooking` row for them), last 30 days, one per mail with its owners, waiting
  office minutes and whether it got a reply without a job number; a per-person summary (owners of the mailboxes, count,
  oldest) that filters the list; in the AI facts (prompt b3). A sale order opened without replying the job number still
  counts as pending - the reply is the only link between a mail and its sale order.
- **Sale order pending alert** (2026-10-12): a confirmed booking with no job-number reply after
  `mail.monitor.booking.sale-order-alert-minutes` (120) office minutes sends one push to its mailbox's owners, during
  office hours, without the subject ("Sale order pending 2 h 05 m - A confirmed booking from ops@gac.com in cs1@... has no
  job number yet."); column `MailResponse.SaleOrderAlertAt` in `db/mail-booking-insights.sql`; the pending list marks
  "alerted" and says after how long the alert goes out.
