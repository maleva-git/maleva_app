# Permissions and role routing

Verified from client source on 2026-10-01. Client visibility, route selection,
manifest declarations, OS grants, and server authorization are different things.
Only the first three are established by this inspection.

## Dashboard routing

Driver login takes precedence and opens `/driver_dashboard` in both inspected
paths. Employee routing is as follows; numeric IDs are recorded without assuming
that comments in different modules use consistent role names.

| Employee role ID | After manual login | After successful splash login |
| --- | --- | --- |
| 100 | `/dashboard/admin` | `/dashboard/admin` |
| 200 | `/dashboard/admin` | `/dashboard/subadmin` |
| 300 | `/dashboard/sales` | `/dashboard/sales` |
| 400 | `/dashboard/admin` | `/dashboard/admin` |
| 500, 600 | `/dashboard/boarding` | `/dashboard/boarding` |
| 800 | `/dashboard/admin` | `/dashboard/admin` |
| 900 | `/dashboard/payable` | `/dashboard/payable` |
| 1000 | `/dashboard/transport` | `/dashboard/transport` |
| 1200 | `/dashboard/receivable` | `/dashboard/receivable` |
| 1300 | `/dashboard/maintenance` | `/dashboard/maintenance` |
| 1400 | `/dashboard/forwarding_agent` | `/dashboard/forwarding_agent` |
| 1500 | `/dashboard/air_freight` | `/dashboard/air_freight` |
| Any other value | `/unauthorized` | `/dashboard/admin` |

Evidence: [manual navigation](../../lib/features/auth/presentation/pages/login_page.dart),
[splash navigation](../../lib/splash/splashscreen.dart), [registered routes](../../lib/core/router/app_router.dart).
Differences are recorded under Q01; they have not been reconciled during setup.

## Client action checks

| Area | Verified behavior | Limit of evidence |
| --- | --- | --- |
| Menu | Login loads/caches menu rows; the drawer uses labels and parent IDs to build/dispatch entries. | Server menu generation and universal PageView enforcement are not established. |
| IR add | Permission defaults allow adding; the menu's PageAdd flag can remove that right. | Backend rejection/authorization is unverified. |
| IR edit | Role 100/200 can edit any report; others need a nonzero employee ID matching the reporter. PageEdit can narrow rights. | BLoC/repository calls are not a global authorization layer. |
| IR delete | Role 100/200 can delete; PageDelete can remove that right. | Server enforcement remains Q03. |
| Driver identity in newer modules | `PreferencesAppSession.employeeId` returns 0 for driver login instead of treating a driver ID as an employee ID. | Legacy globals/session helpers do not necessarily share that rule. |
| Transaction sales form | Employees in the hard-coded restriction list have a restricted field permission map. | Confirm policy through Q05 before changing it. |
| Truck Location | Menu dispatch constructs the board without passing add/edit/delete flags to its route. | A comment says drivers have no menu entry; no production menu response was inspected. |
| Router | Named routes create their dashboards/providers; no global redirect is configured in the inspected router. | Route registration is not an access-control guarantee. |
| Leave review | Client submits request ID, reviewer, target status, and remark. | Approver roles and server policy require confirmation. |
| Boarding salary report | Treats RulesType=ADMIN (case-insensitive) or role ID 1 as admin and sends Employeeid=0; otherwise sends the stored employee ID. | This differs from IR admin IDs 100/200; clarify the intended reporting scope under Q03. |

Evidence: [IR permission rules](../../lib/features/ir_report/presentation/ir_permissions.dart),
[IR route narrowing](../../lib/features/ir_report/presentation/ir_report_routes.dart),
[session identity](../../lib/core/session/app_session.dart), [menu](../../lib/menu/menulist.dart),
[sales field map](../../lib/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart),
[leave repository](../../lib/features/dashboard/common_tabs/driverleave/data/leave_repository.dart),
[salary scope](../../lib/features/dashboard/common_tabs/salary/data/salary_repository.dart).

## Android declarations and runtime requests

The checked-in [main manifest](../../android/app/src/main/AndroidManifest.xml)
declares the following. This table does not include a built merged manifest.

| Declaration | Source-level connection / limitation |
| --- | --- |
| `INTERNET` | HTTP APIs, file services, Firebase, external documents. |
| `CAMERA` | Camera/image-picker and scanner flows exist. Runtime grants were not tested. |
| `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` | Declared; no inference of continuous GPS collection. Truck Location is an editable planning board. |
| `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` | Legacy storage declarations; applicability depends on Android version and plugin behavior. |
| `BLUETOOTH`, `BLUETOOTH_ADMIN` | Legacy Bluetooth declarations. |
| `BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN` | Modern Bluetooth declarations; scan sets `neverForLocation`. Runtime denial/recovery requires device validation. |
| `USE_BIOMETRIC`, `USE_FINGERPRINT` | Declared; no implemented biometric login was established by the inspected authentication flow. |
| Notification permission | `LocalNotificationService.initialize` calls the Android plugin permission request. `POST_NOTIFICATIONS` is not explicitly present in this main manifest; plugin manifest merging was not verified. |

The manifest also enables cleartext traffic and legacy external storage, and
declares SMS/tel/browser query intents. These are configuration facts, not
guarantees that actions or permissions are available at runtime.

## iOS declarations

[Info.plist](../../ios/Runner/Info.plist) contains camera and photo-library usage
descriptions, Bluetooth usage descriptions, and background modes `fetch` and
`remote-notification`. Notification setup asks for alert/sound and disables badge
presentation. No iOS build or permission flow was exercised.

Device questions are Q09/Q10; client/server authorization is Q03; transport
configuration is Q12 in the [clarification register](clarifications.md).
