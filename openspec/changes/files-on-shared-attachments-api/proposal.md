# Proposal

## Why

Photos and files (job status, boarding, RTI status, air freight, forwarding, stock in and stock
update photos, job order files) still went to .NET `CommonApp/UploadFile`, `FetchFiles`,
`DeleteFile` and the web `Common/FetchFile2`, `UploadFile5`, `DeleteFile`, over raw `http` with the
company and folder in headers. The web uses the shared Java `/api/attachments`, which replaced all
of those and writes the same `Upload/` tree.

## What Changes

- **New** `AttachmentsApi` (`lib/core/files`): upload (keeps the phone's file name, as .NET
  `UploadFile`; answers the stored name), add (new unique names, PDF pages as images, as
  `UploadFile5`), list, image names (png/jpg/jpeg, as `FetchFiles`), delete. Session token, company
  from the session, a refusal is an `ApiFailure` with the server's message.
- `SystemHelpers.upload` (seven screens) stores through it; the old URL argument is gone.
- The six photo lists and seven deletes (air freight, forwarding, job status update, RTI status,
  boarding, stock in, stock update) use it; the repository deletes now return nothing and throw on
  failure, and the blocs show the error instead of silently keeping the photo.
- Job Orders' attachments sheet uses list / add (PDF as page images) / delete in its existing
  `jobs order` folder (backend change `allow-space-in-attachment-folder`).
- Dead code removed: `ApiClient.uploadImage`, `ApiClient.uploadPdfOrFile`,
  `SystemHelpers.uploadPdfOrImage`, the `apiPostImage` / `apiGetImage` / `apiDeleteImage` constants.

## Not moved

- The "Report a Problem" log (`AppLogApi`, `CommonApp/UploadFile2`): it also runs on a startup
  crash, before sign-in, when there is no session for the Java API. Needs a decision (a mobile
  crash-report endpoint, or only send it after sign-in).
- Uploads that are part of a feature's own save (summon, spare parts, spot sale, PDO
  `InsertRTIStatus`) move with those features.

## Capabilities

### Modified Capabilities
- `api-integration`: record files use the shared Java `/api/attachments`.

## Impact

`lib/core/files`, `auth_injection`, `SystemHelpers`, `ApiClient`, the seven photo screens and Job
Orders. Ships with backend change `allow-space-in-attachment-folder` (for Job Orders).
