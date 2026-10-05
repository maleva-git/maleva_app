# Proposal

## Why

The Email Inbox tab and TransportDB's mail section called .NET `EmployeeApp` (`SelectEmailData`,
`InsertMailMaster`). Backend change `share-email-inbox-api` ports them.

## What Changes

- **New** `EmailInboxApi` (`lib/core/employee`), registered in DI:
  - `unanswered(employeeId)` reads `/api/email-inboxes/unanswered`;
  - `keep(employeeId, emails)` posts to `/api/email-inboxes/entries`.
- `EmailModel.fromJava` / `toJava` read and write the Java fields. The .NET `fromJson` is removed.
  The received time is read as UTC and sent back as UTC.
- **Removed**: the two inbox `ApiConstants`. **No screen calls .NET `EmployeeApp` any more.**

## Behaviour changes

- **TransportDB's mail section now shows mail.** It never did: it expected a map, but .NET answered
  a JSON string.
- **The unread mark is right.** .NET inverted it.
- **Clear errors.** "No mailbox set up" and a refused login now come back as the server's message.
- **Save confirmation.** A save shows how many mails were kept.

## Capabilities

### Modified Capabilities
- `api-integration`: the staff email inbox uses the shared Java API.

## Impact

`lib/core/employee/email_inbox_api.dart`, `lib/core/models/shared/email_model.dart`, the
`emailinbox` repository and bloc, the TransportDB repository and bloc, `api_constants.dart` and
`auth_injection.dart`. Ships with backend change `share-email-inbox-api`.
