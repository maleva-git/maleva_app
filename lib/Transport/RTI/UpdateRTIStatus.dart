import 'dart:io';
import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

import 'UpdateRTIDetails.dart';

part 'package:maleva/Transport/RTI/mobileUpdateRTIStatus.dart';
part 'package:maleva/Transport/RTI/tabletUpdateRTIStatus.dart';

class RTIStatus extends StatefulWidget {
  final List<dynamic>? RTIDetails;
  const RTIStatus({super.key , this.RTIDetails});

  @override
  RTIStatusState createState() => RTIStatusState();
}

class RTIStatusState extends State<RTIStatus> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";

  List<String> imagenetwork = [];
  String? dropdownValueFW1;
  String? dropdownValueFW2;
  String? dropdownValueFW3;
  String dtpStartTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpEndTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  static const List<String> DriverStatus = <String>['PickUp', 'Delivery'];
  String dropdownValueStatus = DriverStatus.first;
  String BillType = "0";

  int SaleOrderId = 0;
  int RTIId = 0;
  int StatusId = 0;
  String StatusName = "";
  String DriverFolder = "DriverPickup";
  bool checkBoxStartTime = false;
  bool checkBoxEndTime = false;
  bool checkBoxImageUpload = false;

  final txtStatus = TextEditingController();
  final txtJobNo = TextEditingController();
  final txtRTINo = TextEditingController();


  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {

   SaleOrderId = int.parse(widget.RTIDetails![0]["JobId"]);
   RTIId = widget.RTIDetails![0]["RtiId"];
   txtJobNo.text = widget.RTIDetails![0]["JobNo"];
   txtRTINo.text = widget.RTIDetails![0]["RTINo"];
   startup();
   super.initState();
  }

  @override
  void dispose() {
    txtStatus.dispose();
    txtJobNo.dispose();
    txtRTINo.dispose();
    super.dispose();
  }

  Future startup() async {

    loaddata();
    setState(() {
      progress = true;
    });
  }
  Future loaddata() async {
    String ImageDirectory = "/Upload/${objfun.Comid}/SalesOrder/$SaleOrderId/$DriverFolder/";

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiGetimage}${ImageDirectory.toString()}", null, header, context)
        .then((resultData) async {
      if (resultData != "") {

        if (resultData.length != 0) {
          for( var i=0;i < resultData.length ; i++) {
            imagenetwork.add(resultData[i]);
          }
        }
        setState(() {
          progress = true;
        });
      }
    }).onError((error, stackTrace) {
      /*   objfun.msgshow(
          error.toString(),
          stackTrace.toString(),
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2);*/
    });
    //SendMail();
  }

  void clear() {
    BillType = "0";
    SaleOrderId = 0;
    StatusId = 0;
    RTIId = 0;
    txtStatus.text = "";
    txtJobNo.text = "";
    txtRTINo.text = "";
    checkBoxImageUpload = false;
    imagenetwork = [];
    DriverFolder = "DriverPickup";

    setState(() {
      progress =true;
    });

  }

  Future DeleteImages(int index) async {

    if (txtJobNo.text.isEmpty) {
      objfun.toastMsg('Enter Job No', '', context);
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
        'FileName' :'/Upload/${objfun.Comid}/SalesOrder/$SaleOrderId/$DriverFolder/${imagenetwork[index]}',
        'SubFolderName' : DriverFolder
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
                      imageUrl: "${objfun.imagepath}SalesOrder/$SaleOrderId/$DriverFolder/${imagenetwork[index]}",
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      var Imagesource = await objfun.upload(File(pickedFile.path), objfun.apiPostimage , SaleOrderId,'SalesOrder', DriverFolder);
      setState(() {
        imagenetwork.add(Imagesource);
        // _images.add(File(pickedFile.path));
      });
    }
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

  Future<bool> _onBackPressed() async {

    Navigator.of(context).pop();
    return true;
  }
  Future UpdateStatusMail() async {
    List<String>  ImageUrl= [];
    if(imagenetwork.isEmpty){
     objfun.toastMsg("Select Images", "", context);
     return ;
     }
    bool result =
    await objfun.ConfirmationMsgYesNo(context, "Are you sure to update ?");
    if (result == false) {
      return ;
    }
    for(var i =0 ; i<imagenetwork.length ;i++){
      ImageUrl.add("${objfun.imagepath}SalesOrder/$SaleOrderId/$DriverFolder/${imagenetwork[i]}");
    }
        Map<String?, dynamic> master = {};
        master =
        {
          'CompanyRefId': objfun.Comid,
          'RTIId': RTIId,
          'RTINo': txtRTINo.text,
          'JobId': SaleOrderId,
          'JobNo': txtJobNo.text,
          'StatusId': StatusId,
          'StatusName': "$dropdownValueStatus Done",
          'ImageURL': ImageUrl,
        };
        Map<String, String> header = {
          'Content-Type': 'application/json; charset=UTF-8',
        };
        await objfun
            .apiAllinoneSelectArray(
            objfun.apiRTIMail,
            master,
            header,
            context)
            .then((resultData) async {
          if (resultData != "") {
            ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
            if (value.IsSuccess == true) {
              await objfun.ConfirmationOK('Updated Successfully ', context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OldUpdateRTI()),
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

    return width < 768
        ? mobiledesign(this, context)
        : tabletdesign(this, context);
  }
}
