import 'dart:ffi';
import 'dart:io';
import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

import '../../MasterSearch/Employee.dart';
import '../../MasterSearch/JobAllStatus.dart';
import '../../Transaction/Stock/StockUpdate.dart';


part 'package:maleva/Boarding/BoardingOfficerUpdate/mobileBoardOfficerUpdate.dart';
part 'package:maleva/Boarding/BoardingOfficerUpdate/tabletBoardOfficerUpdate.dart';

class Boardofficerupdate extends StatefulWidget {
  final List<dynamic>? SaleMaster;
  const Boardofficerupdate({super.key, this.SaleMaster});

  @override
  BoardofficerupdateState createState() => BoardofficerupdateState();
}
//test
class BoardofficerupdateState extends State<Boardofficerupdate> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  //final GlobalKey<AppBar> appBarKey = GlobalKey<AppBar>();
  GlobalKey appBarKey = GlobalKey();

  String dtpSaleOrderdate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  List<String> imagenetwork = [];
  String? dropdownValue;

  String BillType = "0";

  static  List<String> StatusUpdate = <String>[ 'DELIVERY DONE'];
  String Jobno = "";
  int TotalPkg = 0;
  int Jobid = 0;
  int ScnPkg = 0;
  int SaleOrderId = 0;
  int? StatusId ;
  int StockId = 0;

  int BoardOfficerId1 = 0;
  int BoardOfficerId2 = 0;

  int OBoardOfficerId1 = 0;
  int OBoardOfficerId2 = 0;

  final txtStatus = TextEditingController();
  final txtJobNo = TextEditingController();
  final txtBoardingOfficer1 = TextEditingController();
  final txtAmount1 = TextEditingController();
  final txtBoardingOfficer2 = TextEditingController();
  final txtAmount2 = TextEditingController();

  final txtOBoardingOfficer1 = TextEditingController();
  final txtOAmount1 = TextEditingController();
  final txtOBoardingOfficer2 = TextEditingController();
  final txtOAmount2 = TextEditingController();

  List<dynamic> StockNoList = [];
  List<dynamic> CheckStockNoList = [];

  @override
  void initState() {
    OnlineApi.GetJobNoForwarding(context,int.parse(BillType));
    startup();
    super.initState();
  }

  @override
  void dispose() {
txtStatus.dispose();
txtJobNo.dispose();
txtBoardingOfficer1.dispose();
txtAmount1.dispose();
txtBoardingOfficer2.dispose();
txtAmount2.dispose();

txtOBoardingOfficer1.dispose();
txtOAmount1.dispose();
txtOBoardingOfficer2.dispose();
txtOAmount2.dispose();
    super.dispose();
  }

  Future startup() async {
    await OnlineApi.SelectEmployee(context, '', 'Operation');
    loaddata();
    setState(() {
      progress = true;
    });
  }
  Future loaddata() async {

    if (widget.SaleMaster != null && widget.SaleMaster!.isNotEmpty) {
      Jobid = widget.SaleMaster![0]["Id"];
      txtJobNo.text = widget.SaleMaster![0]["CNumberDisplay"] != null ? widget.SaleMaster![0]["CNumberDisplay"].toString() : "";
      if (widget.SaleMaster![0]["LBoardingOfficerRefid"] != 0 &&
          widget.SaleMaster![0]["LBoardingOfficerRefid"] != null) {
        BoardOfficerId1 = widget.SaleMaster![0]["LBoardingOfficerRefid"];
        var BroardBy1 = objfun.EmployeeList.where((item) =>
        item.Id == widget.SaleMaster![0]["LBoardingOfficerRefid"]).toList();
        txtBoardingOfficer1.text = BroardBy1[0].AccountName;
      }
      if (widget.SaleMaster![0]["LBoardingOfficer1Refid"] != 0 &&
          widget.SaleMaster![0]["LBoardingOfficer1Refid"] != null) {
        BoardOfficerId2 = widget.SaleMaster![0]["LBoardingOfficer1Refid"];
        var BroardBy2 = objfun.EmployeeList.where((item) =>
        item.Id == widget.SaleMaster![0]["LBoardingOfficer1Refid"]).toList();
        txtBoardingOfficer2.text = BroardBy2[0].AccountName;
      }
      txtAmount1.text = widget.SaleMaster![0]["LBoardingAmount"] != null ? widget.SaleMaster![0]["LBoardingAmount"].toString() : "";
      txtAmount2.text = widget.SaleMaster![0]["LBoardingAmount1"] != null ? widget.SaleMaster![0]["LBoardingAmount1"].toString() : "";

      if (widget.SaleMaster![0]["OBoardingOfficerRefid"] != 0 &&
          widget.SaleMaster![0]["OBoardingOfficerRefid"] != null) {
        OBoardOfficerId1 = widget.SaleMaster![0]["OBoardingOfficerRefid"];
        var BroardBy1 = objfun.EmployeeList.where((item) =>
        item.Id == widget.SaleMaster![0]["OBoardingOfficerRefid"]).toList();
        txtOBoardingOfficer1.text = BroardBy1[0].AccountName;
      }
      if (widget.SaleMaster![0]["OBoardingOfficer1Refid"] != 0 &&
          widget.SaleMaster![0]["OBoardingOfficer1Refid"] != null) {
        OBoardOfficerId2 = widget.SaleMaster![0]["OBoardingOfficer1Refid"];
        var BroardBy2 = objfun.EmployeeList.where((item) =>
        item.Id == widget.SaleMaster![0]["OBoardingOfficer1Refid"]).toList();
        txtOBoardingOfficer2.text = BroardBy2[0].AccountName;
      }
      txtOAmount1.text = widget.SaleMaster![0]["OBoardingAmount"] != null ? widget.SaleMaster![0]["OBoardingAmount"].toString() : "";
      txtOAmount2.text = widget.SaleMaster![0]["OBoardingAmount1"] != null ? widget.SaleMaster![0]["OBoardingAmount1"].toString() : "";

    }
  }
  Future SaveSalesOrder() async {
    var statusId = 0;
    if (dropdownValue != null) {
      statusId = 5;
    }
    else{
      objfun.toastMsg('Select Status', '', context);
      return;
    }
    if (Jobid == 0) {
      objfun.toastMsg('Invoice Job', '', context);
      return;
    }

    bool result =
    await objfun.ConfirmationMsgYesNo(context, "Do You Want to Update ?");
    if (result == true) {
      setState(() {
        progress = false;
      });
      Map<String, dynamic> master = {};
      master =
        {
          'Id': Jobid,
          'CompanyRefId': objfun.Comid,
          'UserRefId': null,
          'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
          'JStatus': statusId == 0 ? null : statusId,
          'LBoardingOfficerRefid': BoardOfficerId1,
          'LBoardingOfficer1Refid': BoardOfficerId2,
          'LBoardingAmount': txtAmount1.text,
          'LBoardingAmount1': txtAmount1.text,
          'OBoardingOfficerRefid': OBoardOfficerId1,
          'OBoardingOfficer1Refid': OBoardOfficerId2,
          'OBoardingAmount': txtOAmount1.text,
          'OBoardingAmount1': txtOAmount1.text,
        };

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      await objfun
          .apiAllinoneSelectArray(
          "${objfun.apiUpdateBoardingOfficer}",
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
            await objfun.ConfirmationOK('Updated Successfully ', context);

            Navigator.pop(context);
            //clear();
          } else {
            objfun.msgshow(value.Message, '', Colors.white, Colors.green, null,
                18.00 - objfun.reducesize, objfun.tll, objfun.tgc, context, 2);
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
  Future Calc() async {


      var LBoardingAmount = 0;
      var LBoardingAmount1 = 0;
      var OBoardingAmount = 0;
      var OBoardingAmount1 = 0;

      if (txtBoardingOfficer1.text.isNotEmpty) {
        LBoardingAmount = 50;
      }

      if (txtOBoardingOfficer1.text.isNotEmpty) {
        OBoardingAmount = 50;
      }

      if (txtBoardingOfficer2.text.isNotEmpty) {
        if (LBoardingAmount == 0) {
          LBoardingAmount1 = 50;
        }
        else {
          LBoardingAmount = 30;
          LBoardingAmount1 = 30;
        }
      }
      if (txtOBoardingOfficer2.text.isNotEmpty) {
        if (OBoardingAmount == 0) {
          OBoardingAmount1 = 50;
        }
        else {
          OBoardingAmount = 30;
          OBoardingAmount1 = 30;
        }
      }

      txtAmount1.text = LBoardingAmount.toString();
      txtAmount2.text =LBoardingAmount1.toString();
      txtOAmount1.text= OBoardingAmount.toString();
      txtOAmount2.text= OBoardingAmount1.toString();

  }
  void clear() {
     Jobno = "";
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
