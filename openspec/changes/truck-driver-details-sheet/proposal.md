# Proposal

## Why

The owner asked (2026-10-14) for the Truck & Driver Details sheet - a truck's vehicle details and a
driver's personal details side by side, downloadable - on the web Transport and Customer Service
dashboards and in the app as well.

## What Changes

| New / changed | Java API / migrated from |
|---|---|
| New screen "Truck & Driver Details": pick a truck and a driver, see the sheet, share it as a PDF | Shared Java `GET /api/truck-driver-details` (new in maleva-backend change `truck-driver-details-sheet`; no .NET code behind it). Pickers: the shared `/api/truck-combo`, `/api/driver-combo` |
| A button for it in the app bar of the Transport and Sales (Customer Service) dashboards | - |
| `pdf` package added (pure Dart; no Android/Gradle change) | - |

No backend change for the app: these dashboards sign in with employee tokens, which the endpoint
already accepts. Driver tokens are not given access.

## Impact

`lib/features/truck_driver_details/*`, `lib/features/auth/auth_injection.dart` (registers the API),
the two dashboard app bars, `pubspec.yaml`.
