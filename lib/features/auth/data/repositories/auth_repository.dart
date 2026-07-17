

import 'dart:convert';
import 'package:maleva/core/network/api_services/auth_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/shared/menu_master_model.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';

class AuthRepository {
  final AuthApi authApi;

  AuthRepository({required this.authApi});

  Future<bool> loginUser({
    required String username,
    required String password,
    required String oldUsername,
    required int driverId,
  }) async {
    try {
      // 1. Get FCM Token — wait for it if not yet available (first-launch race condition)
      String fcmToken = AppPreferences.getFcmToken();
      if (fcmToken.isEmpty) {
        try {
          await AppGlobals.getDeviceToken()
              .timeout(const Duration(seconds: 5), onTimeout: () {});
          fcmToken = AppPreferences.getFcmToken(); // retry after fetch
        } catch (_) {
          // FCM unavailable — proceed with empty token, server handles it
        }
      }

      // 2. Fetch raw data from API
      final rawData = await authApi.loginUserRaw(
        username: username,
        password: password,
        oldUsername: oldUsername,
        driverId: driverId,
        fcmToken: fcmToken,
      );

      // 3. Parse Data to Domain Model
      final value = ResponseViewModel.fromJson(rawData);

      // 4. Handle Business Logic & Update Local Cache
      if (value.IsSuccess == true) {
        await _saveLoginData(value, username, password, driverId, oldUsername);
        return true;
      } else {
        throw Exception('Invalid Username & Password');
      }
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('connection') ||
          errStr.contains('timeout') ||
          errStr.contains('network') ||
          errStr.contains('socket')) {
        rethrow;
      }
      throw Exception('Invalid Username & Password');
    }
  }

  Future<void> _saveLoginData(
      ResponseViewModel value,
      String username,
      String password,
      int driverId,
      String oldUsername,
      ) async {
    final data = value.data1[0];
    final idNew = data['UserId'] ?? 0;
    final comid = data['Comid'] ?? 0;
    final mComid = data['MComid'] ?? 0;

    AppGlobals.selectedCompanyName = data['CompanyName'] ?? '';
    AppGlobals.EmpRefId = idNew;

    await AppPreferences.setEmpRefId(idNew);
    await AppPreferences.setEnquiryOpen('false');
    await AppPreferences.setUsername(username);
    await AppPreferences.setPassword(password);
    await AppPreferences.setDriverId(driverId);
    await AppPreferences.setRulesType(data['RulesType'] ?? '');
    await AppPreferences.setComid(comid);
    await AppPreferences.setMComid(mComid);
    await AppPreferences.setOldUsername(idNew.toString());
    await AppPreferences.setRoleId(data['role_id'] ?? 0);
    await AppPreferences.setPermissionId(data['PermisionId'] ?? 0);

    AppGlobals.Comid = comid;
    AppGlobals.DriverTruckRefId = data['TruckRefId'] ?? 0;
    AppGlobals.DriverTruckName  = data['TruckName'] ?? '';

    // Menu data caching logic
    if (oldUsername.isEmpty) {
      final menudata = value.data3 ?? [];
      if (menudata.isNotEmpty) {
        AppGlobals.objMenuMaster.clear();
        AppGlobals.parentclass.clear();
        await AppPreferences.setLoadMenu(json.encode(menudata));
        for (var item in menudata) {
          AppGlobals.objMenuMaster.add(MenuMasterModel.fromJson(item));
        }
        AppGlobals.parentclass.addAll(
          AppGlobals.objMenuMaster.where((e) => e.ParentId == 0),
        );
      }
    } else {
      final temp = AppPreferences.getLoadMenu();
      if (temp.isNotEmpty && temp != 'null') {
        final menudata = json.decode(temp) as List;
        AppGlobals.objMenuMaster.clear();
        AppGlobals.parentclass.clear();
        for (var item in menudata) {
          if (item['FormText'] == null) continue;
          AppGlobals.objMenuMaster.add(MenuMasterModel.fromJson(item));
        }
        AppGlobals.parentclass.addAll(
          AppGlobals.objMenuMaster.where((e) => e.ParentId == 0),
        );
      }
    }
  }
}