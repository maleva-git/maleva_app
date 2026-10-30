# Design
- Read only; same look as the Expenses tab (gradient total, table with Total row).
- The report is fetched as bytes (`ResponseType.bytes`), checked to start with `%PDF` (a JSON refusal is read for its
  message), written to the temp folder and opened with `open_file` (the app's existing pattern).
- Rows map to Records kinds (voucher / pay bill) so the detail page and files are reused.
