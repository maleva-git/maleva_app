## Why
Forwarding clean-up C3 (owner 2026-10-26, `docs/fleet/forwarding-clean-flow.md`): the agent gives the release no on the
stop card he already uses, once per job, instead of the separate FW Update screen (find the job by SMK no). The release no
on the forwarding rows fell from 354 (April) to 0 (August).

## What Changes
- **RTI Activities** stop card: a **Release no** button on forwarding stops (seal, break seal, both, K clearance).
- It opens a sheet with the jobs of that RTI (job no, customer, form, saved release no) and a box + Save per job.
- Reads the shared Java API as it is (`GET /api/forwarding-flow/stops/{id}/jobs`, `PUT …/release`; backend change
  `ff1-forwarding-file-documents` / C3). No backend change for the app.
- The old FW Update screen stays until the agents use the card (removed in C6).

## Not in this change
A photo of the release paper (FW Update keeps its photos for now).
