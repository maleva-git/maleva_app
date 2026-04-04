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

import '../MasterSearch/JobAllStatus.dart';
import '../Transaction/SaleOrderDetails.dart';

part 'package:maleva/Boarding/mobileBoardingStatusUpdate.dart';
part 'package:maleva/Boarding/tabletBoardingStatusUpdate.dart';

class OldBoardingStatusUpdate extends StatefulWidget {
  final String? JobNo;
  final int? JobId;
  const OldBoardingStatusUpdate({super.key, this.JobNo, this.JobId});

  @override
  OldBoardingStatusUpdateState createState() => OldBoardingStatusUpdateState();
}
//test
class OldBoardingStatusUpdateState extends State<OldBoardingStatusUpdate> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  //final GlobalKey<AppBar> appBarKey = GlobalKey<AppBar>();
  GlobalKey appBarKey = GlobalKey();

  List<String> imagenetwork = [];
  String? dropdownValueFW1;
  String? dropdownValueFW2;
  String? dropdownValueFW3;
  String dtpStartTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpEndTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

  String BillType = "0";

  int SaleOrderId = 0;
  int StatusId = 0;

  bool checkBoxStartTime = false;
  bool checkBoxEndTime = false;
  bool checkBoxImageUpload = false;

  final txtStatus = TextEditingController();
  final txtJobNo = TextEditingController();


  final ImagePicker _picker = ImagePicker();
  List<File?> _images = [];

  final List<CachedNetworkImage?> _images2 = [];

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
    super.dispose();
  }

  Future startup() async {
    loadJobdata();
    setState(() {
      progress = true;
    });
  }
  Future loaddata() async {
    await OnlineApi.EditSalesOrder(
        context, SaleOrderId, int.parse(txtJobNo.text));
    await OnlineApi.SelectAllJobStatus(
        context, objfun
        .SaleEditMasterList[0]["JobMasterRefId"]);

    if(objfun.SaleEditMasterList[0]["JStatus"] !=0 )
    {
      StatusId= objfun.SaleEditMasterList[0]["JStatus"];
      var JobStatus = objfun.JobAllStatusList.where(
              (item) => item.Status == StatusId).toList();
      txtStatus.text = JobStatus[0].StatusName;
    } else{
      StatusId = 0;
      txtStatus.text = "";
    }
    String ImageDirectory = "/Upload/${objfun.Comid}/SalesOrder/$SaleOrderId/Boarding/";

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
  }
  Future loadJobdata() async {

    if (widget.JobId != null ) {
      String first4Chars = widget.JobNo!.substring(4);
     txtJobNo.text = first4Chars.toString();
      SaleOrderId = widget.JobId!;
      checkBoxImageUpload = true;
      setState(() {
        imagenetwork = [];
      });

      loaddata();
      _pickImage(ImageSource.gallery);

    }
  }
  Future UpdateStatusMail() async {
    List<String>  ImageUrl= [];
    if(imagenetwork.isEmpty){
      objfun.toastMsg("Select Images", "", context);
      return ;
    }
   /* bool result =
    await objfun.ConfirmationMsgYesNo(context, "Are you sure to update ?");
    if (result == false) {
      return ;
    }*/
    for(var i =0 ; i<imagenetwork.length ;i++){
      ImageUrl.add("${objfun.imagepath}SalesOrder/$SaleOrderId/Boarding/${imagenetwork[i]}");
    }
    Map<String?, dynamic> master = {};
    master =
    {
      'CompanyRefId': objfun.Comid,
      'RTIId': 0,
      'RTINo': '',
      'JobId': SaleOrderId,
      'JobNo': txtJobNo.text,
      'StatusId': StatusId,
      'StatusName': "${txtStatus.text} Done",
      'ImageURL': ImageUrl,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        objfun.apiBoardingMail,
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
            MaterialPageRoute(builder: (context) => const OldBoardingStatusUpdate()),
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
    BillType = "0";
    SaleOrderId = 0;
    StatusId = 0;
    txtStatus.text = "";
    txtJobNo.text = "";
    checkBoxStartTime = false;
    checkBoxEndTime = false;
    checkBoxImageUpload = false;
    imagenetwork = [];
    _images = [];
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
          'FileName' :'/Upload/${objfun.Comid}/SalesOrder/$SaleOrderId/Boarding/${imagenetwork[index]}',
          'SubFolderName' : 'Boarding'
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
                    imageUrl: "${objfun.imagepath}SalesOrder/$SaleOrderId/Boarding/${imagenetwork[index]}",
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
      var Imagesource = await objfun.upload(File(pickedFile.path), objfun.apiPostimage , SaleOrderId,'SalesOrder','Boarding');
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
              txtJobNo.text = predictions[i]['CNumber'].toString();
              SaleOrderId = predictions[i]['Id'];
              FocusScope.of(context).requestFocus(FocusNode());
              setState(() {
                imagenetwork = [];
              });

              loaddata();

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
  Future UpdateBoardingDetails() async {
    bool ResultStatus1 = false;
    bool ResultStatus2 = false;
    if (txtStatus.text.isEmpty && !checkBoxStartTime && !checkBoxEndTime && !checkBoxImageUpload) {
      objfun.toastMsg('Enter Details to update', '', context);
      return;
    }
    if (txtJobNo.text.isEmpty) {
      objfun.toastMsg('Enter Job No', '', context);
      return;
    }
    if(checkBoxImageUpload && imagenetwork.isEmpty ){
      objfun.toastMsg('Select Images !!', '', context);
      return;
    }
    bool result =
    await objfun.ConfirmationMsgYesNo(context, "Are you sure to Update ?");
    if (result == true) {
      setState(() {
        progress = false;
      });

      if(txtStatus.text.isNotEmpty || checkBoxStartTime || checkBoxEndTime) {
        Map<String?, dynamic> master = {};
        master =
        {
          'Id': SaleOrderId,
          'Comid': objfun.Comid,
          'Jobid': txtJobNo.text,
          'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
          'StatusRefId': StatusId,
          'BoardingStartTime': checkBoxStartTime ? DateTime.parse(dtpStartTime)
              .toIso8601String() : null,
          'BoardingEndTime': checkBoxEndTime ? DateTime.parse(dtpEndTime)
              .toIso8601String() : null,

        };
        Map<String, String> header = {
          'Content-Type': 'application/json; charset=UTF-8',
        };
        await objfun
            .apiAllinoneSelectArray(
            objfun.apiUpdateBoardingDetails,
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
               UpdateStatusMail();
              ResultStatus1 = true;
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
     /* if(checkBoxImageUpload && imagenetwork.length != 0 ){
        for(var i=0 ; i< _images.length ; i++){
          var Imagesource = await objfun.upload(_images[i]!, objfun.apiPostimage);
          imagenetwork.add(Imagesource);
        }
        if(imagenetwork.length != 0){
          Map<String?, dynamic> master = {};
          master =
          {
            'Id': 0,
            'Comid': objfun.Comid,
            'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
            'UserRefId': null,
            'LastEmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
            'SaleOrderMasterRefId': SaleOrderId,
            'Type': 'Boarding',
            'FilePath' : imagenetwork,
            'Active' : 1,
          };
          Map<String, String> header = {
            'Content-Type': 'application/json; charset=UTF-8',
          };
          await objfun
              .apiAllinoneSelectArray(
              "${objfun.apiInsertUploadimage}",
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
                ResultStatus2 = true;

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
      }*/
     if(ResultStatus1 || ResultStatus2){
     await objfun.ConfirmationOK('Updated Successfully ', context);
     clear();
     }

    }
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
