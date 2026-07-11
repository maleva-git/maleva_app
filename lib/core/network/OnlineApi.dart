import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/model.dart';
import 'api_client.dart';

Future<bool> Login(String Username, String Password, String OldUsername,int DriverId, context) async {
  try {

    int flag = 0;
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Token':AppGlobals.mobiletoken,
    };
    try {
  final result = await AppGlobals.apiAllinoneSelectArrayWithOutAuth(Uri.encodeFull("${AppGlobals.apiLoginSuccess}$Username&Pwd=$Password&olduserid=$OldUsername&DriverId=$DriverId"),
            null,
            header,
            context);
  if (result != null) {

        if (result is Map<String, dynamic>) {
          ResponseViewModel? value = ResponseViewModel.fromJson(result);


          if (value.IsSuccess == true) {
            var IdNew = value.data1[0]["UserId"] ?? 0;
            var Comid = value.data1[0]["Comid"] ?? 0;
            var MComid = value.data1[0]["MComid"] ?? 0;
            AppGlobals.selectedCompanyName = value.data1[0]["CompanyName"] ?? '';
            AppGlobals.EmpRefId = value.data1[0]["UserId"];
            AppGlobals.storagenew.setString('EnquiryOpen', "false");
            if (IdNew != "") {
              AppGlobals.storagenew.setString('Username', Username);
              AppGlobals.storagenew.setString('Password', Password);
              AppGlobals.storagenew.setInt('DriverId', DriverId);
              AppGlobals.DriverLogin = DriverId;

              AppGlobals.storagenew.setString(
                  'RulesType', value.data1[0]["RulesType"] ?? '');
              AppGlobals.storagenew.setInt('Comid', Comid);
              AppGlobals.Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
              AppGlobals.DriverTruckRefId = value.data1[0]["TruckRefId"] ?? 0;
              AppGlobals.DriverTruckName = value.data1[0]["TruckName"] ?? '';
              AppGlobals.storagenew.setInt('MComid', MComid);
              AppGlobals.storagenew.setString('OldUsername', IdNew.toString());
              if (OldUsername == "") {
                var menudata = value.data3 ?? [];
                if (menudata != null && menudata.isNotEmpty) {
                  AppGlobals.objMenuMaster.clear();
                  AppGlobals.parentclass.clear();
                  AppGlobals.storagenew.setString(
                      'loadmenu', json.encode(menudata));
                  for (int i = 0; i < menudata.length; i++) {
                    AppGlobals.objMenuMaster
                        .add(MenuMasterModel.fromJson(menudata[i]));
                  }

                  AppGlobals.parentclass.addAll(AppGlobals.objMenuMaster
                      .where((element) => element.ParentId == 0)
                      .toList());
                }
              }
              else {
                String? temp1 = AppGlobals.storagenew.getString('loadmenu');
                if (temp1 != null && temp1 != 'null') {
                  var decoded = json.decode(temp1);
                  List menudata = decoded;

                  if (menudata != null && menudata.isNotEmpty) {
                    AppGlobals.objMenuMaster.clear();
                    AppGlobals.parentclass.clear();
                    for (int i = 0; i < menudata.length; i++) {
                      if (menudata[i]['FormText'] == null) {
                        continue;
                      }
                      AppGlobals.objMenuMaster
                          .add(MenuMasterModel.fromJson(menudata[i]));
                    }
                    AppGlobals.parentclass.addAll(AppGlobals.objMenuMaster
                        .where((element) => element.ParentId == 0)
                        .toList());
                  }
                }
              }
            }
            flag = 1;
          }
          else if (value.StatusCode != 500) {
            msgshow(
                "Invaild Username & Password",
                "",
                Colors.white,
                Colors.green,
                null,
                18.00 - AppGlobals.reducesize,
                AppGlobals.tll,
                AppGlobals.tgc,
                context,
                2);
            flag = 0;
          }
          else {
            msgshow(
                value.Message,
                value.data1,
                Colors.white,
                Colors.red,
                null,
                18.00 - AppGlobals.reducesize,
                AppGlobals.tll,
                AppGlobals.tgc,
                context,
                2);
            flag = 0;
          }
        }

        else {
          msgshow(
            "Unexpected response from server",
            "",
            Colors.white,
            Colors.red,
            null,
            18.00 - AppGlobals.reducesize,
            AppGlobals.tll,
            AppGlobals.tgc,
            context,
            2,
          );
          flag = 0;
        }
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
      flag = 0;
}

    if (flag == 1) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    return false;
  }
}

