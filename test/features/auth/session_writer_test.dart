import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/models/shared/menu_master_model.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/mobile_session.dart';
import 'package:maleva/features/auth/data/session_writer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/session/session_token_store_test.dart' show MemoryStore;

MobileSession fixture({bool driver = false, List<MenuMasterModel>? menu}) => MobileSession(
      token: 'synthetic.jwt',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(1790000000000),
      sessionExpiresAt: DateTime.fromMillisecondsSinceEpoch(1800000000000),
      isDriver: driver,
      userId: 41,
      companyId: 6,
      mComid: 1,
      companyName: 'FIXTURE CO',
      rulesType: driver ? '' : 'SALES',
      roleId: driver ? 0 : 300,
      permissionId: 1,
      truckRefId: driver ? 12 : 0,
      truckName: driver ? 'VBC 5521' : '',
      menu: menu ??
          [
            MenuMasterModel('Transaction', 1, 6, 0, 1, 1, 1, 1),
            MenuMasterModel('Sales Order', 51, 1, 1, 1, 1, 1, 1),
            MenuMasterModel('', 99, 6, 0, 1, 1, 1, 1),
            MenuMasterModel('Logout', 9, 6, 0, 1, 1, 1, 1),
          ],
    );

void main() {
  late MemoryStore platform;
  late SessionWriter writer;

  setUp(() async {
    // an earlier version's saved credentials and a stale cached menu
    SharedPreferences.setMockInitialValues({
      'Username': 'old-user',
      'Password': 'old-pass',
      'OldUsername': '7',
      'loadmenu': jsonEncode([{'FormText': 'Stale', 'Id': 3, 'ParentId': 0}]),
    });
    await AppPreferences.init();
    platform = MemoryStore();
    writer = SessionWriter(SessionTokenStore(platform));
  });

  test('an employee session writes every key and global the app reads, and no password', () async {
    await writer.write(fixture());

    final prefs = AppPreferences.raw;
    expect(prefs.getInt('EmpRefId'), 41);
    expect(prefs.getString('EnquiryOpen'), 'false');
    expect(prefs.getInt('DriverId'), 0);
    expect(prefs.getString('RulesType'), 'SALES');
    expect(prefs.getInt('Comid'), 6);
    expect(prefs.getInt('MComid'), 1);
    expect(prefs.getInt('role_id'), 300);
    expect(prefs.getInt('PermissionId'), 1);
    expect(AppGlobals.selectedCompanyName, 'FIXTURE CO');
    expect([AppGlobals.EmpRefId, AppGlobals.Comid, AppGlobals.DriverLogin, AppGlobals.DriverTruckRefId], [41, 6, 0, 0]);
    expect(platform.values[SessionTokenStore.tokenKey], 'synthetic.jwt');

    // no new credential is written; the old ones are left to the restore step to delete
    expect(prefs.getString('Username'), 'old-user');
    expect(prefs.getString('Password'), 'old-pass');
    expect(prefs.getString('OldUsername'), '7');
    expect(prefs.getKeys().where((k) => prefs.get(k) == 'synthetic.jwt'), isEmpty, reason: 'token only in secure storage');
  });

  test('a driver session sets the driver flag and truck', () async {
    await writer.write(fixture(driver: true));

    expect(AppPreferences.getDriverId(), 1);
    expect(AppPreferences.getRoleId(), 0);
    expect(AppGlobals.DriverLogin, 1);
    expect(AppGlobals.DriverTruckRefId, 12);
    expect(AppGlobals.DriverTruckName, 'VBC 5521');
  });

  test('the menu always comes from the session, replacing a cached one; unlabelled rows are dropped', () async {
    AppGlobals.objMenuMaster = [MenuMasterModel('Stale', 3, 6, 0, 1, 1, 1, 1)];
    AppGlobals.parentclass = [MenuMasterModel('Stale', 3, 6, 0, 1, 1, 1, 1)];

    await writer.write(fixture());

    expect(AppGlobals.objMenuMaster.map((m) => m.FormText), ['Transaction', 'Sales Order', 'Logout']);
    expect(AppGlobals.parentclass.map((m) => m.FormText), ['Transaction', 'Logout']);
    final cached = jsonDecode(AppPreferences.getLoadMenu()) as List;
    expect(cached.map((m) => m['FormText']), ['Transaction', 'Sales Order', 'Logout']);
  });
}
