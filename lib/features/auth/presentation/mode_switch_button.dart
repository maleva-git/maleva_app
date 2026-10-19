import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/dialog_helper.dart';
import 'package:maleva/core/utils/toast.dart';
import 'package:maleva/features/auth/data/mobile_auth_api.dart';
import 'package:maleva/features/auth/data/session_service.dart';
import 'package:maleva/features/auth/presentation/dashboard_routes.dart';
import 'package:maleva/features/notifications/notification_summary_cubit.dart';

/// "Driver mode" on an office dashboard, "Office mode" on the driver dashboard,
/// for a person who is both an employee and a driver (Driver Master "Linked
/// employee"; openspec change employee-extra-jobs-and-driver-mode). Hidden for
/// everyone else.
class ModeSwitchButton extends StatelessWidget {
  const ModeSwitchButton({required this.isTablet, super.key});

  final bool isTablet;

  /// True when the saved session has a linked record to switch to.
  static bool canSwitch() => AppPreferences.getDriverId() == 1
      ? AppPreferences.getLinkedEmployeeId() > 0
      : AppPreferences.getLinkedDriverId() > 0;

  @override
  Widget build(BuildContext context) {
    if (!canSwitch()) return const SizedBox.shrink();
    final toDriver = AppPreferences.getDriverId() != 1;
    return IconButton(
      tooltip: toDriver ? 'Driver mode' : 'Office mode',
      icon: Icon(toDriver ? Icons.local_shipping_outlined : Icons.business_center_outlined,
          size: isTablet ? 28 : 25),
      onPressed: () => switchMode(context, toDriver: toDriver),
    );
  }

  /// Asks, switches and opens the new mode's home dashboard. On a refusal the
  /// user stays signed in where he is. Returns true when the mode changed.
  static Future<bool> switchMode(BuildContext context, {required bool toDriver, String? question}) async {
    final ok = await ConfirmationMsgYesNo(
        context, question ?? (toDriver ? 'Switch to Driver mode?' : 'Switch to Office mode?'));
    if (!ok) return false;
    try {
      final session = await sl<SessionService>().switchMode(toDriver: toDriver);
      // the bell belongs to the other record now
      if (sl.isRegistered<NotificationSummaryCubit>()) sl<NotificationSummaryCubit>().clear();
      if (!context.mounted) return true;
      context.go(dashboardRouteFor(
          isDriver: session.isDriver, roleId: session.roleId, permissionId: session.permissionId));
      return true;
    } on MobileAuthFailure catch (e) {
      Fluttertoast.showToast(msg: e.message);
      return false;
    }
  }
}
