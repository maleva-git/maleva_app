import 'dart:io';
import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maleva/MasterSearch/WareHouseList.dart';

import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

import '../../MasterSearch/JobAllStatus.dart';
import '../SaleOrderDetails.dart';

part 'package:maleva/Transaction/Stock/mobileStockTransferUpdate.dart';
part 'package:maleva/Transaction/Stock/tabletStockTransferUpdate.dart';

class StockTransferUpdate extends StatefulWidget {

  const StockTransferUpdate({super.key});

  @override
  StockTransferUpdateState createState() => StockTransferUpdateState();
}
//test
class StockTransferUpdateState extends State<StockTransferUpdate> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  //final GlobalKey<AppBar> appBarKey = GlobalKey<AppBar>();
  GlobalKey appBarKey = GlobalKey();

  List<String> imagenetwork = [];
  String? dropdownValue;

  String BillType = "0";

  static  List<String> StatusUpdate = <String>['AT WAREHOUSE', 'STOCK OUT'];
  String Jobno = "";
  String PortName = "";
  int TotalPkg = 0;
  int ScnPkg = 0;
  int SaleOrderId = 0;
  int? StatusId ;
  int StockId = 0;
  int WareHouseId = 0;

  final txtWareHouse = TextEditingController();
  final txtBarcodeNo = TextEditingController();

  List<dynamic> StockNoList = [];
  List<dynamic> CheckStockNoList = [];

  @override
  void initState() {

    startup();
    super.initState();
  }

  @override
  void dispose() {
txtWareHouse.dispose();
txtBarcodeNo.dispose();
    super.dispose();
  }

  Future startup() async {
    await OnlineApi.SelectWareHouse(context);
    setState(() {
      progress = true;
    });
  }
  Future loaddata() async {

  }
  Future UpdateStockStatus(int id,int Status) async {
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    Map<String?, dynamic> master = {};

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiUpdateStockTransfer}$id&PortId=$Status&Comid=$Comid",
        master,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          await objfun.ConfirmationOK('Updated Successfully', context);
          clear();
          setState(() {
            progress = true;
          });
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
  void clear() {
     Jobno = "";
     PortName = "";
     txtWareHouse.text = "";
     WareHouseId = 0;
     TotalPkg = 0;
     ScnPkg = 0;
     SaleOrderId = 0;
     StatusId = 0;
     StockId = 0;
     dropdownValue = null;
     StockNoList = [];
     CheckStockNoList = [];
    setState(() {
      progress =true;
    });

  }
  Future loadStockData(String Barcodelabel) async {
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      await objfun
          .apiAllinoneSelectArray(
          "${objfun.apiEditStockIn}0&barcodeLabel=$Barcodelabel&Comid=$Comid",
          null,
          header,
          context)
          .then((resultData) async {
        if (resultData != "") {
          setState(() {
            progress = true;
          });
          ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
          if (value.IsSuccess == true) {
            for(var i = 1 ; i <= value.data1[0]["NumberOfPackages"];i++){
              CheckStockNoList.add(value.data1[0]["BarcodeLabelDisplay"] + "-" + i.toString() + "/"+value.data1[0]["NumberOfPackages"].toString());
            }
            TotalPkg = value.data1[0]["NumberOfPackages"];
            Jobno = value.data1[0]["BarcodeLabelDisplay"];
            StockId = value.data1[0]["Id"];
            StatusId = value.data1[0]["Status"];
            final warehouse = objfun.WareHouseList.firstWhere(
                  (item) => item.Id == value.data1[0]["PortMasterRefId"],
            );
            PortName =warehouse.PortName ?? "";

            if( StatusId == 0){
              StatusUpdate = <String>['AT WAREHOUSE'];
            }
            else if( StatusId == 1){
              StatusUpdate = <String>['STOCK OUT'];
            }
            setState(() {
              progress = true;
            });
          }
          else {
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

          }}
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

  Future<bool> _onBackPressed() async {


    Navigator.of(context).pop();
    return true;
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
