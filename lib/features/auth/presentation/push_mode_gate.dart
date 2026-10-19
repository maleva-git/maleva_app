import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/presentation/mode_switch_button.dart';
import 'package:maleva/features/mail_monitor/mine/push_route.dart';
import 'package:maleva/features/vessel_changes/push_route.dart' show localPayloadForPush;

/// A person who is both an employee and a driver gets office and driver alerts
/// in either mode (openspec change employee-extra-jobs-and-driver-mode). Each
/// push says whom it is for in `forKind` (EMPLOYEE / DRIVER). Tapping one for
/// the other mode asks to switch first; Yes switches and opens it, No leaves
/// the person where he is. A push without `forKind` opens as before.
class PushModeGate {
  PushModeGate._();

  /// `forKind` of the latest foreground pushes, by their local notification
  /// payload (the payload itself carries only the push type).
  static final Map<String, String> _kindByPayload = {};

  /// The mode the app is in now.
  static String currentKind() => AppPreferences.getDriverId() == 1 ? 'DRIVER' : 'EMPLOYEE';

  /// The other mode when [forKind] is for it and the person can switch; else null.
  static String? otherModeFor(String? forKind) {
    final kind = forKind?.trim().toUpperCase() ?? '';
    if (kind.isEmpty || kind == currentKind()) return null;
    return ModeSwitchButton.canSwitch() ? kind : null;
  }

  /// Remembers a foreground push's `forKind` for when its local notification is tapped.
  static void remember(Map<String, dynamic> data) {
    final kind = data['forKind']?.toString();
    if (kind == null || kind.isEmpty) return;
    _kindByPayload[localPayloadForPush(data)] = kind;
  }

  /// A tapped push (app in the background).
  static Future<void> openPush(Map<String, dynamic> data) =>
      _open(data['forKind']?.toString(), routeForPush(data));

  /// A tapped local notification (shown while the app was open).
  static Future<void> openPayload(String? payload) =>
      _open(payload == null ? null : _kindByPayload[payload], routeForPayload(payload));

  static Future<void> _open(String? forKind, String? route) async {
    final other = otherModeFor(forKind);
    if (other == null) {
      openPushRoute(route);
      return;
    }
    final context = AppGlobals.navigatorKey.currentContext;
    if (context == null) return;
    final toDriver = other == 'DRIVER';
    final switched = await ModeSwitchButton.switchMode(
      context,
      toDriver: toDriver,
      question: toDriver
          ? 'This is a driver alert. Switch to Driver mode to open it?'
          : 'This is an office alert. Switch to Office mode to open it?',
    );
    if (switched && route != null) {
      // the new dashboard opens first; the alert's screen goes on top of it
      Future.microtask(() => openPushRoute(route));
    }
  }
}
