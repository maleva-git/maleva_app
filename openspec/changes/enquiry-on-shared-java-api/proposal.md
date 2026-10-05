# Proposal

## Why

Six app places called .NET `EnquiryMasterApp`. Backend change `share-enquiry-api` ports the list and
the status change.

## What Changes

| Screen | Before (.NET) | Now (shared Java) |
|---|---|---|
| Enquiry tab (sales, subadmin, transport) | `SelectEnquiryMaster`, `UpdateEnquiryMaster` CANCEL | `POST /api/enquiry-masters/search` (team), `PUT /{id}/status` |
| Customer dashboard enquiries | the same | the same |
| TransportDB enquiries | the same | the same |
| Enquiry TR list | the same | `search` (own employee, customer, job type, dates) and `status` |
| Sales Order: from an enquiry | `.NET row → javaSaleOrderFromDotNet`; `UpdateEnquiryMaster` CONFIRMED | the Java row (`EnquiryApi.asSaleOrder`); `PUT /{id}/status` CONFIRMED |

- **New** `EnquiryApi` (`lib/core/enquiry`), registered in DI.
- **Screens read the Java row**: `id`, `customerName`, `jobType`, `forwardingDate`, `pickupDate`,
  `eta`, `oeta`, `loadingvesselname`, `offvesselname`, `sport`, `oport`, `origin`, `destination`,
  `quantity`, `totalWeight`.
- **Edit prefill.** The Add Enquiry prefill reads the Java row, and the TR model gains
  `EnquiryMasterModel.fromJava`.
- **Sale order from an enquiry.** `EnquiryApi.asSaleOrder` renames the six fields Lombok spells
  differently in the two Java DTOs (`sport`→`sPort`, `oport`→`oPort`, `ovessel`→`oVessel`,
  `jstatus`→`jStatus`, `oagentCompanyRefId`, `oagentMasterRefId`).
- **Removed**: the transitional `.NET`-key converter `sale_order_keys.dart`, and the list and
  status `ApiConstants`.

## Behaviour changes

- **The Enquiry TR list works.** It used to come back empty, because the app wrapped the filter in
  `_objModel` and .NET read company 0. Cancel there now reports correctly too.
- **TransportDB can open an enquiry for edit.** It used to pass a raw map where a model was expected.
- **A refused cancel shows the server's reason.**

## Phase 2 (2026-10-05): saving

- Add Enquiry (MY) and Add Enquiry TR save with `EnquiryApi.save` to
  `POST /api/enquiry-masters/entries`. That is the Java port of `InsertEnquiryMaster` /
  `SP_EnquiryMaster` (backend `share-enquiry-api` phase 2). The forms send only their own fields
  under the Java names, not the 120-column .NET row. **No enquiry call goes to .NET any more.**
- A refused save shows the server's reason (for example "Select the job type"). The TR form used to
  stay silent when the save failed.
- Editing an enquiry no longer blanks its agents, amounts and status. The server now changes only
  the form's fields.
- Removed: `ApiConstants.apiInsertEnquiry` and `EnquiryTrRepository.insertEnquiry`. The network
  tests use `apiInsertForwarding` as their example of a call that is still on .NET.

## Capabilities

### Modified Capabilities
- `api-integration`: enquiry lists and statuses use the shared Java enquiry API.

## Impact

`lib/core/enquiry/enquiry_api.dart`, the enquiry, custdashboard, transportDB, enquirytrmaster and
salesorder add features, `api_constants.dart`, `auth_injection.dart` and the network tests. Ships
with backend change `share-enquiry-api`.
