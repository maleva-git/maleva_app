## ADDED Requirements

### Requirement: Expense table with a total
The Expenses tab SHALL list every expense head of the period with its count and amount, biggest first, and a Total
row whose count and amount are the sums of the rows; amounts in RM with two decimals.

#### Scenario: The team's sheet
- **WHEN** the period has FUEL 1 RM 10,000.00 and VENDOR 4 RM 5,052.91
- **THEN** FUEL is first, VENDOR second, and Total shows 5 and RM 15,052.91

### Requirement: Approved, waiting and rejected
The tab SHALL show the approved and waiting parts of the total and of each head, and SHALL say how many REJECTED
payments (and how much) were left out when the server reports any.

#### Scenario: Two rejected
- **WHEN** the server answers RejectedCount 2 and RejectedAmount 450
- **THEN** the tab shows "Left out: 2 rejected (RM 450.00)"

### Requirement: An expense opens its payments
Tapping an expense SHALL list the period's payment vouchers and pay bills with that expense head, REJECTED left out,
each opening the record's detail page.

#### Scenario: Fuel
- **WHEN** the user taps FUEL
- **THEN** the FUEL vouchers and pay bills of the period are listed and a rejected FUEL voucher is not
