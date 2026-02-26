import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

import '../MasterSearch/Truck.dart';

part 'package:maleva/Transport/mobileMaintenance.dart';
part 'package:maleva/Transport/tabletMaintenance.dart';

class Maintenance extends StatefulWidget {

  const Maintenance({super.key});

  @override
  MaintenanceState createState() => MaintenanceState();
}

class MaintenanceState extends State<Maintenance> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  int TruckId = objfun.DriverTruckRefId ;
  final txtTruckNo = TextEditingController();
  var ExpDate = "";
  var ExpApadBonam = "";
  var ExpServiceAligmentGreece="";
  bool VisibleTruck = objfun.DriverLogin == 1 ? false : true;
  @override
  void initState() {
    objfun.TruckDetailsList = [];
    startup();
    super.initState();
  }

  @override
  void dispose() {
    txtTruckNo.dispose();
    super.dispose();
  }

  Future startup() async {
    setState(() {
      progress = true;
    });
    if(TruckId!=0) {
      loaddata();
    }
  }
  Future loaddata() async {

    ExpDate = objfun.currentdate(objfun.commonexpirydays);
    ExpApadBonam = objfun.currentdate(objfun.apadbonamexpirydays);
    ExpServiceAligmentGreece = objfun.currentdate(objfun.ExpServiceAligmentGreecedays);
    Map<String, dynamic> master = {};
    master = {
     // 'Expdate':ExpDate,
      'Expdate':null,
      'ExpApadBonam':ExpApadBonam,
      'ExpServiceAligmentGreece': ExpServiceAligmentGreece,
      'Id':TruckId,
      'SFromDate':null,
      'Comid':objfun.Comid,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.apiSelectTruckDetails, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        if (resultData.length != 0) {
          objfun.TruckDetailsList = resultData
              .map((element) => TruckDetailsModel.fromJson(element))
              .toList().cast<TruckDetailsModel>();
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
    setState(() {
      progress = true;
    });
  }

  Color _ExpColor(String LicenseDate ) {
    DateFormat dateFormat = DateFormat("yyyy/MM/dd");
    DateFormat dateFormat2 = DateFormat("yyyy-MM-dd");
    if(ExpDate == "" || LicenseDate == "null"){
      return colour.commonColor;
    }
    DateTime FormatlicenseDate = dateFormat.parse(LicenseDate);
    DateTime FormatExpDate = dateFormat2.parse(ExpDate);
    if (FormatlicenseDate.isBefore(FormatExpDate) || FormatlicenseDate.isAtSameMomentAs(FormatExpDate) ) {
    return colour.commonColorred;
    }  else {
      return colour.commonColor;
    }
  }
  Color _ExpServiceAligmentGreece(String LicenseDate ) {
    DateFormat dateFormat = DateFormat("yyyy/MM/dd");
    DateFormat dateFormat2 = DateFormat("yyyy-MM-dd");
    if( ExpServiceAligmentGreece == "" || LicenseDate == "null"){
      return colour.commonColor;
    }
    DateTime FormatlicenseDate = dateFormat.parse(LicenseDate);
    DateTime FormatExpDate = dateFormat2.parse( ExpServiceAligmentGreece);
    if (FormatlicenseDate.isBefore(FormatExpDate) || FormatlicenseDate.isAtSameMomentAs(FormatExpDate) ) {
      return colour.commonColorred;
    }  else {
      return colour.commonColor;
    }
  }

  Color _ExpApadBonamColor(String LicenseDate ) {
    DateFormat dateFormat = DateFormat("yyyy/MM/dd");
    DateFormat dateFormat2 = DateFormat("yyyy-MM-dd");
    if(ExpApadBonam == "" || LicenseDate == "null"){
      return colour.commonColor;
    }
    DateTime FormatlicenseDate = dateFormat.parse(LicenseDate);
    DateTime FormatExpDate = dateFormat2.parse(ExpApadBonam);
    if (FormatlicenseDate.isBefore(FormatExpDate) || FormatlicenseDate.isAtSameMomentAs(FormatExpDate) ) {
      return colour.commonColorred;
    }  else {
      return colour.commonColor;
    }
  }

  Future<bool> _onBackPressed() async {

    Navigator.of(context).pop();
    return true;
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return width < 768
        ? mobiledesign(this, context)
        : tabletdesign(this, context);
  }
}
