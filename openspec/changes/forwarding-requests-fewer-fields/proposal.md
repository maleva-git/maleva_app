## Why

Owner, 2026-10-15: "Remove Submitted, Approved, Released, seal by and break seal by from the mobile app's
forwarding request screens too." The web did the same (maleva-front-end change `forwarding-requests-fewer-columns`).

## What changes

- **Edit page** (`forwarding_request_edit_page.dart`): only Documents received, Draft created and C Number are
  shown and edited. Submitted + registration no, Approved + approved on, Released + release number, the Seal
  section (Seal by / Break seal by) and the employee lookup (`EmployeeApi.dropdown`) that fed those pickers are
  removed.
- **Detail page** (`forwarding_request_detail_page.dart`, My Forwarding Requests): the Submitted, Registration no,
  Approved, Released, Release number, Seal by and Break seal by rows are removed.
- **Card**: no longer shows the release number (C Number stays).
- The status chip, the six-step indicator, the status filter and the open count are unchanged, because older
  rows may already hold those statuses.
- No backend change. Save still sends the full ticks body (`PUT /api/forwarding-requests/{id}/ticks`) with the
  saved submitted / approved / released values, references and seal ids passed through unchanged. Unticking
  Draft (or Documents) still unticks the later steps, as the server ladder does.

Modifies "The forwarding team works the list" and "My Forwarding Requests" of `forwarding-requests-app`
(change `forwarding-requests-on-shared-java-api`, not yet archived: archive that one first).

## Exclusions

- RTI and the operations Forwarding Update screen (`features/operations/forwarding`) are not forwarding
  request screens and are unchanged. The models keep every field so the pass-through works.
