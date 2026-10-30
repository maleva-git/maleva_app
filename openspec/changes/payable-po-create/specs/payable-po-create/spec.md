## ADDED Requirements

### Requirement: New PO and edit from the Records tab
The Records tab SHALL show a **New PO** button when the PO chip is chosen, and a PO's detail page SHALL offer **Edit**.
Both open the PO form; after a save the list reloads. A PO raised from a workshop job order SHALL NOT be edited in
the app (the form says to edit it on the web).

#### Scenario: Job-order PO
- **WHEN** the user opens Edit on a PO with a job order link
- **THEN** the form says to edit it on the web and offers no Save

### Requirement: Three steps, the web's rules
The form SHALL have three steps (Supplier, Items, Check & save). Choosing a supplier SHALL set its payment term; the
due date SHALL be the invoice date plus the term's days. A line's amount SHALL be qty × rate + tax (tax = qty × rate ×
tax% ÷ 100); the PO amount SHALL be the sum of the lines. Save SHALL refuse, listing the reasons, without a supplier,
payment term, expense type, invoice number, at least one item, an account on every item, or (new PO) with an invoice
number already on another PO.

#### Scenario: Missing account
- **WHEN** an item has no account and the user presses Save
- **THEN** "1 item without an account" is shown and nothing is saved

### Requirement: Saved as the web saves
Save SHALL send `POST /api/bills-order/insert` with header `Comid` and the web form's body (CREDIT, pay to DIRECT
PAYMENT when blank, status ASSIGNED by default, pStatus 1 only for PAYMENT COMPLETED, invoice number in upper case,
the signed-in employee) after a confirm, and SHALL then upload the attached photos to folder `BillOrderMaster` with
the new PO id. If the photos fail, the PO stays saved and the message says to add them on the web.

#### Scenario: New PO with a photo
- **WHEN** the user saves a new PO with one photo
- **THEN** the PO is saved, the photo is uploaded under the new id and the form closes

### Requirement: Read with AI
The form SHALL offer Read with AI: a photo (camera or gallery) is sent to `POST /api/ai/purchase-orders/extract`;
the answer fills supplier and term (by id), invoice no. and dates, expense type (only a listed one), truck, driver,
job no. and items (account by id, code or name); the photo is kept to attach. A "Filled by AI: please check" banner
SHALL show with the warnings (unmatched supplier with up to 3 candidates, items without account, document total
different from the items). Nothing SHALL be saved without the person pressing Save. Typed data SHALL be replaced only
after the person agrees.

#### Scenario: Supplier not matched
- **WHEN** the AI finds no supplier
- **THEN** the supplier stays empty and up to three candidates are offered
