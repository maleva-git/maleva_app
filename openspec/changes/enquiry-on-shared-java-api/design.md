# Design

**Search filters.**
- `EnquiryApi.search` sends `team: true` for the Enquiry tab, the customer dashboard and TransportDB
  (.NET DashboardStatus 2).
- Enquiry TR sends the employee alone, plus the customer, the job type, `invoice` and the optional
  dates, as before.

**Date display.** `EnquiryApi.display` formats a date `dd-MM-yyyy HH:mm`, as the screens did.

**Sale order from an enquiry.** The sale order form reads a Java sale order, and an enquiry row has
the same field names except the six that `asSaleOrder` renames. Fields an enquiry does not have
(the CPop flags, flight time) stay unset, as with .NET.
