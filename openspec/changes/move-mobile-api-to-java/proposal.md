# Proposal

## Why

After sign-in moved to Java (change `move-mobile-login-to-java`), every other screen still calls
the .NET `/api/<Name>App/<Action>` endpoints: about 135 calls over 33 controllers, sent without
authentication and with the company as a query parameter. The app cannot leave .NET until these
calls go to Java.

## What Changes

- The backend serves each .NET app action at `/api/mobile/app/<Name>App/<Action>` with the same
  contract (backend change `add-mobile-app-api`), so screens, blocs and models stay as they are.
- **New** `JavaRoute`: the list of moved controllers (or single actions). A call to a moved one is
  rewritten to the Java host, whichever constant or inline URL built it.
- The shared HTTP helpers (`ApiClient`, `LegacyApiRepository`) send Java URLs through
  `JavaApiClient`: the session token, one refresh on 401, the session ended when refresh fails.
  The legacy auth headers never reach Java; the token never reaches .NET.
- Code that calls .NET with its own `http`/`Dio` client is switched to the shared helpers when its
  controller moves.
- Controllers move one at a time as their Java port lands; removing an entry sends it back to .NET.

## Capabilities

### Modified Capabilities
- `api-integration`: moved calls go to the Java backend with the session token.

## Impact

`lib/core/network` (routing, helpers) and, per controller, any direct HTTP callers. No screen,
model or bloc change for a moved controller.
