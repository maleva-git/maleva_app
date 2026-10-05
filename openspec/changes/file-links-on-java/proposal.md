# Proposal

## Why

The app calls no .NET API, but its image and document links were still built on the .NET host
(`AppConfig.baseUrl` / `ApiConstants.port` + `/Upload/...`). They would break once the .NET site is
switched off.

The Java server already serves the same Upload tree publicly:
- `AttachmentResourceConfig` maps `/Upload/**` to `file.upload.upload-dir`;
- `SecurityConfig` permits it;
- the app's uploads already go through Java (`AttachmentsApi`).

## What Changes

- **New** `fileUrl(path)` (`lib/core/files/file_links.dart`). It builds the Java-host link of a stored path (`/Upload/<company>/<folder>/<record>/...`). A full URL is left alone, and an empty path is ''.
- **12 links on 6 screens** use it instead of `ApiConstants.port + path`: Spare Parts (5), Spot Sale (2), Summons (2), Job Orders, PDO and TransportDB.
- **`AppGlobals.imagepath`**, the company's Upload folder, was `"$port/Upload/$Comid/"` on the .NET host. My earlier scans missed it; the analyzer caught it when `ApiConstants` was removed. It is now a getter, `fileUrl('/Upload/$Comid/')`. Its 14 uses on 12 screens follow: Air Freight, Forwarding, Job Status Update, RTI Status, Stock-in and others.
- **Fixed with it:** `imagepath` was a static field, so the company was fixed the first time it was read. A sign-in to another company kept the previous company's folder. The getter reads the current company.
- **Removed:** `ApiConstants` (only the host was left) and `AppGlobals.port` (unused).
- **`AppConfig.baseUrl`** (the .NET site) stays only for the certificate policy, and its comment now says so.

## Behaviour changes

- **Images, PDFs and documents open from the Java server.**
- **Links sent in emails and WhatsApp point at the Java server too.** RTI Status and the Job Status Update boarding email send the photo links to the server, which puts them in those messages.
- **Switching company takes effect for image links straight away.**

## Deployment check

In production, `FILE_UPLOAD_DIR` must point at the IIS site's Upload folder, as `application.yaml` says, so files written by the .NET site before the migration are found on the Java host. Files the app uploads now are already written by Java.

## Noted, not changed

`certificate_policy.dart` accepts an invalid TLS certificate from any host except the Java one. This is a leftover for the .NET site's certificate. With no .NET calls left it could reject them everywhere, but that is a security behaviour change to make on purpose.

## Capabilities

### Modified Capabilities
- `api-integration`: file links point at the Java server.

## Impact

`lib/core/files/file_links.dart` (new), `app_globals.dart`, `app_config.dart`, `api_constants.dart`
(deleted), the spare parts, spot sale, summons, job orders, PDO and TransportDB views, and
`test/core/files/file_links_test.dart`. No backend change.
