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

import '../../Boarding/BoardingStatusUpdate.dart';
import '../../MasterSearch/JobAllStatus.dart';
import '../../MasterSearch/WareHouseList.dart';
import '../AirFrieght/AirFrieght.dart';
import '../SaleOrderDetails.dart';

part 'package:maleva/Transaction/Stock/mobileStockInEntry.dart';
part 'package:maleva/Transaction/Stock/tabletStockInEntry.dart';

class Stockinentry extends StatefulWidget {
  final String? JobNo;
  final int? JobId;
  const Stockinentry({super.key, this.JobNo, this.JobId});

  @override
  StockinentryState createState() => StockinentryState();
}
//test
class StockinentryState extends State<Stockinentry> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  //final GlobalKey<AppBar> appBarKey = GlobalKey<AppBar>();
  GlobalKey appBarKey = GlobalKey();

  String dtpStockdate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String BillType = "0";
  String ShipName = "";
  String CustomerName = "";
  String JobDate = "";

  int WareHouseId = 0;
  int SaleOrderId = 0;
  int StatusId = 0;
  int JobId = 0;
  int WeightPkg = 0;



  final txtPackages = TextEditingController();
  final txtJobNo = TextEditingController();
  final txtStockNo = TextEditingController();
  final txtWareHouse = TextEditingController();
  final txtJobStatus = TextEditingController();

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
    txtPackages.dispose();
    txtJobNo.dispose();
    txtWareHouse.dispose();
    txtStockNo.dispose();
    super.dispose();
  }

  Future startup() async {
    await OnlineApi.SelectWareHouse(context);
    await OnlineApi.SelectStockJob(context);
    await OnlineApi.MaxStockNo(context);
    txtStockNo.text =  objfun.MaxStockNum;
    loaddata();
    setState(() {
      progress = true;
    });
  }

  Future loaddata() async {
    if (widget.JobId != null ) {
      bool isPresent = objfun.StockJobList.any((warehouse) => warehouse.Id == widget.JobId);

      if (isPresent) {

        bool result = await objfun.ConfirmationMsgYesNo(context, "Stock Already Exists !! Do you want Remove and Save ??");
        if (result == false) {
          return ;
        }

      }
      String first4Chars = widget.JobNo!.substring(4);
      txtJobNo.text = first4Chars.toString();
     // txtJobNo.text = widget.JobNo!;
      SaleOrderId = widget.JobId!;
      LoadJobDetails(SaleOrderId);
    }
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
  void clear() {
    BillType = "0";
    SaleOrderId = 0;
    WareHouseId = 0;
    txtPackages.text = "";
    txtWareHouse.text = "";
    txtStockNo.text = "";
    txtJobNo.text = "";
    ShipName = "";
    CustomerName = "";
    JobDate = "";

    setState(() {
      progress =true;
    });

  }


  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }

    showsearch = false;
  }

  bool showsearch = false;
  OverlayEntry? overlayEntry;
  String previousSearchTerm = '';

  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(String place, bool show) async {

    if (show == false) {
      if (place == previousSearchTerm) {
        return;
      }
      previousSearchTerm = place;
      clearOverlay();

      if (place.isEmpty) {
        return;
      }
      setState(() {
        showsearch = true;
      });
    } else {
      // if (context == null) {
      //   return;
      // }
      clearOverlay();
      setState(() {
        showsearch = true;
      });
    }
    try {
      place = place.replaceAll(" ", "+");
      List<Widget> suggestions = [];

      List<dynamic> predictions = [];

      if (place == '') {
        predictions = objfun.JobNoList;
      } else {
        predictions = objfun.JobNoList
            .where((element) =>
            element['CNumber'].toString().contains(place))
            .toList();
      }
      if (predictions.isNotEmpty) {
        for (int i = 0; i < predictions.length; i++) {
          suggestions.add(InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(predictions[i]['CNumber'].toString()) ,
            ),
            onTap: () async {
            //  bool isPresent = objfun.StockJobList.contains(predictions[i]['Id']);
              bool isPresent = objfun.StockJobList.any((warehouse) => warehouse.Id == predictions[i]['Id']);

              if (isPresent) {
                clearOverlay();
                bool result =
                await objfun.ConfirmationMsgYesNo(context, "Stock Already Exists !! Do you want Remove and Save ??");
                if (result == false) {
                  return ;
                }

              }

              txtJobNo.text = predictions[i]['CNumber'].toString();
              SaleOrderId = predictions[i]['Id'];
              LoadJobDetails(SaleOrderId);
              FocusScope.of(context).requestFocus(FocusNode());
              setState(() {

              });



              clearOverlay();
            },
          ));
        }
      }
      if(suggestions.isEmpty){
        objfun.toastMsg("Enter Correct Job No", " ", context);
        return;
      }
      displayAutoCompleteSuggestions(suggestions,context);
    } finally {}
  }

  void displayAutoCompleteSuggestions(List<Widget> suggestions,context) {

    double height = MediaQuery.of(context).size.height;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    final RenderBox? appBarBox =
    appBarKey.currentContext!.findRenderObject() as RenderBox?;

    clearOverlay();
    setState(() {
      showsearch = true;
    });
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: null,
        top:objfun.MalevaScreen == 1
            ?appBarBox!.size.height + height * 0.12 + 10:appBarBox!.size.height + height * 0.22 + 10,
        left: objfun.MalevaScreen == 1
            ?10 :70,
        right: objfun.MalevaScreen == 1
            ?10 :500,
        child: Material(
          color: colour.commonColorLight,
          elevation: 1,
          textStyle:GoogleFonts.lato(textStyle: TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: objfun.FontLow,
              letterSpacing: 0.3),),
          child:
          SizedBox(height: 350, child: ListView(children: suggestions))
        ),
      ),
    );


    Overlay.of(context).insert(overlayEntry!);


  }

  Future<bool> _onBackPressed() async {

    if(overlayEntry != null){
      clearOverlay();
      return false;
    }
    Navigator.of(context).pop();
    return true;
  }

  Future UpdateStockData() async {

    if(SaleOrderId == 0 || txtJobNo.text.isEmpty ){
      objfun.toastMsg("Select Job", "", context);
      return ;
    }
    if(StatusId == 0 || txtJobStatus.text.isEmpty ){
      objfun.toastMsg("Select Status", "", context);
      return ;
    }
    // if(txtWareHouse.text.isEmpty || WareHouseId == 0){
    //   objfun.toastMsg("Select WareHouse Location", "", context);
    //   return ;
    // }
    if(txtPackages.text.isEmpty ){
      objfun.toastMsg("Enter Packages", "", context);
      return ;
    }
    if(int.parse(txtPackages.text) != WeightPkg ){
      objfun.toastMsg("Invalid Packages", "", context);
      return ;
    }
     bool result =
    await objfun.ConfirmationMsgYesNo(context, "Do you want to Save ?");
    if (result == false) {
      return ;
    }
    var preJob = "MY00";
     if(int.parse(BillType) == 1){
     preJob = "TR00";
     }

    List<String>  ImageUrl= [];
    for(var i =0 ; i<imagenetwork.length ;i++){
      ImageUrl.add("${objfun.imagepath}SalesOrder/$SaleOrderId/${txtJobStatus.text.replaceAll(' ', '')}/${imagenetwork[i]}");
    }
    List<dynamic> master = [];

    master =
    [{
      'Id': 0,
      'CompanyRefId': objfun.Comid,
      'UserRefId': objfun.Comid,
      'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
      'SaleOrderMasterRefId': SaleOrderId,
      'StockDate': DateTime.parse(dtpStockdate).toIso8601String(),
      'CNumberDisplay': "",
      'CNumber': 0,
      'NumberOfPackages': txtPackages.text,
      'statusId':StatusId,
      'PortMasterRefId': 0,
      'Barcode': preJob+txtJobNo.text,
      'BarcodeLabelDisplay':preJob+ txtJobNo.text,
      'Status': 0,
      'ImageURL': ImageUrl,
    }];
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray("${objfun.apiInsertStockIn}${objfun.Comid}",
        master,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          var lStockid = value.data2;
          await objfun.ConfirmationOK('Saved Successfully ', context);
          stockPrint(lStockid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Stockinentry()),
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
          var data = value.data1[0] ;

          if(data["CustomerName"] != null && data["CustomerName"] != "")
          {
            ShipName =data["LoadingVesselName"];
          }
          else
          {
            ShipName =data["OffVesselName"];
          }
          RegExp regExp = RegExp(r'\d+');
          String? result = regExp.stringMatch(data["Quantity"]);
          WeightPkg = int.parse(result ?? "0");
           JobId = data["JobMasterRefId"];
          await OnlineApi.SelectAllJobStatus(context, JobId);

          // if (data["JStatus"] != 0 &&
          //     data["JStatus"] != null) {
          //   StatusId = data["JStatus"];
          //   var JobStatus = objfun.JobAllStatusList.where(
          //           (item) => item.Status ==  data["JStatus"]).toList();
          //   txtJobStatus.text = JobStatus[0].StatusName;
          // }
          // if(data["JStatus"] == 18){
          //    StatusId = 3;
          //      var JobStatus = objfun.JobAllStatusList.where(
          //              (item) => item.Status == StatusId).toList();
          //      txtJobStatus.text = JobStatus[0].StatusName;
          // }
          // else{
          //   StatusId = data["JStatus"];
          //   var JobStatus = objfun.JobAllStatusList.where(
          //           (item) => item.Status == StatusId).toList();
          //   txtJobStatus.text = JobStatus[0].StatusName;
          // }
          // else{
          //   clear();
          //   objfun.toastMsg("Invalid", "", context);
          //   return ;
          // }
            CustomerName = data["CustomerName"];
            JobDate = data["SSaleDate"];
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

  Future stockPrint(int id) async {

    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    Map<String?, dynamic> master = {};

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiPrintStock}$id&Comid=$Comid",
        master,
        header,
        context)
        .then((resultData) async {
      if (resultData != "") {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {

          List<BarcodePrintModel> printData = [];
          for(var i=1;i <= int.parse(value.data1[0]["NumberOfPackages"]) ;i++){
            // if (input.length > 15) {
            //   // Split the string at the 15th character
            //   String firstPart = input.substring(0, 15);
            //   String secondPart = input.substring(15);
            //   return '$firstPart | $secondPart'; // Separate with a space or any separator
            // }

            BarcodePrintModel model = BarcodePrintModel(
                "MALEVA",
                value.data1[0]["VesselName"],
                value.data1[0]["VesselName"],
                value.data1[0]["JobNo"]+"-"+i.toString()+"/"+value.data1[0]["NumberOfPackages"],
                value.data1[0]["SSaleDate"],
                value.data1[0]["JobNo"],
                value.data1[0]["JobNo"],
                "[ " +i.toString()+"/"+value.data1[0]["NumberOfPackages"]+" ]"
            );
            printData.add(model);
          }

          await objfun.printdata(printData);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Stockinentry()),
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