Future SelectUser(context) async {
  try {
    AppGlobals.UserList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiSelectUser}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.UserList = resultData
            .map((element) => UserLoginModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectCustomer(context) async {
  try {
    AppGlobals.CustomerList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiSelectCustomer}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.CustomerList = resultData
            .map((element) => CustomerModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectLocation(context) async {
  try {
    AppGlobals.LocationList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
        Uri.encodeFull("${AppGlobals.apiSelectLocation}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.LocationList = resultData
            .map((element) => LocationModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectWareHouse(context) async {
  try {
    AppGlobals.WareHouseList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelectArrayWithOutAuth(
        Uri.encodeFull("${AppGlobals.apiWareHouseCombo}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.WareHouseList = resultData["Data1"]
            .map((element) => WareHouseModel.fromJson(element))
            .toList().cast<WareHouseModel>();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectStockJob(context) async {
  try {
    AppGlobals.StockJobList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelectArrayWithOutAuth(
        Uri.encodeFull("${AppGlobals.apiSelectStockJob}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.StockJobList = resultData["Data1"]
            .map((element) => WareHouseModel.fromJson(element))
            .toList().cast<WareHouseModel>();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectEmployee(context, String type, String type1) async {
  try {
    AppGlobals.EmployeeList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiSelectEmployee}$Comid&type=$type&type1=$type1"),
            null,
            null,
            context);
  if (resultData.isNotEmpty) {
        AppGlobals.EmployeeList = resultData
            .map((element) => EmployeeModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectJobStatus(context) async {
  try {
    AppGlobals.JobStatusList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiSelectJobStatus}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.JobStatusList = resultData
            .map((element) => JobStatusModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future MaxSaleOrderNo(context, String BillType) async {
  try {
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiGetString(
            "${AppGlobals.apiMaxSaleOrderNo}$Comid&BillType=$BillType");
  if (resultData.isNotEmpty) {
        AppGlobals.MaxSaleOrderNum = resultData;
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,

          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future MaxStockNo(context) async {
  try {
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelectArray(
            Uri.encodeFull("${AppGlobals.apiMaxStockNo}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
       // var checkdata = resultData["Data1"];
        AppGlobals.MaxStockNum = resultData["Data1"];
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectJobType(context) async {
  try {
    AppGlobals.JobTypeList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiSelectJobType}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.JobTypeList = resultData
            .map((element) => JobTypeModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAllJobStatus(context, int Jobid) async {
  try {
    AppGlobals.JobAllStatusList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiSelectAllJobStatus}$Comid&Jobid=$Jobid"),
            null,
            null,
            context);
  if (resultData.isNotEmpty) {
        var resultDetails = resultData[0]["JobTypeDetails"];
        var result = resultData[0]["JobStatusDetails"];
        AppGlobals.JobAllStatusList = result
            .map((element) => JobAllStatusModel.fromJson(element))
            .toList()
            .cast<JobAllStatusModel>();
        AppGlobals.JobTypeDetailsList = resultDetails
            .map((element) => JobTypeDetailsModel.fromJson(element))
            .toList()
            .cast<JobTypeDetailsModel>();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAgentCompany(context) async {
  try {
    AppGlobals.AgentCompanyList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiSelectAgentCompany}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.AgentCompanyList = resultData
            .map((element) => AgentCompanyModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAgentAll(context, int AgentCompanyId) async {
  try {
    AppGlobals.AgentAllList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiSelectAgentAll}$Comid&Jobid=$AgentCompanyId"),
            null,
            null,
            context);
  if (resultData.isNotEmpty) {
        AppGlobals.AgentAllList =
            resultData.map((element) => AgentModel.fromJson(element)).toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectProductList(context) async {
  try {
    AppGlobals.ProductList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiGetProductList}$Comid"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.ProductList = resultData
            .map((element) => ProductModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}



// Context illa clean code!
Future<List<dynamic>?> selectAddressList() async {
  try {
    AppGlobals.AddressList.clear();
    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    // Call ApiClient.postRequest and pass null for the body
    final resultData = await ApiClient.postRequest(
      "${AppGlobals.apiSelectAddressList}$comId",
      null,
    );

    // ApiClient decodes the response automatically.
    // We just ensure it's returned as a List safely.
    if (resultData is List) {
      return resultData;
    } else if (resultData != null) {
      return [resultData]; // Wrap in list if a map is returned
    }

    return [];

  } on TimeoutException {
    throw Exception("Server timeout. Please try again.");
  } on SocketException {
    throw Exception("No internet connection.");
  } catch (error) {
    // ApiClient already gives clean error messages,
    // so we can just pass them along smoothly.
    throw Exception(error.toString().replaceAll('Exception: ', ''));
  }
}

// Future<void> SelectAddressList(BuildContext context) async {
//   try {
//     AppGlobals.AddressList.clear();
//
//     final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
//
//     final resultData = await objfun
//         .apiAllinoneSelect(
//       "${AppGlobals.apiSelectAddressList}$comId",
//       null,
//       null,
//       context,
//     )
//         .timeout(const Duration(seconds: 15));
//
//     if (resultData != null && resultData.isNotEmpty) {
//       AppGlobals.AddressList = resultData;
//     }
//
//   } on TimeoutException {
//     _showError(context, "Server timeout. Please try again.");
//   } on SocketException {
//     _showError(context, "No internet connection.");
//   } on HttpException {
//     _showError(context, "Server error occurred.");
//   } catch (error, stackTrace) {
//     _showError(context, error.toString());
//     debugPrint(stackTrace.toString());
//   }
// }


void _showError(BuildContext context, String message) {
  msgshow(
    message,
    "",
    Colors.white,
    Colors.red,
    null,
    18.00 - AppGlobals.reducesize,
    AppGlobals.tll,
    AppGlobals.tgc,
    context,
    2,
  );
}

Future EditSalesOrder(int Id, int SaleNo, {BuildContext? context}) async {
  try {
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    var resultData = await AppGlobals.apiAllinoneSelect(
        Uri.encodeFull("${AppGlobals.apiEditSalesOrder}$Id&SaleorderNo=$SaleNo&Comid=$Comid"),
        null, null, context);

    if (resultData != null && resultData.isNotEmpty) {
      AppGlobals.SaleEditMasterList = resultData;
      AppGlobals.SaleEditDetailList = resultData[0]["SaleDetails"]
          .map((element) => SaleEditDetailModel.fromJson(element))
          .toList()
          .cast<SaleEditDetailModel>();
    } else {
      throw Exception("Data empty ah iruku");
    }
  } catch (error) {
    throw Exception("Sales Order failed: $error");
  }
}


Future loadCustomerCurrency(context, int CustomerId) async {
  try {
AppGlobals.CustomerCurrencyValue = 0.0;
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelectArray(
        Uri.encodeFull("${AppGlobals.apiGetCurrencyValue}$Comid&CustId=$CustomerId"),
        null,
        null,
        context);
  if (resultData.length != 0) {
        AppGlobals.CustomerCurrencyValue = resultData["Data1"];
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}
Future loadComboS1(context, int type) async {
  try {
    AppGlobals.ComboS1List=[];
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelectArray(
            Uri.encodeFull("${AppGlobals.apiGetComboS1}$Comid&type=$type"),
            null,
            null,
            context);
  if (resultData.length != 0) {
        AppGlobals.ComboS1List.add(resultData["Data1"]);
        AppGlobals.ComboS1List.add(resultData["Data2"]);
        AppGlobals.ComboS1List.add(resultData["Data3"]);
        AppGlobals.ComboS1List.add(resultData["Data4"]);
        AppGlobals.ComboS1List.add(resultData["Data5"]);
        AppGlobals.ComboS1List.add(resultData["Data6"]);

      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}
Future EditPlanning(context, int Id, int PlanningNo) async {
  try {
    // AppGlobals.PlanningEditList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiEditPlanning}$Id&PLANINGNo=$PlanningNo&Comid=$Comid"),
            null,
            null,
            context);
  if (resultData.isNotEmpty) {
        AppGlobals.PlanningEditList = resultData[0]["SaleDetails"].toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}
Future EditVesselPlanning(context, int Id, int PlanningNo) async {
  try {
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
        Uri.encodeFull("${AppGlobals.apiEditVesselPlanning}$Id&VESSELPLANINGNo=$PlanningNo&Comid=$Comid"),
        null,
        null,
        context);
  if (resultData.isNotEmpty) {
        AppGlobals.VesselPlanningEditList = resultData[0]["SaleDetails"].toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}
Future DeleteSalesOrder(context, int Id) async {
  try {
    // AppGlobals.AddressList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelectArray(
            Uri.encodeFull("${AppGlobals.apiDeleteSalesOrder}$Id&Comid=$Comid"),
            null,
            null,
            context);
  if (resultData.length != 0) {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          await ConfirmationOK(value.Message, context);
        }
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAddressDetails(context, String Keyword) async {
  try {
    AppGlobals.AddressDetailedList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
            Uri.encodeFull("${AppGlobals.apiSelectAddressDetails}$Comid&KeyWord=$Keyword"),
            null,
            null,
            context);
  if (resultData.isNotEmpty) {
        AppGlobals.AddressDetailedList = resultData
            .map((element) => AddressDetailsModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future GetJobNoForwarding(context,int BillId) async {
  try {
    AppGlobals.ForwardingList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelectArray(
        Uri.encodeFull("${AppGlobals.apiGetJobNo}$Comid&JobType=$BillId"), null, null, context);
  if (resultData.length != 0) {   
        AppGlobals.ForwardingList = resultData["Data1"]
            .map((element) => ForwardingModel.fromJson(element))
            .toList().cast<ForwardingModel>();
        AppGlobals.JobNoList =  resultData["Data1"].toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future<void> GetRTINoForwarding(BuildContext ?context, int billId) async {
  try {
    // Clear existing job list
    AppGlobals.JobNoList.clear();

    // Get company ID from storage
    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    // Construct the API URL
    final String apiUrl = '${AppGlobals.apiGetRTINo}$comId';

    // Call the API
    final resultData = await AppGlobals.apiAllinoneSelectArray(
        apiUrl, null, null, context);

    // Check response validity and content
    if (resultData != null && resultData is List) {
      final List<dynamic> dataList = resultData;

      // Clear existing job list
      AppGlobals.JobNoList.clear();

      for (var item in dataList) {
        // Safety check: ensure item is a Map
        if (item is Map<String, dynamic>) {
          final String cNumber = item['RTINoDisplay']?.toString() ?? '';
          final int id = item['Id'] ?? 0;

          AppGlobals.JobNoList.add({
            'CNumber': cNumber,
            'Id': id,
          });
        }
      }
    } else {
      AppGlobals.JobNoList = []; // Default to empty list
    }
  }
  catch (error, stackTrace) {
    msgshow(
      error.toString(),
      stackTrace.toString(),
      Colors.white,
      Colors.red,
      null,
      18.00 - AppGlobals.reducesize,
      AppGlobals.tll,
      AppGlobals.tgc,
      context,
      2,
    );
  }
}
Future SelectTruckList(context,String? Type) async {
  try {
    AppGlobals.GetTruckList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
        Uri.encodeFull("${AppGlobals.apiGetTruckList}$Comid&type="), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.GetTruckList = resultData
            .map((element) => GetTruckModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future EditTruckList(context,int Keyword,String Column,String? Type) async {
  try {
    AppGlobals.TruckDetailsList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
        Uri.encodeFull("${AppGlobals.apiEditTruckDetails}$Comid&Startindex=0&PageCount=0&Keyword=$Keyword&Column=$Column&type="), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.TruckDetailsList = resultData
            .map((element) => TruckDetailsModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectDriverList(context,String? Type) async {
  try {
    AppGlobals.GetDriverList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
        Uri.encodeFull("${AppGlobals.apiGetDriverList}$Comid&type="), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.GetDriverList = resultData
            .map((element) => GetTruckModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectRTIDetailViewList(context,String Fromdate,String Todate,int DId, int TId, int Employeeid,String Search) async {
  try {
    AppGlobals.RTIViewMasterList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
        Uri.encodeFull("${AppGlobals.apiSelectRTIDetailsView}$Comid&Fromdate=$Fromdate&Todate=$Todate&DId=$DId&TId=$TId&Employeeid=$Employeeid&Search$Search"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.RTIViewMasterList = resultData[0]["salemaster"]
            .map((element) => RTIMasterViewModel.fromJson(element))
            .toList();
        AppGlobals.RTIViewDetailList = resultData[0]["saledetails"]
            .map((element) => RTIDetailsViewModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectRTIViewList(context,String Fromdate,String Todate,int DId, int TId, int Employeeid,String Search) async {
  try {
    AppGlobals.RTIViewMasterList.clear();
    var Comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    try {
  final resultData = await AppGlobals.apiAllinoneSelect(
        Uri.encodeFull("${AppGlobals.apiSelectRTIView}$Comid&Fromdate=$Fromdate&Todate=$Todate&DId=$DId&TId=$TId&Employeeid=$Employeeid&Search=$Search"), null, null, context);
  if (resultData.isNotEmpty) {
        AppGlobals.RTIViewMasterList = resultData[0]["salemaster"]
            .map((element) => RTIMasterViewModel.fromJson(element))
            .toList();
        AppGlobals.RTIViewDetailList = resultData[0]["saledetails"]
            .map((element) => RTIDetailsViewModel.fromJson(element))
            .toList();
      }
} catch (error, stackTrace) {
  msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - AppGlobals.reducesize,
          AppGlobals.tll,
          AppGlobals.tgc,
          context,
          2);
}

  } catch (error) {
    if (error.toString() == "") {}
  }
}

