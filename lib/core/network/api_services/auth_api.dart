import 'dart:convert';
import '../../models/model.dart';
import '../../utils/clsfunction.dart' as objfun;
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/utils/app_preferences.dart';

class AuthApi {


  static Future<bool> loginUser(String username, String password, String oldUsername, int driverId) async {
    try {

      String currentFcmToken = AppPreferences.getFcmToken();

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Token': currentFcmToken,
      };

      String url = "${ApiConstants.apiLoginSuccess}$username&Pwd=$password&olduserid=$oldUsername&DriverId=$driverId";

      final result = await ApiClient.postRequest(
        url,
        null,
        headers: header,
      );

      if (result == null) {
        throw Exception("No response from server");
      }

      if (result is Map<String, dynamic>) {
        ResponseViewModel? value = ResponseViewModel.fromJson(result);

        if (value.IsSuccess == true) {

          var IdNew = value.data1[0]["UserId"] ?? 0;
          var Comid = value.data1[0]["Comid"] ?? 0;
          var MComid = value.data1[0]["MComid"] ?? 0;
          objfun.selectedCompanyName = value.data1[0]["CompanyName"] ?? '';
          objfun.EmpRefId = value.data1[0]["UserId"];
          objfun.storagenew.setString('EnquiryOpen', "false");

          if (IdNew != "") {
            objfun.storagenew.setString('Username', username);
            objfun.storagenew.setString('Password', password);
            objfun.storagenew.setInt('DriverId', driverId);

            objfun.storagenew.setString('RulesType', value.data1[0]["RulesType"] ?? '');
            objfun.storagenew.setInt('Comid', Comid);
            objfun.Comid = objfun.storagenew.getInt('Comid') ?? 0;
            objfun.DriverTruckRefId = value.data1[0]["TruckRefId"] ?? 0;
            objfun.DriverTruckName = value.data1[0]["TruckName"] ?? '';
            objfun.storagenew.setInt('MComid', MComid);
            objfun.storagenew.setString('OldUsername', IdNew.toString());

            if (oldUsername == "") {
              var menudata = value.data3 ?? [];
              if (menudata != null && menudata.isNotEmpty) {
                objfun.objMenuMaster.clear();
                objfun.parentclass.clear();
                objfun.storagenew.setString('loadmenu', json.encode(menudata));
                for (int i = 0; i < menudata.length; i++) {
                  objfun.objMenuMaster.add(MenuMasterModel.fromJson(menudata[i]));
                }
                objfun.parentclass.addAll(objfun.objMenuMaster.where((element) => element.ParentId == 0).toList());
              }
            } else {
              String? temp1 = objfun.storagenew.getString('loadmenu');
              if (temp1 != null && temp1 != 'null') {
                var decoded = json.decode(temp1);
                List menudata = decoded;

                if (menudata != null && menudata.isNotEmpty) {
                  objfun.objMenuMaster.clear();
                  objfun.parentclass.clear();
                  for (int i = 0; i < menudata.length; i++) {
                    if (menudata[i]['FormText'] == null) {
                      continue;
                    }
                    objfun.objMenuMaster.add(MenuMasterModel.fromJson(menudata[i]));
                  }
                  objfun.parentclass.addAll(objfun.objMenuMaster.where((element) => element.ParentId == 0).toList());
                }
              }
            }
          }

          return true; // Success na true return pandrom
        }
        else if (value.StatusCode != 500) {
          throw Exception("Invalid Username & Password");
        }
        else {
          throw Exception(value.Message ?? "Server Error");
        }
      }
      else {
        throw Exception("Unexpected response format from server");
      }

    } catch (error) {
      // Inga already catch aana error-a apdiye BLoC-ku anuppurom
      rethrow;
    }
  }
}