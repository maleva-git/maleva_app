
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maleva/core/network/api_services/auth_api.dart';
import 'package:maleva/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:maleva/features/auth/presentation/pages/login_page.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/features/mastersearch/Employee.dart';
import 'package:maleva/features/home/view/home_tab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/dialog_helper.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';
import 'package:maleva/core/models/shared/employee_model.dart';

class ApiLegacyHelper {
  static Future<void> localstoragecall() async {
    AppGlobals.storagenew = await SharedPreferences.getInstance();
  }

  static Future<http.Response> _performPostRequest(String url, dynamic bodyData, Map<String, String> headers) async {
  String body;
    if (bodyData == null || bodyData == '') {
      body = "{}";
    } else {
      body = json.encode(bodyData);
    }
  
    debugPrint(url);
    if (body != '' && body != 'null' && body != '{}') {
      debugPrint(body);
    }
    return await http.post(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: 30));
  }

  static Future<List<dynamic>> apiAllinoneSelect(api, insertDetails,
      Map<String, String>? header, BuildContext ?context) async {
  String apiname = api.toString().split('?')[0];
    apiname = "${apiname.replaceAll('$AppGlobals.port/api/', '')}: ";
    try {
  final headers = AppGlobals.buildRequestHeaders(header);
  final result = await _performPostRequest(api, insertDetails, headers);
      if (result.statusCode == 200) {
        if (result.body == "") {
          return [];
        } else {
          return jsonDecode(result.body);
        }
      } else if (result.statusCode == 401) {
        if (context != null && !context.mounted) return [];
        ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
        try {
          ResponseViewModel? value =
              ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        } catch (_) {}
        return [];
      } else if (result.statusCode == 406) {
        if (context != null && !context.mounted) return [];
        ConfirmationOK(
            "Already Login Another User.ReLogin or Change Password !!!", context);
        AppGlobals.loginId = 0;
        AppGlobals.loginname = '';
        AppGlobals.storagenew.setString('Username', "");
        AppGlobals.storagenew.setString('Password', "");
        AppGlobals.storagenew.setString('OldUsername', "");
        return [];
      } else if (result.statusCode == 404 || result.statusCode == 500) {
        if (context != null && !context.mounted) return [];
        try {
          ResponseViewModel? value =
              ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        } catch (e) {
          msgshow("Server Error: ${result.statusCode}", "", Colors.white, Colors.red, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        }
        return [];
      } else {
  throw Exception('${result.statusCode} Unknown Error Occurred');
      }
    } on SocketException catch (_) {
  throw Exception('Check Your Network Connection');
    } catch (error) {
  throw Exception('$apiname$error');
    }
  }

  static Future<dynamic> apiAllinoneMapSelect(
      api,
      insertDetails,
      Map<String, String>? header,
      BuildContext context) async {
  String apiname = api.toString().split('?')[0];
    apiname = "${apiname.replaceAll('$AppGlobals.port/api/', '')}: ";
    try {
  final headers = AppGlobals.buildRequestHeaders(header);
  final result = await _performPostRequest(api, insertDetails, headers);

      if (result.statusCode == 200) {
        if (result.body == "") {
          return [];
        } else {
  final decoded = jsonDecode(result.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          } else if (decoded is List) {
            return decoded;
          } else {
            return decoded;
          }
        }
      } else if (result.statusCode == 401) {
        if (!context.mounted) return [];
        ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
        try {
          ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        } catch (_) {}
        return [];
      } else if (result.statusCode == 406) {
        if (!context.mounted) return [];
        ConfirmationOK(
            "Already Login Another User.ReLogin or Change Password !!!", context);
        AppGlobals.loginId = 0;
        AppGlobals.loginname = '';
        AppGlobals.storagenew.setString('Username', "");
        AppGlobals.storagenew.setString('Password', "");
        AppGlobals.storagenew.setString('OldUsername', "");
        return [];
      } else if (result.statusCode == 404 || result.statusCode == 500) {
        if (!context.mounted) return [];
        try {
          ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        } catch (e) {
          msgshow("Server Error: ${result.statusCode}", "", Colors.white, Colors.red, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        }
        return [];
      } else {
  throw Exception('${result.statusCode} Unknown Error Occurred');
      }
    } on SocketException catch (_) {
  throw Exception('Check Your Network Connection');
    } catch (error) {
  throw Exception('$apiname$error');
    }
  }

  static Future<List<dynamic>> apiAllinoneSelectWithOutAuth(api, insertDetails,
      Map<String, String>? header, BuildContext context) async {
  String apiname = api.toString().split('?')[0];
    apiname = "${apiname.replaceAll('$AppGlobals.port/api/', '')}: ";
    try {
  final headers = AppGlobals.buildRequestHeaders(header, skipAuth: true);
  final result = await _performPostRequest(api, insertDetails, headers);
      if (result.statusCode == 200) {
        if (result.body == "") {
          return [];
        } else {
          return jsonDecode(result.body);
        }
      } else if (result.statusCode == 401) {
        if (!context.mounted) return [];
        ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
        try {
          ResponseViewModel? value =
              ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        } catch (_) {}
        return [];
      } else if (result.statusCode == 406) {
        if (!context.mounted) return [];
        ConfirmationOK(
            "Already Login Another User.ReLogin or Change Password !!!", context);
        AppGlobals.loginId = 0;
        AppGlobals.loginname = '';
        AppGlobals.storagenew.setString('Username', "");
        AppGlobals.storagenew.setString('Password', "");
        AppGlobals.storagenew.setString('OldUsername', "");
        return [];
      } else if (result.statusCode == 404 || result.statusCode == 500) {
        if (!context.mounted) return [];
        try {
          ResponseViewModel? value =
              ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        } catch (e) {
          msgshow("Server Error: ${result.statusCode}", "", Colors.white, Colors.red, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        }
        return [];
      } else {
  throw Exception('${result.statusCode} Unknown Error Occurred');
      }
    } on SocketException catch (_) {
  throw Exception('Check Your Network Connection');
    } catch (error) {
  throw Exception('$apiname$error');
    }
  }

  static Future<dynamic> apiAllinoneSelectArrayWithOutAuth(api, insertDetails,
      Map<String, String>? header, BuildContext ?context) async {
  String apiname = api.toString().split('?')[0];
    apiname = "${apiname.replaceAll('$AppGlobals.port/api/', '')}: ";
    try {
  final headers = AppGlobals.buildRequestHeaders(header, skipAuth: true);
  final result = await _performPostRequest(api, insertDetails, headers);
      if (result.statusCode == 200) {
        if (result.body == "") {
          return [];
        } else {
          return jsonDecode(result.body);
        }
      } else if (result.statusCode == 401) {
        if (context != null && !context.mounted) return [];
        ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
        try {
          ResponseViewModel? value =
              ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        } catch (_) {}
        return [];
      } else if (result.statusCode == 406) {
        if (context != null && !context.mounted) return [];
        ConfirmationOK(
            "Already Login Another User.ReLogin or Change Password !!!", context);
        AppGlobals.loginId = 0;
        AppGlobals.loginname = '';
        AppGlobals.storagenew.setString('Username', "");
        AppGlobals.storagenew.setString('Password', "");
        AppGlobals.storagenew.setString('OldUsername', "");
        return [];
      } else if (result.statusCode == 404 || result.statusCode == 500) {
        if (context != null && !context.mounted) return [];
        try {
          ResponseViewModel? value =
              ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        } catch (e) {
          msgshow("Server Error: ${result.statusCode}", "", Colors.white, Colors.red, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        }
        return [];
      } else {
  throw Exception('${result.statusCode} Unknown Error Occurred');
      }
    } on SocketException catch (_) {
  throw Exception('Check Your Network Connection');
    } catch (error) {
  throw Exception('$apiname$error');
    }
  }

  static Future<dynamic> apiAllinoneSelectArray(api, insertDetails,
      Map<String, String>? header, BuildContext? context) async {
  String apiname = api.toString().split('?')[0];
    apiname = "${apiname.replaceAll('$AppGlobals.port/api/', '')}: ";
    try {
  final headers = AppGlobals.buildRequestHeaders(header);
  final result = await _performPostRequest(api, insertDetails, headers);

      if (result.statusCode == 200) {
        if (result.body == "") {
          return [];
        } else {
          return jsonDecode(result.body);
        }
      } else if (result.statusCode == 401) {
        if (context != null) {
          ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
          ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        }
        return [];
      } else if (result.statusCode == 406) {
        AppGlobals.loginId = 0;
        AppGlobals.loginname = '';
        AppGlobals.storagenew.setString('Username', "");
        AppGlobals.storagenew.setString('Password', "");
        AppGlobals.storagenew.setString('OldUsername', "");
        if (context != null) {
          ConfirmationOK(
              "Already Login Another User.ReLogin or Change Password !!!", context);
        }
        return [];
      } else if (result.statusCode == 404 || result.statusCode == 500) {
        if (context != null) {
          ResponseViewModel? value =
          ResponseViewModel.fromJson(jsonDecode(result.body));
          msgshow(value.Message, "", Colors.white, Colors.green, null,
              18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        }
        return [];
      } else {
  throw Exception('${result.statusCode} Unknown Error Occurred');
      }
    } on SocketException catch (_) {
  throw Exception('Check Your Network Connection');
    } catch (error) {
  throw Exception('$apiname$error');
    }
  }

  static Future<dynamic> apiAllinone(api, insertDetails, Map<String, String>? header, BuildContext context) async {
  String apiname = api.toString().split('?')[0];
    apiname = "${apiname.replaceAll('$AppGlobals.port/api/', '')}: ";
    try {
  final headers = AppGlobals.buildRequestHeaders(header);
  final result = await _performPostRequest(api, insertDetails, headers);
      if (result.statusCode == 200) {
        return true;
      } else if (result.statusCode == 401) {
        ConfirmationOK("Authentication Failed !!!..ReLogin !!!", context);
        ResponseViewModel? value =
            ResponseViewModel.fromJson(jsonDecode(result.body));
        msgshow(value.Message, "", Colors.white, Colors.green, null,
            18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        return [];
      } else if (result.statusCode == 406) {
        ConfirmationOK(
            "Already Login Another User.ReLogin or Change Password !!!", context);
        AppGlobals.loginId = 0;
        AppGlobals.loginname = '';
        AppGlobals.storagenew.setString('Username', "");
        AppGlobals.storagenew.setString('Password', "");
        AppGlobals.storagenew.setString('OldUsername', "");
        return [];
      } else if (result.statusCode == 404) {
        ResponseViewModel? value =
            ResponseViewModel.fromJson(jsonDecode(result.body));
        msgshow(value.Message, "", Colors.white, Colors.green, null,
            18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        return false;
      } else if (result.statusCode == 406) {
        ConfirmationOK("Already login another devices.Please ReLogin.", context);
        return false;
      } else if (result.statusCode == 409) {
        ResponseViewModel? value =
            ResponseViewModel.fromJson(jsonDecode(result.body));
        msgshow(value.Message, "", Colors.white, Colors.green, null,
            18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        return false;
      } else if (result.statusCode == 500) {
        ResponseViewModel? value =
            ResponseViewModel.fromJson(jsonDecode(result.body));
        msgshow(value.Message, "", Colors.white, Colors.green, null,
            18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        return false;
      } else {
  throw Exception('${result.statusCode} Unknown Error Occurred');
      }
    } on SocketException catch (_) {
      msgshow('Check Your Network Connection', "", Colors.white, Colors.red, null,
          18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
  throw Exception('Check Your Network Connection');
    } catch (error) {
      msgshow('Check Your Network Connection', "", Colors.white, Colors.red, null,
          18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
  throw Exception('$apiname$error');
    }
  }

  static Future<String> apiGetString(api) async {
    try {
      debugPrint(api);
      AppGlobals.numberofapicalls = AppGlobals.numberofapicalls + 1;
  var result = await http.post(Uri.parse(api)).timeout(const Duration(seconds: 30));
      if (result.statusCode == 200) {
        AppGlobals.numberofapicalls = AppGlobals.numberofapicalls - 1;
        return jsonDecode(result.body).toString();
      } else {
        AppGlobals.numberofapicalls = AppGlobals.numberofapicalls - 1;
  throw Exception('Failed to Get String');
      }
    } on SocketException catch (_) {
      AppGlobals.networkConnection = false;
      AppGlobals.currenttryconnection = AppGlobals.currenttryconnection + 1;
  throw Exception('There is No Network !!');
    }
  }

  static Future<void> EmployeeLogin(context, int type) async {
    if (type != 1) {
  bool result =
  await ConfirmationMsgYesNo(context, "Are you sure to logout ?? ");
      if (result == false) {
        return;
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Homemobile()));
    }
    AppGlobals.EmpRefId = 0;
    AppGlobals.storagenew.setInt('AppGlobals.EmpRefId', 0);
    AppGlobals.storagenew.setString('Username', "");
    AppGlobals.storagenew.setString('Password', "");
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            height: 35,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0.0),
              color: colour.commonColor,
              border: Border.all(
                color: colour.commonColorLight,
              ),
              // side: const BorderSide(color: colour.commonColorLight, width: 1, style: BorderStyle.solid),
            ),
            child: Text(
              "Employee Login",
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: colour.whiteText,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: 0.3),
              ),
            ),
          ),
          content: SizedBox(
            height: 165,
            child: Column(children: [
              Container(
                width: SizeConfig.safeBlockHorizontal * 99,
                height: SizeConfig.safeBlockVertical * 7,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(bottom: 5),
                child: TextField(
                  textCapitalization: TextCapitalization.characters,
                  controller: AppGlobals.txtLoginEmployee,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.name,
                  readOnly: true,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.commonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: AppGlobals.FontLow,
                        letterSpacing: 0.3),
                  ),
                  decoration: InputDecoration(
                    hintText: "Employee Name",
                    hintStyle:GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: AppGlobals.FontMedium,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColorLight)),
                    suffixIcon: InkWell(
                        child: Icon(
                            (AppGlobals.txtLoginEmployee.text.isNotEmpty)
                                ? Icons.close
                                : Icons.search_rounded,
                            color: colour.commonColorred,
                            size: 30.0),
                        onTap: () async {
                          if (AppGlobals.txtLoginEmployee.text == "") {
                            await OnlineApi.SelectEmployee(
                                context, 'Sales', 'admin');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
  const Employee(Searchby: 1, SearchId: 0)),
                            ).then((dynamic value) async {
                              //setState(() {
                              AppGlobals.txtLoginEmployee.text =
                                  AppGlobals.SelectEmployeeList.AccountName;
                              AppGlobals.LoginEmpId = AppGlobals.SelectEmployeeList.Id;
                              AppGlobals.SelectEmployeeList = EmployeeModel.Empty();
                              // });
                            });
                          } else {
                            //setState(() {
                            AppGlobals.txtLoginEmployee.text = "";
                            AppGlobals.LoginEmpId = 0;
                            AppGlobals.SelectEmployeeList = EmployeeModel.Empty();
                            // });
                          }
                        }),
                    fillColor: Colors.black,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: colour.commonColor),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: colour.commonColorred),
                    ),
                    contentPadding:
                        const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                  ),
                ),
              ),
              Container(
                width: SizeConfig.safeBlockHorizontal * 99,
                height: SizeConfig.safeBlockVertical * 7,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(bottom: 5),
                child: TextField(
                  cursorColor: colour.commonColor,
                  controller: AppGlobals.txtLoginPassword,
                  autofocus: false,
                  showCursor: true,
                  decoration: InputDecoration(
                    hintText: ('Password'),
                    hintStyle:GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: AppGlobals.FontMedium,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColorLight)),
                    fillColor: colour.commonColor,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: colour.commonColor),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: colour.commonColorred),
                    ),
                    contentPadding:
                        const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                  ),
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.commonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: AppGlobals.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colour.commonColor,
                  side: const BorderSide(
                      color: colour.commonColorLight,
                      width: 1,
                      style: BorderStyle.solid),
                  textStyle: const TextStyle(color: Colors.black),
                  elevation: 20.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.all(4.0),
                ),
                onPressed: () {
                  if (AppGlobals.txtLoginPassword != "" && AppGlobals.LoginEmpId != 0) {
  var EmployeeDetailsList = AppGlobals.EmployeeList.where((item) =>
                        item.Id == AppGlobals.LoginEmpId &&
                        item.Password == AppGlobals.txtLoginPassword.text).toList();
                    if (EmployeeDetailsList.isNotEmpty) {
                      AppGlobals.EmpRefId = EmployeeDetailsList[0].Id;
                      AppGlobals.storagenew.setString(
                          'Username', EmployeeDetailsList[0].AccountName);
                      AppGlobals.storagenew.setString(
                          'Password', EmployeeDetailsList[0].Password);
                      AppGlobals.storagenew.setInt(
                          'AppGlobals.EmpRefId', EmployeeDetailsList[0].Id );
                      AppGlobals.txtLoginEmployee.text = "";
                      AppGlobals.txtLoginPassword.text = "";
                      AppGlobals.LoginEmpId = 0;
                      AppGlobals.SelectEmployeeList = EmployeeModel.Empty();
                    } else {
                      ConfirmationOK("Invalid Employee and Password", context);
                    }

                    Navigator.pop(context, true);
                  } else {
                    ConfirmationOK(
                        "Enter Employee Name and Password !!", context);
                  }
                },
                child: Text(
                  'Login',
                  style: GoogleFonts.lato(
                      fontSize: 22.0,
                      // height: 1.45,
                      fontWeight: FontWeight.bold,
                      color: colour.commonColorLight),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  static Future<void> logout(BuildContext context) async {
  bool result = await ConfirmationMsgYesNo(context, "Are you sure you want to logout?");

    if (!result) {
      return;
    }

    // Clear Session Variables
    AppGlobals.loginId = 0;
    AppGlobals.loginname = '';
    AppGlobals.DriverLogin = 0;
    AppGlobals.DriverTruckRefId = 0;

    AppGlobals.storagenew.setString('Username', "");
    AppGlobals.storagenew.setString('Password', "");
    AppGlobals.storagenew.setString('OldUsername', "");


    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LoginBloc(
            authRepository: AuthRepository(
              authApi: AuthApi.instance,
            ),
          ),
          child: const Appuserloginmobile(),
        ),
      ),
          (Route<dynamic> route) => false,
    );
  }

}
