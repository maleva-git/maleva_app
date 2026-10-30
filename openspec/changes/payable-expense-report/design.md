# Design
- A new screen rather than a patch of `common_tabs/expensereport` (shared with the admin dashboard, 631 lines, maps
  of untyped rows): the payable tab reads the typed `ExpenseSummary` already used by the Today tab.
- Drill-down reuses the Records API (voucher + pay bill lists of the period) and filters by the stored Description
  (`PayableRecord.head`), case- and space-insensitive, so it matches the server's GROUP BY Description.
- Period state lives in the widget (one future); no cubit needed for one call.
