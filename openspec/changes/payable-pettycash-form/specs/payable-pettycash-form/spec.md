## ADDED Requirements

### Requirement: Petty cash form saves as the web
The app SHALL save a petty cash sheet with `POST /api/petty-cash-masters/save?companyId=` and the web's body: id,
Requested by (the signed-in employee when none is chosen), employee type, date `yyyy-MM-dd`, status, remark, the
rows that have an item or an amount (item, notes, amount, account id or 0, the account's classification or 0), and the
balances (Last balance, Cash received, typed-by-hand flag) only when the server says the balances are ready. It SHALL
refuse to save, saying why, when there is no employee type, no row, or a row without an item or a valid amount.

#### Scenario: Save with balances
- **WHEN** the balances are ready, Last balance is RM 15.99, Cash received RM 2,000 and the rows add up to RM 1,739.91
- **THEN** the body carries balanceBefore 15.99, cashReceived 2000, balanceBeforeTyped false, and the page closes
  after the save

#### Scenario: Row without an item
- **WHEN** a row has an amount but no item
- **THEN** Save says each row needs an item and a valid amount and nothing is sent

### Requirement: Petty cash balance
The form SHALL show This balance = Last balance + Cash received − Total, to two decimals, blanks counted as 0. On a
new sheet Last balance SHALL come from the chosen person's last sheet for the chosen date, with the note "from
<number>, dd/MM/yyyy", or "No earlier sheet: type the opening balance" when there is none. A pencil SHALL let the
person type Last balance (saved as typed by hand). A balance below 0 SHALL show red with "More spent than cash in
hand" and the sheet SHALL still save. While the server says the balances are not ready only the Total SHALL show.

#### Scenario: Below zero
- **WHEN** Last balance is 10, Cash received is blank and the total is 25
- **THEN** This balance shows RM -15.00 in red with "More spent than cash in hand" and Save still works

#### Scenario: Not ready
- **WHEN** the last-balance answer says ready = false
- **THEN** only Total shows and the save sends no balances

### Requirement: Last balance changed note
When an opened sheet's server answer has an expected Last balance different from the saved one, the form SHALL show
"Last balance changed: was RM x, now RM y" with Update; Update SHALL ask the server to make this and later sheets
follow, say how many sheets were updated, and reload the sheet.

#### Scenario: Update
- **WHEN** the user taps Update on the note
- **THEN** the follow call is made, the result is shown and the sheet is loaded again

### Requirement: Read a petty cash sheet with AI
The form SHALL offer Read with AI from a camera or gallery photo, ask before replacing a filled form, and fill date,
remark, Requested by (only when the server matched one), employee type (when listed), Last balance (typed by hand only
when it differs from the server's last balance), Cash received and the rows (account only when the expense list has
it, by id then code). It SHALL show "Filled by AI — please check" with the warnings and, when no person was matched,
the closest names to tap. Nothing SHALL be saved until the person presses Save; the photo SHALL be attached to the
sheet (folder PettyCash) after the save.

#### Scenario: Name not matched
- **WHEN** the AI reads "Lim" and offers LIM AH KOW and LIM MEI
- **THEN** the banner shows both names; tapping one sets Requested by
