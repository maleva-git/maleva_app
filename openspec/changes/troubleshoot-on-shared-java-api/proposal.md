# Proposal

## Why

"Report a Problem" and the startup crash report posted a log file to .NET `CommonApp/UploadFile2`. That was the app's last file upload to .NET, and it accepted anonymous uploads. The shared Java upload is `POST /api/attachments`, which the app's `AttachmentsApi` already uses. Backend change `share-troubleshoot-upload` opens it to drivers for their own Troubleshoot folder.

## What Changes

- **Report a Problem** uploads with `AttachmentsApi.upload` to folder `Troubleshoot`, with the user's id as the record (the driver id for drivers) and mode `MIXED` (the `.txt` is kept as it is). The log text is unchanged. A refusal shows the server's reason.
- **Startup crash (`main.dart`).** It runs before sign-in, when there is no token. The owner chose (2026-10-05) to keep it on the phone rather than add a public endpoint:
  - `AppLogApi.savePendingCrash` writes it to `<app support>/pending_troubleshoot/`; the temporary-file clean-up does not touch that folder.
  - `AppLogApi.sendPending` uploads those files to the signed-in user's Troubleshoot folder and deletes each one once stored. It runs after sign-in, after a restored session (splash), and with every Report a Problem. A failed send is kept for next time.
  - The crash log no longer claims company 6; it says "unknown".
- **Removed:** `ApiConstants.apiPostFile`. The network tests now use `apiSelectUser` as their example of a .NET URL.

## Behaviour changes

- **A crash before sign-in reaches the server only once someone signs in** on that phone, and is filed under that person.
- **A driver's report is filed under their own company and driver id.** The server enforces this.

## Capabilities

### Modified Capabilities
- `api-integration`: troubleshoot logs use the shared Java attachment upload.

## Impact

`features/troubleshoot/data/applog_api.dart`, `main.dart`, `splash/splashscreen.dart`,
`auth/data/repositories/auth_repository.dart`, `api_constants.dart` and the network tests. Ships with
backend change `share-troubleshoot-upload`.
