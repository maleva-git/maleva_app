# Design

## Routing

`JavaRoute.resolve(url)` rewrites `<AppConfig.baseUrl>/api/<Controller>/<Action><rest>` to
`<AppConfig.javaBaseUrl>/api/mobile/app/<Controller>/<Action><rest>` when `<Controller>` or
`<Controller>/<Action>` is in `JavaRoute.moved` (names compared without case, as .NET did; the
Java spelling is used). Constants are not edited, so inline URLs built from `ApiConstants.port`
move too, and one entry moves or restores a controller.

## Transport

- `ApiClient.postRequest/getString`: a Java URL is posted through `JavaApiClient.dio` and turned
  back into an `http.Response`, so `_handleResponse` (200 decode, 401/404/500 messages) is
  unchanged. Only the caller's own headers (for example `Comid`) are passed; `Authorization`,
  `Userid` and `Profile` of the legacy token are not built for Java.
- `LegacyApiRepository`: every POST (generic helpers and the named helpers) picks the client by the
  resolved URL; error bodies are still returned to the caller as before.
- `JavaApiClient` adds the session token and refreshes on 401; the backend answers 401 on
  `/api/mobile/**` without a valid token (backend change `add-mobile-app-api`).

## Per controller

A controller moves when the Java port exists and its tests pass. Before adding it to `moved`:
check for direct `http`/`Dio` callers of that controller and route them through the shared
helpers; check every action spelling the app uses exists on the Java side.
