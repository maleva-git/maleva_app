## ADDED Requirements

### Requirement: Pay the supplier's open bills
Choosing a supplier SHALL load their open documents (`/api/payments/supplier-bills`, this payment left out when
editing) with balance and paid. The person SHALL put an amount on each (typed, full balance, or none) or Pay all; the
total SHALL be the sum of the amounts.

#### Scenario: Pay all
- **WHEN** the supplier has balances of RM 600, RM 200 and RM 50 and the user taps Pay all
- **THEN** the total is RM 850

### Requirement: Saved as the web
Save SHALL send `POST /api/payments/save` with the web's body (only documents with an amount and their bill / purchase /
opening-balance ref, PV status from the tick, the supplier's bank and tax details) and SHALL refuse, in the web's order:
no supplier, bank, reference no., status or description; no amount; total not above zero; an amount above its balance.

#### Scenario: Overpaying a bill
- **WHEN** a bill with balance RM 200 gets RM 250
- **THEN** Save says the amount is more than its balance and nothing is saved

### Requirement: Pay this bill
A credit bill's page SHALL offer Pay this bill: the form opens on the Bills step with the bill's supplier chosen and the
bill's full balance on it; the bill's files SHALL be offered to copy to the payment.

#### Scenario: From a bill
- **WHEN** the user taps Pay this bill on BIL2610/005 (balance RM 200)
- **THEN** the form shows that supplier's open bills with RM 200 on BIL2610/005
