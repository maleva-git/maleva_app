## ADDED Requirements

### Requirement: Completed tab by month
The Completed tab SHALL show one month at a time (this month first, up to today; earlier months by ‹; no future month):
the total and count from the server, approved vs waiting, the sum per expense head with a Total row, and the payments,
newest first, searchable and filterable by head. A payment SHALL open its voucher or pay bill page.

#### Scenario: Last month
- **WHEN** the user taps ‹ on 30 Oct 2026
- **THEN** 1–30 Sep 2026 is asked and shown

### Requirement: Monthly report
The tab SHALL offer Monthly report (PDF): the server's printed report for the same days, opened in the phone's PDF
viewer; a refusal SHALL show its message.

#### Scenario: Print October
- **WHEN** the user taps Monthly report on October 2026
- **THEN** the PDF for 1–30 Oct opens
