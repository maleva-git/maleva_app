## ADDED Requirements

### Requirement: Voucher form saves as the web
The voucher form SHALL save with `POST /api/payment-voucher-masters/save` and the web's body (date `yyyy-MM-dd`,
payment by = bank id, status '' = send for approval, amount = Σ lines, each line's account, classification and links).
It SHALL refuse, listing the reasons in the web's order: no expense head, no bank, no line, a line without an account,
an amount below zero.

#### Scenario: No bank
- **WHEN** the user saves without choosing the bank
- **THEN** "Choose the bank (payment by)" is shown and nothing is saved

### Requirement: Push to PV
A purchase order's page SHALL offer Push to PV. The voucher SHALL carry the PO link, pay to, pay from, expense head and
one line per PO line with its amount; the person chooses the bank, reference and status. The PO's files SHALL be offered
with ticks and the ticked ones copied after the save; the confirm SHALL say the PO will be marked PAYMENT COMPLETED.

#### Scenario: Pay a PO
- **WHEN** the user pushes PO000000077 (RM 636) to a voucher, chooses the bank and saves
- **THEN** the voucher is saved with that PO link and RM 636, and the PO's ticked file is copied to the voucher

### Requirement: Linked lines are kept
Editing a voucher SHALL send every line back with its levy entry, pending payment and sub-expense links; a linked line
SHALL show that it is linked and SHALL NOT be removable in the app.

#### Scenario: Levy line
- **WHEN** a voucher paying levy entry 12 is edited and saved
- **THEN** its line still carries levy entry 12
