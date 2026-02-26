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

import '../../MasterSearch/JobAllStatus.dart';
import '../../MasterSearch/WareHouseList.dart';
import '../SaleOrderDetails.dart';

part 'package:maleva/Transaction/Stock/mobileStockUpdate.dart';
part 'package:maleva/Transaction/Stock/tabletStockUpdate.dart';

class StockUpdate extends StatefulWidget {

  const StockUpdate({super.key});

  @override
  StockUpdateState createState() => StockUpdateState();
}
//test
class StockUpdateState extends State<StockUpdate> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  //final GlobalKey<AppBar> appBarKey = GlobalKey<AppBar>();
  GlobalKey appBarKey = GlobalKey();

  int BoardOfficerId1 = 0;
  int BoardOfficerId2 = 0;
  double BoardOfficerAmt1 = 0.0;
  double BoardOfficerAmt2 = 0.0;

  String? dropdownValue;

  String BillType = "0";

  static  List<String> StatusUpdate = <String>['AT WAREHOUSE', 'STOCK OUT'];
  String Jobno = "";
  int TotalPkg = 0;
  int ScnPkg = 0;
  int SaleOrderId = 0;
  int? Status ;
  int StockId = 0;
  int WareHouseId = 0;
  int JobId = 0;
  int StatusId = 0;

  final txtStatus = TextEditingController();
  final txtBarcodeNo = TextEditingController();
  final txtWareHouse = TextEditingController();
  final txtJobStatus = TextEditingController();

  List<dynamic> StockNoList = [];
  List<dynamic> CheckStockNoList = [];

  bool checkBoxImageUpload = false;
  List<String> imagenetwork = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    OnlineApi.GetJobNoForwarding(context,int.parse(BillType));
    startup();
    super.initState();
  }

  @override
  void dispose() {
    txtStatus.dispose();
    txtBarcodeNo.dispose();
    txtWareHouse.dispose();
    txtJobStatus.dispose();
    super.dispose();
  }

  Future startup() async {
    setState(() {
      progress = true;
    });
  }
  Future loaddata() async {

  }
  Future UpdateStockStatus(int id,int Statusid,int PortRefid) async {
    List<String>  ImageUrl= [];
    for(var i =0 ; i<imagenetwork.length ;i++){
      ImageUrl.add("${objfun.imagepath}SalesOrder/$SaleOrderId/${txtJobStatus.text.replaceAll(' ', '')}/${imagenetwork[i]}");
    }
    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    Map<String?, dynamic> master = {};

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiUpdateStockIn}$id&StatusId=$Statusid&Comid=$Comid&PortRefid=$PortRefid&ImageURL",
        ImageUrl,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          await UpdateBoardingOfficier(Statusid);
          await objfun.ConfirmationOK('Updated Successfully', context);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StockUpdate()),
          );
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
      txtWareHouse.text ="";
      txtJobStatus.text = "";
     TotalPkg = 0;
     ScnPkg = 0;
     SaleOrderId = 0;
     Status = 0;
     StockId = 0;
      WareHouseId = 0;
      JobId = 0;
      StatusId = 0;
     dropdownValue = null;
     StockNoList = [];
     CheckStockNoList = [];
    setState(() {
      progress =true;
    });

  }
  Future LoadJobDetails(int id) async {

    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    Map<String?, dynamic> master = {};

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiSaleOrderDetailsLoad}$Comid&Id=$id",
        master,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          var data = value.data1[0];
          SaleOrderId= data["Id"];
          JobId = data["JobMasterRefId"];
          await OnlineApi
              .SelectAllJobStatus(
              context,
              JobId);
          if(objfun.DriverLogin == 1){
            if (data["JStatus"] == 3) {
              StatusId = 11;
              var JobStatus = objfun.JobAllStatusList.where(
                      (item) => item.Status == StatusId).toList();
              txtJobStatus.text = JobStatus[0].StatusName;
            }
            else if (data["JStatus"] == 11) {
              StatusId = 19;
              var JobStatus = objfun.JobAllStatusList.where(
                      (item) => item.Status == StatusId).toList();
              txtJobStatus.text = JobStatus[0].StatusName;
            }
            else {
              clear();
              objfun.toastMsg("Invalid", "", context);
              return;
            }
          }
          else {
            if (data["JStatus"] == 19) {
              StatusId = 4;
              var JobStatus = objfun.JobAllStatusList.where(
                      (item) => item.Status == StatusId).toList();
              txtJobStatus.text = JobStatus[0].StatusName;
            }
            else if (data["JStatus"] == 4) {
              StatusId = 7;
              var JobStatus = objfun.JobAllStatusList.where(
                      (item) => item.Status == StatusId).toList();
              txtJobStatus.text = JobStatus[0].StatusName;
              loadBoardingOfficier(StatusId);

            }
            else if (data["JStatus"] == 7) {
              StatusId = 5;
              var JobStatus = objfun.JobAllStatusList.where(
                      (item) => item.Status == StatusId).toList();
              txtJobStatus.text = JobStatus[0].StatusName;
              loadBoardingOfficier(StatusId);
            }
            else {
              clear();
              objfun.toastMsg("Invalid", "", context);
              return;
            }
          }
          // if (data["JStatus"] != 0 &&
          //     data["JStatus"] != null) {
          //   StatusId = data["JStatus"];
          //   var JobStatus = objfun.JobAllStatusList.where(
          //           (item) => item.Status ==  data["JStatus"]).toList();
          //   txtJobStatus.text = JobStatus[0].StatusName;
          // }
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
  Future loadBoardingOfficier(int statusType) async {

    if(statusType == 7){

      BoardOfficerId1 = objfun.EmpRefId;
      BoardOfficerAmt1 = 50;
    }
    else  if(statusType == 5){
      await OnlineApi.EditSalesOrder(context, SaleOrderId, 0);
      BoardOfficerId1 = objfun.SaleEditMasterList[0]["LBoardingOfficerRefid"];
      if(BoardOfficerId1 != objfun.EmpRefId ) {
        BoardOfficerId2 = objfun.EmpRefId;
        BoardOfficerAmt1 = 30;
        BoardOfficerAmt2 = 30;
      }
    }

  }
  Future UpdateBoardingOfficier(int statusType) async {


    Map<String, dynamic> master = {};

    if(statusType == 7) {

      master =
      {
        'Id': SaleOrderId,
        'CompanyRefId': objfun.Comid,
        'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'LBoardingOfficerRefid': BoardOfficerId1,
        'LBoardingAmount': BoardOfficerAmt1,

      };
    }
    else if(statusType == 5) {
      if(BoardOfficerId1 == objfun.EmpRefId ) {
        return false ;
      }
      master =
      {
        'Id': SaleOrderId,
        'CompanyRefId': objfun.Comid,
        'UserRefId': null,
        'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'LBoardingOfficerRefid': BoardOfficerId1,
        'LBoardingOfficer1Refid': BoardOfficerId2,
        'LBoardingAmount': BoardOfficerAmt1,
        'LBoardingAmount1': BoardOfficerAmt2,
      };
    }
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
          //await objfun.ConfirmationOK('Updated Successfully ', context);
          //Navigator.pop(context);

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
            Status = value.data1[0]["Status"];

            LoadJobDetails(value.data1[0]["SaleOrderMasterRefId"]);

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
  Future<void> _pickImage(ImageSource source) async {

    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      var Imagesource = await objfun.upload(
          File(pickedFile.path), objfun.apiPostimage, SaleOrderId,
          'SalesOrder', txtJobStatus.text.replaceAll(' ', ''));
      setState(() {
        imagenetwork.add(Imagesource);
      });
    }

  }
  Future DeleteImages(int index) async {

    if (txtJobStatus.text.isEmpty) {
      objfun.toastMsg('Select Status', '', context);
      return;
    }

    bool result =
    await objfun.ConfirmationMsgYesNo(context, "Are you sure to Delete ?");
    if (result == true) {
      setState(() {
        progress = false;
      });

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': objfun.Comid.toString(),
        'Id' : SaleOrderId.toString(),
        'FolderName' : 'SalesOrder',
        'FileName' :'/Upload/${objfun.Comid}/SalesOrder/$SaleOrderId/${txtJobStatus.text.replaceAll(' ', '')}/${imagenetwork[index]}',
        'SubFolderName' : txtJobStatus.text.replaceAll(' ', '')
      };
      await objfun
          .apiAllinoneSelectArray(
          objfun.apiDeleteimage,
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
            await objfun.ConfirmationOK('Deleted Successfully ', context);
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

      imagenetwork.removeAt(index);



    }
  }
  Future<void> _showDialogPreviewImage(int index) async {

    await showDialog(
        barrierDismissible: true,
        context: context,

        builder: (BuildContext context) {
          return Dialog(
            //elevation: 40.0,
              backgroundColor: Colors.transparent,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    CachedNetworkImage(
                      placeholder: (context,
                          url) =>
                      const CircularProgressIndicator(),
                      imageUrl: "${objfun.imagepath}SalesOrder/$SaleOrderId/${txtJobStatus.text.replaceAll(' ', '')}/${imagenetwork[index]}",
                      //fit: BoxFit.fill,
                    ),
                    const SizedBox(height: 7,),
                    CircleAvatar(
                      backgroundColor: colour.commonColorLight,
                      child:IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon: const Icon(
                        Icons.clear,
                        color: colour.commonColor,
                      )),
                    ),
                  ]));
        });
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
