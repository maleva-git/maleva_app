import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

part 'package:maleva/Transport/Fuel/mobileFuelEntryView.dart';
part 'package:maleva/Transport/Fuel/tabletFuelEntryView.dart';


class FuelEntryView extends StatefulWidget {

  const FuelEntryView({super.key});

  @override
  FuelEntryViewState createState() => FuelEntryViewState();
}

class FuelEntryViewState extends State<FuelEntryView> with TickerProviderStateMixin {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  List<dynamic> showdetails = [];

  @override
  void initState() {
    startup();
    super.initState();
  }


  Future startup() async {
    await loaddata();
    setState(() {
      progress = true;
    });
  }

  Future clear() async {
    setState(() {
      progress = true;
    });
  }

  Future loaddata() async {
    setState(() {
      showdetails=[];
      progress = false;
    });
    Map<String, dynamic> master = {};
    master = {
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': dtpFromDate,
      'Todate': dtpToDate,
      'Employeeid': 0,
      'DId': objfun.DriverTruckRefId,
      'TId': objfun.EmpRefId,
      'Search': '',
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.apiSelectFuelEntry, master, header, context)
        .then((resultData) async {
      if (resultData != "") {
        setState(() {
          progress = true;
        });
        if (resultData.length != 0) {
          showdetails = resultData;
          // showdetails = (resultData as dynamic)
          //     .map((element) => FuelEntryModel.fromJson(element))
          //     .toList();

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
  Future deletedata(objlist) async {
    bool result =
    await objfun.ConfirmationMsgYesNo(
        context, "Do You Want to Delete Fuel Entry ?");
    if (result == true) {
      setState(() {
        progress = false;
      });
      Map<String, dynamic> master = {};
      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      await objfun
          .apiAllinoneSelectArray(
          "${objfun
              .apiDeleteFuelEntry}${objlist['Id']}&Comid=${objlist['CompanyRefId']}&Mobile=1",
          master, header, context)
          .then((resultData) async {
        if (resultData != "") {
          loaddata();
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
  }
  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    return true;
  }


  GlobalKey appBarKey = GlobalKey();

  Row loadgridheader() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(
            "SNo",
            textAlign: TextAlign.left,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: colour.ButtonForeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: objfun.FontCardText,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            "Date",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: colour.ButtonForeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: objfun.FontCardText,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            "Liter",
            textAlign: TextAlign.right,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: colour.ButtonForeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: objfun.FontCardText,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            "Amount",
            textAlign: TextAlign.right,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: colour.ButtonForeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: objfun.FontCardText,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: IconButton(
            onPressed:
                () {
                  deletedata(null);
            },
            icon:
            const Icon(Icons.delete_outline_rounded ,color: colour.commonColorLight,),
            color:
            colour.commonColorhighlight,
          ),
        ),
      ],
    );
  }

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