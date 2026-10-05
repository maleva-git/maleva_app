# Proposal

## Why

The owner asked (2026-10-05) for every .NET-related piece to be removed from the app, keeping only what
the Java implementation needs. That included Bluetooth, Firebase and notifications, but only where
they depend on .NET.

## What was checked and kept (needed by the Java app)

- **Firebase and notifications** (`firebase_core`, `firebase_messaging`, `flutter_local_notifications`). The Java backend sends push notifications through FCM (`pushnotification/PushNotificationService`, `GoogleFcmClient`), and the app registers its push token with Java (`/api/mobile/auth/device-token`). They do not depend on .NET.
- **Bluetooth printing** (`bluetooth_print_plus`, `core/bluetooth`, `printer_helper`). Ten dashboards use it to print to a local printer, and the data printed comes from the Java APIs. It does not depend on .NET.
- **`LegacyApiRepository` and `LegacyFeatureContext`.** Despite the name, they are now the picker helpers (calling the Java APIs) and the session reader. They are not .NET code.
- **Comments that name the .NET source of a port.** Rule 6 asks for that source to be recorded.
- **`win32`**: a direct dependency that only pins a version for the Windows plugins.

## What Changes (removed)

- **Accept-invalid-certificate override.** `MyHttpOverrides` and `lib/core/network/certificate_policy.dart` existed for the .NET site's certificate, and its test goes with them. **Every host must now present a valid TLS certificate**, as the Java host already did.
- **The .NET site's address:**
  - `AppConfig.baseUrl` and the commented .NET server addresses in `AppConfig` and `AppGlobals`;
  - the old `apiPostimage` line;
  - a commented-out **live Razorpay key**, a payment credential in source.
- **The .NET session token in `SessionManager`** (`mobileToken`, `setMobileToken`). Sign-out still deletes a token an earlier app version saved, so it does not linger on the phone.
- **`ResponseViewModel`**, the .NET response wrapper, which nothing used, and its export.
- **`api_services/auth_api.dart`**, an empty class named after the .NET login and kept only as a DI marker. `setupDependencies` now checks the `SessionManager` registration.
- **`api_services/firebase_service.dart`**, an unused duplicate of the push-token code.
- **Five unused packages:** `textfield_search`, `pdf`, `provider`, `flutter_map`, `latlong2`. Resolving dropped 16 packages in all, with no version change to any kept package.

## Behaviour changes

- **An invalid HTTPS certificate is now refused on every host.** No .NET host is called any more, so nothing relied on the old acceptance.

## Capabilities

### Modified Capabilities
- `api-integration`: the app holds no .NET address, token, wrapper or certificate exception.

## Impact

`main.dart`, `app_config.dart`, `app_globals.dart`, `session_manager.dart`, `core/di/injection.dart`,
`core/models/model.dart`, `pubspec.yaml` / `pubspec.lock`; deleted `certificate_policy.dart`,
`response_view_model.dart`, `auth_api.dart`, `firebase_service.dart` and `certificate_policy_test.dart`.
No backend change.
