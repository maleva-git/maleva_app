import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';

import '../utils/clsfunction.dart';

Future<bool> Login(String Username, String Password, String OldUsername,int DriverId, context) async {
  try {

    int flag = 0;
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Token':objfun.mobiletoken,
    };
    await objfun.apiAllinoneSelectArrayWithOutAuth("${objfun.apiLoginSuccess}$Username&Pwd=$Password&olduserid=$OldUsername&DriverId=$DriverId",
            null,
            header,
            context)
        .then((result) {
      if (result != null) {

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
              objfun.storagenew.setString('Username', Username);
              objfun.storagenew.setString('Password', Password);
              objfun.storagenew.setInt('DriverId', DriverId);

              objfun.storagenew.setString(
                  'RulesType', value.data1[0]["RulesType"] ?? '');
              objfun.storagenew.setInt('Comid', Comid);
              objfun.Comid = objfun.storagenew.getInt('Comid') ?? 0;
              objfun.DriverTruckRefId = value.data1[0]["TruckRefId"] ?? 0;
              objfun.DriverTruckName = value.data1[0]["TruckName"] ?? '';
              objfun.storagenew.setInt('MComid', MComid);
              objfun.storagenew.setString('OldUsername', IdNew.toString());
              if (OldUsername == "") {
                var menudata = value.data3 ?? [];
                if (menudata != null && menudata.isNotEmpty) {
                  objfun.objMenuMaster.clear();
                  objfun.parentclass.clear();
                  objfun.storagenew.setString(
                      'loadmenu', json.encode(menudata));
                  for (int i = 0; i < menudata.length; i++) {
                    objfun.objMenuMaster
                        .add(MenuMasterModel.fromJson(menudata[i]));
                  }

                  objfun.parentclass.addAll(objfun.objMenuMaster
                      .where((element) => element.ParentId == 0)
                      .toList());
                }
              }
              else {
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
                      objfun.objMenuMaster
                          .add(MenuMasterModel.fromJson(menudata[i]));
                    }
                    objfun.parentclass.addAll(objfun.objMenuMaster
                        .where((element) => element.ParentId == 0)
                        .toList());
                  }
                }
              }
            }
            flag = 1;
          }
          else if (value.StatusCode != 500) {
            objfun.msgshow(
                "Invaild Username & Password",
                "",
                Colors.white,
                Colors.green,
                null,
                18.00 - objfun.reducesize,
                objfun.tll,
                objfun.tgc,
                context,
                2);
            flag = 0;
          }
          else {
            objfun.msgshow(
                value.Message,
                value.data1,
                Colors.white,
                Colors.red,
                null,
                18.00 - objfun.reducesize,
                objfun.tll,
                objfun.tgc,
                context,
                2);
            flag = 0;
          }
        }

        else {
          objfun.msgshow(
            "Unexpected response from server",
            "",
            Colors.white,
            Colors.red,
            null,
            18.00 - objfun.reducesize,
            objfun.tll,
            objfun.tgc,
            context,
            2,
          );
          flag = 0;
        }
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
      flag = 0;
    });
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
    objfun.UserList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiSelectUser}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.UserList = resultData
            .map((element) => UserLoginModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectCustomer(context) async {
  try {
    objfun.CustomerList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiSelectCustomer}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.CustomerList = resultData
            .map((element) => CustomerModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectLocation(context) async {
  try {
    objfun.LocationList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
        "${objfun.apiSelectLocation}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.LocationList = resultData
            .map((element) => LocationModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectWareHouse(context) async {
  try {
    objfun.WareHouseList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelectArrayWithOutAuth(
        "${objfun.apiWareHouseCombo}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.WareHouseList = resultData["Data1"]
            .map((element) => WareHouseModel.fromJson(element))
            .toList().cast<WareHouseModel>();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectStockJob(context) async {
  try {
    objfun.StockJobList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelectArrayWithOutAuth(
        "${objfun.apiSelectStockJob}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.StockJobList = resultData["Data1"]
            .map((element) => WareHouseModel.fromJson(element))
            .toList().cast<WareHouseModel>();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectEmployee(context, String type, String type1) async {
  try {
    objfun.EmployeeList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiSelectEmployee}$Comid&type=$type&type1=$type1",
            null,
            null,
            context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.EmployeeList = resultData
            .map((element) => EmployeeModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectJobStatus(context) async {
  try {
    objfun.JobStatusList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiSelectJobStatus}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.JobStatusList = resultData
            .map((element) => JobStatusModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future MaxSaleOrderNo(context, String BillType) async {
  try {
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiGetString(
            "${objfun.apiMaxSaleOrderNo}$Comid&BillType=$BillType")
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.MaxSaleOrderNum = resultData;
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,

          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future MaxStockNo(context) async {
  try {
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelectArray(
            "${objfun.apiMaxStockNo}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
       // var checkdata = resultData["Data1"];
        objfun.MaxStockNum = resultData["Data1"];
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectJobType(context) async {
  try {
    objfun.JobTypeList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiSelectJobType}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.JobTypeList = resultData
            .map((element) => JobTypeModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAllJobStatus(context, int Jobid) async {
  try {
    objfun.JobAllStatusList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiSelectAllJobStatus}$Comid&Jobid=$Jobid",
            null,
            null,
            context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        var resultDetails = resultData[0]["JobTypeDetails"];
        var result = resultData[0]["JobStatusDetails"];
        objfun.JobAllStatusList = result
            .map((element) => JobAllStatusModel.fromJson(element))
            .toList()
            .cast<JobAllStatusModel>();
        objfun.JobTypeDetailsList = resultDetails
            .map((element) => JobTypeDetailsModel.fromJson(element))
            .toList()
            .cast<JobTypeDetailsModel>();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAgentCompany(context) async {
  try {
    objfun.AgentCompanyList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiSelectAgentCompany}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.AgentCompanyList = resultData
            .map((element) => AgentCompanyModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAgentAll(context, int AgentCompanyId) async {
  try {
    objfun.AgentAllList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiSelectAgentAll}$Comid&Jobid=$AgentCompanyId",
            null,
            null,
            context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.AgentAllList =
            resultData.map((element) => AgentModel.fromJson(element)).toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectProductList(context) async {
  try {
    objfun.ProductList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiGetProductList}$Comid", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.ProductList = resultData
            .map((element) => ProductModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future<void> SelectAddressList(BuildContext context) async {
  try {
    objfun.AddressList.clear();

    final int comId = objfun.storagenew.getInt('Comid') ?? 0;

    final resultData = await objfun
        .apiAllinoneSelect(
      "${objfun.apiSelectAddressList}$comId",
      null,
      null,
      context,
    )
        .timeout(const Duration(seconds: 15)); // ✅ VERY IMPORTANT

    if (resultData != null && resultData.isNotEmpty) {
      objfun.AddressList = resultData;
    }

  } on TimeoutException {
    _showError(context, "Server timeout. Please try again.");
  } on SocketException {
    _showError(context, "No internet connection.");
  } on HttpException {
    _showError(context, "Server error occurred.");
  } catch (error, stackTrace) {
    _showError(context, error.toString());
    debugPrint(stackTrace.toString());
  }
}


void _showError(BuildContext context, String message) {
  objfun.msgshow(
    message,
    "",
    Colors.white,
    Colors.red,
    null,
    18.00 - objfun.reducesize,
    objfun.tll,
    objfun.tgc,
    context,
    2,
  );
}


Future EditSalesOrder(context, int Id, int SaleNo) async {
  try {
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiEditSalesOrder}$Id&SaleorderNo=$SaleNo&Comid=$Comid",
            null,
            null,
            context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.SaleEditMasterList = resultData;
        objfun.SaleEditDetailList = resultData[0]["SaleDetails"]
            .map((element) => SaleEditDetailModel.fromJson(element))
            .toList()
            .cast<SaleEditDetailModel>();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}
Future loadCustomerCurrency(context, int CustomerId) async {
  try {
objfun.CustomerCurrencyValue = 0.0;
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetCurrencyValue}$Comid&CustId=$CustomerId",
        null,
        null,
        context)
        .then((resultData) {
      if (resultData.length != 0) {
        CustomerCurrencyValue = resultData["Data1"];
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}
Future loadComboS1(context, int type) async {
  try {
    objfun.ComboS1List=[];
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelectArray(
            "${objfun.apiGetComboS1}$Comid&type=$type",
            null,
            null,
            context)
        .then((resultData) {
      if (resultData.length != 0) {
        objfun.ComboS1List.add(resultData["Data1"]);
        objfun.ComboS1List.add(resultData["Data2"]);
        objfun.ComboS1List.add(resultData["Data3"]);
        objfun.ComboS1List.add(resultData["Data4"]);
        objfun.ComboS1List.add(resultData["Data5"]);
        objfun.ComboS1List.add(resultData["Data6"]);

      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}
Future EditPlanning(context, int Id, int PlanningNo) async {
  try {
    // objfun.PlanningEditList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiEditPlanning}$Id&PLANINGNo=$PlanningNo&Comid=$Comid",
            null,
            null,
            context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.PlanningEditList = resultData[0]["SaleDetails"].toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}
Future EditVesselPlanning(context, int Id, int PlanningNo) async {
  try {
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
        "${objfun.apiEditVesselPlanning}$Id&VESSELPLANINGNo=$PlanningNo&Comid=$Comid",
        null,
        null,
        context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.VesselPlanningEditList = resultData[0]["SaleDetails"].toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}
Future DeleteSalesOrder(context, int Id) async {
  try {
    // objfun.AddressList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelectArray(
            "${objfun.apiDeleteSalesOrder}$Id&Comid=$Comid",
            null,
            null,
            context)
        .then((resultData) async {
      if (resultData.length != 0) {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          await objfun.ConfirmationOK(value.Message, context);
        }
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectAddressDetails(context, String Keyword) async {
  try {
    objfun.AddressDetailedList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
            "${objfun.apiSelectAddressDetails}$Comid&KeyWord=$Keyword",
            null,
            null,
            context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.AddressDetailedList = resultData
            .map((element) => AddressDetailsModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future GetJobNoForwarding(context,int BillId) async {
  try {
    objfun.ForwardingList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetJobNo}$Comid&JobType=$BillId", null, null, context)
        .then((resultData) {
      if (resultData.length != 0) {   
        objfun.ForwardingList = resultData["Data1"]
            .map((element) => ForwardingModel.fromJson(element))
            .toList().cast<ForwardingModel>();
        objfun.JobNoList =  resultData["Data1"].toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future<void> GetRTINoForwarding(BuildContext context, int billId) async {
  try {
    // Clear existing job list
    objfun.JobNoList.clear();

    // Get company ID from storage
    final int comId = objfun.storagenew.getInt('Comid') ?? 0;

    // Construct the API URL
    final String apiUrl = '${objfun.apiGetRTINo}$comId';

    // Call the API
    final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl, null, null, context);

    // Check response validity and content
    if (resultData != null && resultData is List) {
      final List<dynamic> dataList = resultData;

      // Clear existing job list
      objfun.JobNoList.clear();

      for (var item in dataList) {
        // Safety check: ensure item is a Map
        if (item is Map<String, dynamic>) {
          final String cNumber = item['RTINoDisplay']?.toString() ?? '';
          final int id = item['Id'] ?? 0;

          objfun.JobNoList.add({
            'CNumber': cNumber,
            'Id': id,
          });
        }
      }
    } else {
      objfun.JobNoList = []; // Default to empty list
    }
  }
  catch (error, stackTrace) {
    objfun.msgshow(
      error.toString(),
      stackTrace.toString(),
      Colors.white,
      Colors.red,
      null,
      18.00 - objfun.reducesize,
      objfun.tll,
      objfun.tgc,
      context,
      2,
    );
  }
}




Future SelectTruckList(context,String? Type) async {
  try {
    objfun.GetTruckList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;

    await objfun
        .apiAllinoneSelect(
        "${objfun.apiGetTruckList}$Comid&type=", null, null, context)
        .then((resultData) {
        if (resultData.isNotEmpty) {
        objfun.GetTruckList = resultData
            .map((element) => GetTruckModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future EditTruckList(context,int Keyword,String Column,String? Type) async {
  try {
    objfun.TruckDetailsList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
        "${objfun.apiEditTruckDetails}$Comid&Startindex=0&PageCount=0&Keyword=$Keyword&Column=$Column&type=", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.TruckDetailsList = resultData
            .map((element) => TruckDetailsModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectDriverList(context,String? Type) async {
  try {
    objfun.GetDriverList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;

    await objfun
        .apiAllinoneSelect(
        "${objfun.apiGetDriverList}$Comid&type=", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.GetDriverList = resultData
            .map((element) => GetTruckModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectRTIDetailViewList(context,String Fromdate,String Todate,int DId, int TId, int Employeeid,String Search) async {
  try {
    objfun.RTIViewMasterList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
        "${objfun.apiSelectRTIDetailsView}$Comid&Fromdate=$Fromdate&Todate=$Todate&DId=$DId&TId=$TId&Employeeid=$Employeeid&Search$Search", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.RTIViewMasterList = resultData[0]["salemaster"]
            .map((element) => RTIMasterViewModel.fromJson(element))
            .toList();
        objfun.RTIViewDetailList = resultData[0]["saledetails"]
            .map((element) => RTIDetailsViewModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

Future SelectRTIViewList(context,String Fromdate,String Todate,int DId, int TId, int Employeeid,String Search) async {
  try {
    objfun.RTIViewMasterList.clear();
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    await objfun
        .apiAllinoneSelect(
        "${objfun.apiSelectRTIView}$Comid&Fromdate=$Fromdate&Todate=$Todate&DId=$DId&TId=$TId&Employeeid=$Employeeid&Search$Search", null, null, context)
        .then((resultData) {
      if (resultData.isNotEmpty) {
        objfun.RTIViewMasterList = resultData[0]["salemaster"]
            .map((element) => RTIMasterViewModel.fromJson(element))
            .toList();
        objfun.RTIViewDetailList = resultData[0]["saledetails"]
            .map((element) => RTIDetailsViewModel.fromJson(element))
            .toList();
      }
    }).onError((error, stackTrace) {
      objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);
    });
  } catch (error) {
    if (error.toString() == "") {}
  }
}

