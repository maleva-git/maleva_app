

import 'dart:convert';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_services/auth_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

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
      // 1. Get Token
      final fcmToken = AppPreferences.getFcmToken();

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
      } else if (value.StatusCode != 500) {
        throw Exception('Invalid Username & Password');
      } else {
        throw Exception(value.Message ?? 'Server Error');
      }
    } catch (e) {
      rethrow;
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

    objfun.selectedCompanyName = data['CompanyName'] ?? '';
    objfun.EmpRefId = idNew;

    await AppPreferences.setEnquiryOpen('false');
    await AppPreferences.setUsername(username);
    await AppPreferences.setPassword(password);
    await AppPreferences.setDriverId(driverId);
    await AppPreferences.setRulesType(data['RulesType'] ?? '');
    await AppPreferences.setComid(comid);
    await AppPreferences.setMComid(mComid);
    await AppPreferences.setOldUsername(idNew.toString());

    objfun.Comid = comid;
    objfun.DriverTruckRefId = data['TruckRefId'] ?? 0;
    objfun.DriverTruckName  = data['TruckName'] ?? '';

    // Menu data caching logic
    if (oldUsername.isEmpty) {
      final menudata = value.data3 ?? [];
      if (menudata.isNotEmpty) {
        objfun.objMenuMaster.clear();
        objfun.parentclass.clear();
        await AppPreferences.setLoadMenu(json.encode(menudata));
        for (var item in menudata) {
          objfun.objMenuMaster.add(MenuMasterModel.fromJson(item));
        }
        objfun.parentclass.addAll(
          objfun.objMenuMaster.where((e) => e.ParentId == 0),
        );
      }
    } else {
      final temp = AppPreferences.getLoadMenu();
      if (temp.isNotEmpty && temp != 'null') {
        final menudata = json.decode(temp) as List;
        objfun.objMenuMaster.clear();
        objfun.parentclass.clear();
        for (var item in menudata) {
          if (item['FormText'] == null) continue;
          objfun.objMenuMaster.add(MenuMasterModel.fromJson(item));
        }
        objfun.parentclass.addAll(
          objfun.objMenuMaster.where((e) => e.ParentId == 0),
        );
      }
    }
  }
}