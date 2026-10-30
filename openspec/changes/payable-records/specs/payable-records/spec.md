## ADDED Requirements

### Requirement: Records tab lists payable records
The Payable dashboard SHALL have a Records tab, after PO & Vouchers, in place of the Bills tab. It SHALL show one
record type at a time (PO, Bill, Pay bill, Voucher, Petty cash, Levy) for a period (This month, Last month, chosen
dates), newest first, from the same Java endpoints the web uses, with the number of records, their total and how many
have files. Each card SHALL show supplier / pay to / employee / truck, amount, number, date, status and file count.

#### Scenario: Payable user opens Records
- **WHEN** a role 1100 user opens Records
- **THEN** this month's purchase orders are listed newest first with their total

#### Scenario: Switch to vouchers
- **WHEN** the user taps Voucher
- **THEN** this period's payment vouchers are asked and listed

### Requirement: Search and status filter
The tab SHALL filter the loaded list by a search on number, party, description or type, and by a status chip built
from the statuses in the list (an empty status reads "Pending", ACCEPETED reads "Accepted").

#### Scenario: Only rejected
- **WHEN** the user taps the Rejected chip
- **THEN** only rejected records stay in the list and the total follows

### Requirement: Record detail with lines and files
Tapping a card SHALL open the record: amount, status, party, number and date at the top; its facts (empty ones left
out); its lines with the total; and its files from `/api/attachments` (photos open full screen with zoom and swipe;
PDFs and other files open in the phone's viewer; Share). Details and files SHALL load on their own and each SHALL
show Retry when it fails. A pay bill SHALL list only the bills it paid.

#### Scenario: Voucher with a PDF
- **WHEN** the user opens a voucher whose folder has one PDF
- **THEN** the PDF is listed under Files and opens in the phone's viewer

#### Scenario: Files cannot be read
- **WHEN** the file list fails
- **THEN** the details and lines still show and Files shows the message with Retry
