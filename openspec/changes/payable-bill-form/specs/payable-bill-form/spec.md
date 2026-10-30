## ADDED Requirements

### Requirement: Bill form saves as the web
The bill form SHALL save with `POST /api/bills/save` and the web's body (dates `yyyy-MM-ddT00:00:00`, CREDIT by
default, status Completed by default, invoice no. upper case, amounts = Σ qty × rate + tax rounded once, actual
amount = total × the supplier's currency rate, only items with an account, the PO link when pushed). It SHALL refuse,
listing the reasons in the web's order: no supplier, term, invoice no. or expense type; an item with an amount but no
account; no item; an item with quantity 0; a new bill whose invoice no. is on another bill; an edited bill whose total
is below what is already paid.

#### Scenario: Total below paid
- **WHEN** a bill with RM 50 already paid is edited to RM 10
- **THEN** Save says the total is below what is already paid and nothing is saved

### Requirement: Push to Bill
A purchase order's page SHALL offer Push to Bill. The bill SHALL be filled from the PO (supplier, invoice, dates,
term, expense type, Cash/Credit, truck, driver, remarks, items), with the supplier's current currency rate, and the
PO's files SHALL be offered with ticks; the ticked ones SHALL be copied to the bill after it is saved. The confirm
SHALL say the PO will be marked INVOICE MADE.

#### Scenario: One PO file left out
- **WHEN** the PO has a PDF and a photo and the user unticks the photo
- **THEN** after the save only the PDF is copied to the bill

### Requirement: Same bill already saved
When the server answers that the bill already exists, the app SHALL say "already in the system as <number>", save
nothing new and upload no file.

#### Scenario: Duplicate
- **WHEN** the save answers duplicate for BIL2610/001
- **THEN** the message names BIL2610/001 and no file is copied or uploaded

### Requirement: Read a bill with AI
A new bill (not pushed) SHALL offer Read with AI from a photo; the answer fills supplier (then its term, currency and
due date as if chosen), invoice no. (upper case), dates, a listed expense type, remarks (the document's or "PO x"),
and items (upper case, qty 1 by default, account by id or code). A "Filled by AI: please check" banner SHALL show with
the warnings; nothing is saved until the person presses Save.

#### Scenario: Supplier matched
- **WHEN** the AI matches supplier 9
- **THEN** the form shows that supplier with its payment term and due date
