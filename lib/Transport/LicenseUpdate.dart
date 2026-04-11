import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

import '../MasterSearch/Truck.dart';
part 'package:maleva/Transport/mobileLicenseUpdate.dart';
part 'package:maleva/Transport/tabletLicenseUpdate.dart';
class OldLicenseUpdate extends StatefulWidget {

  const OldLicenseUpdate({super.key});

  @override
  OldLicenseUpdateState createState() => OldLicenseUpdateState();
}

class OldLicenseUpdateState extends State<OldLicenseUpdate> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  int TruckId = 0 ;
  final txtTruckNo = TextEditingController();
  final txtTruckNo2 = TextEditingController();
  final txtTruckName = TextEditingController();
  final txtLongitude = TextEditingController();
  final txtLatitude = TextEditingController();
  final txtTruckType = TextEditingController();
  String CNumberDisplay = "";
  int CNumber = 0;
  int Active = 0;


  String dtpRotexMyExp =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpRotexSGExp =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpPuspacomExp =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpRotexMyExp1 =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpRotexSGExp1 =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpPuspacomExp1 =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpInsuratnceExp =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpBonamExp =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpApadExp =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpServiceExp =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpAlignmentExp =
  DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpGreeceExp =
  DateFormat("yyyy-MM-dd").format(DateTime.now());

  bool checkBoxValueRotexMyExp = false;
  bool checkBoxValueRotexSGExp = false;
  bool checkBoxValuePuspacomExp = false;
  bool checkBoxValueRotexMyExp1 = false;
  bool checkBoxValueRotexSGExp1 = false;
  bool checkBoxValuePuspacomExp1 = false;
  bool checkBoxValueInsuratnceExp = false;
  bool checkBoxValueBonamExp = false;
  bool checkBoxValueApadExp = false;
  bool checkBoxValueServiceExp = false;
  bool checkBoxValueAlignmentExp = false;
  bool checkBoxValueGreeceExp = false;
  bool admin=false;

  @override
  void initState() {
    if (objfun.DriverTruckRefId==0) {
      admin = true;
    }
    else {
      TruckId = objfun.DriverTruckRefId;
      loaddata();
    }
    objfun.TruckDetailsList = [];
    startup();
    super.initState();
  }

  @override
  void dispose() {
     txtTruckNo.dispose();
     txtTruckNo2.dispose();
     txtTruckName.dispose();
     txtLongitude.dispose();
     txtLatitude.dispose();
     txtTruckType.dispose();
    super.dispose();
  }

  Future startup() async {
    setState(() {
      progress = true;
    });
  }
  Future loaddata() async {

    await OnlineApi.EditTruckList(context,TruckId,'Id', null);
    if(objfun.TruckDetailsList.isNotEmpty){
       txtTruckNo.text = objfun.TruckDetailsList[0].TruckNumber ;
       txtTruckNo2.text = objfun.TruckDetailsList[0].TruckNumber1 ;
       txtTruckName.text = objfun.TruckDetailsList[0].TruckName;
       txtLongitude.text = objfun.TruckDetailsList[0].longitude;
       txtLatitude.text = objfun.TruckDetailsList[0].Latitude;
       txtTruckType.text = objfun.TruckDetailsList[0].TruckType;
       CNumberDisplay = objfun.TruckDetailsList[0].CNumberDisplay;
       CNumber = objfun.TruckDetailsList[0].CNumber;
       Active = objfun.TruckDetailsList[0].Active;
      DateFormat dateFormat = DateFormat("MM/dd/yyyy HH:mm:ss");
      if(objfun.TruckDetailsList[0].RotexMyExp != "null"){
        checkBoxValueRotexMyExp = true;
        dtpRotexMyExp = dateFormat.parse(objfun.TruckDetailsList[0].RotexMyExp).toString();
      }
      if(objfun.TruckDetailsList[0].RotexSGExp != "null"){
        checkBoxValueRotexSGExp = true;
        dtpRotexSGExp = dateFormat.parse(objfun.TruckDetailsList[0].RotexSGExp).toString();
      }
      if(objfun.TruckDetailsList[0].PuspacomExp != "null"){
        checkBoxValuePuspacomExp = true;
        dtpPuspacomExp = dateFormat.parse(objfun.TruckDetailsList[0].PuspacomExp).toString();
      }
      if(objfun.TruckDetailsList[0].RotexMyExp1 != "null"){
        checkBoxValueRotexMyExp1 = true;
        dtpRotexMyExp1 = dateFormat.parse(objfun.TruckDetailsList[0].RotexMyExp1).toString();
      }
      if(objfun.TruckDetailsList[0].RotexSGExp1 != "null"){
        checkBoxValueRotexSGExp1 = true;
        dtpRotexSGExp1 = dateFormat.parse(objfun.TruckDetailsList[0].RotexSGExp1).toString();
      }
      if(objfun.TruckDetailsList[0].PuspacomExp1 != "null"){
        checkBoxValuePuspacomExp1 = true;
        dtpPuspacomExp1 = dateFormat.parse(objfun.TruckDetailsList[0].PuspacomExp1).toString();
      }
      if(objfun.TruckDetailsList[0].InsuratnceExp != "null"){
        checkBoxValueInsuratnceExp = true;
        dtpInsuratnceExp = dateFormat.parse(objfun.TruckDetailsList[0].InsuratnceExp).toString();
      }
      if(objfun.TruckDetailsList[0].BonamExp != "null"){
        checkBoxValueBonamExp = true;
        dtpBonamExp = dateFormat.parse(objfun.TruckDetailsList[0].BonamExp).toString();
      }
      if(objfun.TruckDetailsList[0].ApadExp != "null"){
        checkBoxValueApadExp = true;
        dtpApadExp = dateFormat.parse(objfun.TruckDetailsList[0].ApadExp).toString();
      }
      if(objfun.TruckDetailsList[0].ServiceExp != "null"){
        checkBoxValueServiceExp = true;
        dtpServiceExp = dateFormat.parse(objfun.TruckDetailsList[0].ServiceExp).toString();
      }
      if(objfun.TruckDetailsList[0].AlignmentExp != "null"){
        checkBoxValueAlignmentExp = true;
        dtpAlignmentExp = dateFormat.parse(objfun.TruckDetailsList[0].AlignmentExp).toString();
      }
      if(objfun.TruckDetailsList[0].GreeceExp != "null"){
        checkBoxValueGreeceExp = true;
        dtpGreeceExp = dateFormat.parse(objfun.TruckDetailsList[0].GreeceExp).toString();
      }

    }
    setState(() {
      progress = true;
    });
  }
  void Clear()  {
    objfun.TruckDetailsList = [];
    objfun.SelectTruckList =
        GetTruckModel
            .Empty();
     TruckId = 0 ;
     txtTruckNo.text = "";
     txtTruckNo2.text = "";
     txtTruckName.text = "";
     txtLongitude.text = "";
     txtLatitude.text = "";
     txtTruckType.text = "";
     CNumberDisplay = "";
     CNumber = 0;
     Active = 0;
     dtpRotexMyExp =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpRotexSGExp =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpPuspacomExp =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpRotexMyExp1 =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpRotexSGExp1 =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpPuspacomExp1 =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpInsuratnceExp =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpBonamExp =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpApadExp =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpServiceExp =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpAlignmentExp =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     dtpGreeceExp =
    DateFormat("yyyy-MM-dd").format(DateTime.now());
     checkBoxValueRotexMyExp = false;
     checkBoxValueRotexSGExp = false;
     checkBoxValuePuspacomExp = false;
     checkBoxValueRotexMyExp1 = false;
     checkBoxValueRotexSGExp1 = false;
     checkBoxValuePuspacomExp1 = false;
     checkBoxValueInsuratnceExp = false;
     checkBoxValueBonamExp = false;
     checkBoxValueApadExp = false;
     checkBoxValueServiceExp = false;
     checkBoxValueAlignmentExp = false;
     checkBoxValueGreeceExp = false;
    setState(() {
      progress = true;
    });
  }
  Future UpdateLicenseDate() async {

    if (txtTruckNo.text.isEmpty) {
      objfun.toastMsg('Enter Truck No', '', context);
      return;
    }
    bool result =
    await objfun.ConfirmationMsgYesNo(context, "Are you sure to Update ?");
    if (result == true) {
      setState(() {
        progress = false;
      });


      List<dynamic> master = [];
      master =
      [{
        'Id':TruckId,
        'CompanyRefId' : objfun.Comid,
        'TruckName' : txtTruckName.text,
        'TruckNumber' : txtTruckNo.text,
        'TruckNumber1' : txtTruckNo2.text,
        'TruckType' : txtTruckType.text,
        'Latitude' : txtLatitude.text,
        'longitude' : txtLongitude.text,
        'RotexMyExp1' : checkBoxValueRotexMyExp1 == true ? DateTime.parse(dtpRotexMyExp1).toIso8601String() : null,
        'RotexSGExp1' : checkBoxValueRotexSGExp1 == true ? DateTime.parse(dtpRotexSGExp1).toIso8601String() : null,
        'PuspacomExp1' : checkBoxValuePuspacomExp1 == true ? DateTime.parse(dtpPuspacomExp1).toIso8601String() : null,
        'RotexMyExp' : checkBoxValueRotexMyExp == true ? DateTime.parse(dtpRotexMyExp).toIso8601String() : null,
        'RotexSGExp' : checkBoxValueRotexSGExp == true ? DateTime.parse(dtpRotexSGExp).toIso8601String() : null,
        'PuspacomExp' : checkBoxValuePuspacomExp == true ? DateTime.parse(dtpPuspacomExp).toIso8601String() : null,
        'InsuratnceExp' : checkBoxValueInsuratnceExp == true ? DateTime.parse(dtpInsuratnceExp).toIso8601String() : null,
        'BonamExp' : checkBoxValueBonamExp == true ? DateTime.parse(dtpBonamExp).toIso8601String() : null,
        'ApadExp' : checkBoxValueApadExp == true ? DateTime.parse(dtpApadExp).toIso8601String() : null,
        'ServiceExp' : checkBoxValueServiceExp == true ? DateTime.parse(dtpServiceExp).toIso8601String() : null,
        'AlignmentExp' : checkBoxValueAlignmentExp == true ? DateTime.parse(dtpAlignmentExp).toIso8601String() : null,
        'GreeceExp' : checkBoxValueGreeceExp == true ? DateTime.parse(dtpGreeceExp).toIso8601String() : null,
        'Active' : Active,

      }];
      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      await objfun
          .apiAllinoneSelectArray(
          "${objfun.apiUpdateTruckDetails}${objfun.Comid}",
          master,
          header,
          context)
          .then((resultData) async {
        if (resultData != "") {
          ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
          if (value.IsSuccess == true) {
            await objfun.ConfirmationOK('Updated Successfully ', context);
            Clear();
          } else {
            objfun.msgshow(
                value.Message,
                '',
                Colors.white,
                Colors.green,
                null,
                18.00 - objfun.reducesize,
                objfun.tll,
                objfun.tgc,
                context,
                2);
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
    }
      setState(() {
      progress = true;
    });
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
