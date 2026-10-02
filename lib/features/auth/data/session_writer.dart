import 'dart:convert';

import 'package:maleva/core/models/shared/menu_master_model.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/mobile_session.dart';

/// Writes a Java session where the rest of the app reads it.
///
/// One writer for sign-in and session restore, so both always leave the same
/// state. Every module still reads the same preference keys (`Comid`,
/// `EmpRefId`, `role_id`, `PermissionId`, `RulesType`, `DriverId`, `MComid`,
/// `loadmenu`) and `AppGlobals` fields as before the move to Java.
///
/// It never writes `Username`, `Password` or `OldUsername`: the password is not
/// kept on the device, and `OldUsername` only drove the old stale-menu rule.
class SessionWriter {
  SessionWriter(this._tokens);

  final SessionTokenStore _tokens;

  Future<void> write(MobileSession session) async {
    await _tokens.save(session.token, session.sessionExpiresAt);

    await AppPreferences.setEmpRefId(session.userId);
    await AppPreferences.setEnquiryOpen('false');
    await AppPreferences.setDriverId(session.isDriver ? 1 : 0);
    await AppPreferences.setRulesType(session.rulesType);
    await AppPreferences.setComid(session.companyId);
    await AppPreferences.setMComid(session.mComid);
    await AppPreferences.setRoleId(session.roleId);
    await AppPreferences.setPermissionId(session.permissionId);

    AppGlobals.selectedCompanyName = session.companyName;
    AppGlobals.EmpRefId = session.userId;
    AppGlobals.Comid = session.companyId;
    AppGlobals.DriverLogin = session.isDriver ? 1 : 0;
    AppGlobals.DriverTruckRefId = session.truckRefId;
    AppGlobals.DriverTruckName = session.truckName;

    await writeMenu(session.menu);
  }

  /// Replaces the drawer menu with [rows] - always the server's latest - and
  /// caches them in `loadmenu` for drawing the drawer. Rows without a label are
  /// left out, as before.
  static Future<void> writeMenu(List<MenuMasterModel> rows) async {
    final menu = rows.where((m) => m.FormText.isNotEmpty).toList();
    await AppPreferences.setLoadMenu(json.encode(menu.map((m) => m.toJson()).toList()));
    AppGlobals.objMenuMaster
      ..clear()
      ..addAll(menu);
    AppGlobals.parentclass
      ..clear()
      ..addAll(menu.where((m) => m.ParentId == 0));
  }
}
