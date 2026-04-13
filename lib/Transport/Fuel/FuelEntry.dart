import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/Transport/Fuel/FuelEntryView.dart';
import 'package:maleva/features/transport/fuelentry/view/view/fuelentryview_tab.dart';

import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

part 'package:maleva/Transport/Fuel/mobileFuelEntry.dart';
part 'package:maleva/Transport/Fuel/tabletFuelEntry.dart';

class OldFuelEntry extends StatefulWidget {

  const OldFuelEntry({super.key});

  @override
  OldFuelEntryState createState() => OldFuelEntryState();
}

class OldFuelEntryState extends State<OldFuelEntry> with TickerProviderStateMixin {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  String dtpdate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  final txtliter = TextEditingController();
  final txtamount = TextEditingController();
  final txtfuelno = TextEditingController();
  var maxno="";
  @override
  void initState() {
    startup();
    super.initState();
  }

  @override
  void dispose() {
    txtliter.dispose();
    txtamount.dispose();
    super.dispose();
  }

  Future startup() async {
    await MaxSaleOrderNo();
    setState(() {
      progress = true;
    });
  }
  Future MaxSaleOrderNo() async {
    try {
      var Comid = objfun.storagenew.getInt('Comid') ?? 0;
      await objfun
          .apiGetString(
          "${objfun.apiMaxFuelEntryNo}$Comid")
          .then((resultData) {
        if (resultData.isNotEmpty) {
            maxno = resultData;
            txtfuelno.text=maxno;
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

  Future clear() async{
    txtliter.text = "";
    txtamount.text = "";
    txtfuelno.text='';
    dtpdate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    await MaxSaleOrderNo();
    setState(() {
      progress = true;
    });
  }


  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    return true;
  }

  Future savefuel() async {
    if (txtliter.text.isEmpty) {
      objfun.toastMsg('Enter Liter', '', context);
      return;
    }
    if (txtamount.text.isEmpty) {
      objfun.toastMsg('Enter Amount', '', context);
      return;
    }


    bool result =
    await objfun.ConfirmationMsgYesNo(
        context, "Do You Want to Save Fuel Entry ?");
    if (result == true) {
      setState(() {
        progress = false;
      });
      var master = [
        {
          'SaleDate': DateTime.parse(dtpdate).toIso8601String(),
          'CNumberDisplay': '0',
          'CNumber': 0,
          'Id': 0,
          'CompanyRefId': objfun.Comid,
          'UserRefId': null,
          'EmployeeRefId':  null ,
          'TruckRefid': objfun.DriverTruckRefId,
          'DriverRefId': objfun.EmpRefId,
          'FilePath': '',
          'Remarks': '',
          'Aliter': txtliter.text,
          'AAmount': txtamount.text,
          'Pliter': 0,
          'PRate': 0,
          'PAmount': 0,
          'Gliter': 0,
          'GAmount': 0,
          'DPliter': 0,
          'DPAmount': 0,
          'DGliter': 0,
          'DGAmount': 0,
          'FStatus': 1,
        }
      ];

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid':objfun.Comid.toString(),
      };

      await objfun.apiAllinoneSelectArray(
          objfun.apiInsertFuelEntry,
          master,
          header,
          context)
          .then((resultData) async {
        if (resultData != "") {
          setState(() {
            progress = true;
          });
          ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
          if (value.IsSuccess == true) {
            await objfun.ConfirmationOK('Saved Successfully ', context);
            await clear();
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
        setState(() {
          progress = true;
        });
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
  }

  GlobalKey appBarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;

    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);
  }
}