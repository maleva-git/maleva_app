import 'dart:io';
import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../MasterSearch/JobAllStatus.dart';
import '../SaleOrderDetails.dart';

part 'package:maleva/Transaction/AirFrieght/mobileAirFrieght.dart';
part 'package:maleva/Transaction/AirFrieght/tabletAirFrieght.dart';

class AirFrieghtUpdate extends StatefulWidget {
  final String? JobNo;
  final int? JobId;
  const AirFrieghtUpdate({super.key, this.JobNo, this.JobId});

  @override
  AirFrieghtUpdateState createState() => AirFrieghtUpdateState();
}

class AirFrieghtUpdateState extends State<AirFrieghtUpdate> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";
  //final GlobalKey<AppBar> appBarKey = GlobalKey<AppBar>();
  GlobalKey appBarKey = GlobalKey();

  List<String> imagenetwork = [];


  String BillType = "0";

  int SaleOrderId = 0;
  int StatusId = 0;

  bool checkBoxImageUpload = false;

  final txtStatus = TextEditingController();
  final txtJobNo = TextEditingController();
  final txtJobType = TextEditingController();
  final txtAWBNo = TextEditingController();
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
    txtJobNo.dispose();
    txtJobType.dispose();
    txtAWBNo.dispose();
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
    await OnlineApi.SelectJobType(context);
    await OnlineApi.SelectAllJobStatus(
        context, objfun
        .SaleEditMasterList[0]["JobMasterRefId"]);

    if(objfun.SaleEditMasterList[0]["JobMasterRefId"] !=0 && objfun.SaleEditMasterList[0]["JobMasterRefId"] != null )
      {
        var JobType = objfun.JobTypeList.where(
                (item) => item.Id == objfun.SaleEditMasterList[0]["JobMasterRefId"])
            .toList();

        if(JobType[0].Name.trim() != "AIR FRIEGHT IMPORT" && JobType[0].Name.trim() != "AIR FRIEGHT EXPORT")
          {
            objfun.toastMsg("Enter Air Frieght JobNo", "", context);
            clear();
            return;
          }
        txtJobType.text = JobType[0].Name;

    }
    else{
      txtJobType.text = "";
    }
    if(objfun.SaleEditMasterList[0]["JStatus"] !=0 )
    {
      StatusId= objfun.SaleEditMasterList[0]["JStatus"];
      var JobStatus = objfun.JobAllStatusList.where(
              (item) => item.Status == StatusId).toList();
      txtStatus.text = JobStatus[0].StatusName;
    }
    else{
      StatusId = 0;
      txtStatus.text = "";
    }
    txtAWBNo.text = objfun.SaleEditMasterList[0]["AWBNo"] ?? "";
    String ImageDirectory = "/Upload/${objfun.Comid}/SalesOrder/$SaleOrderId/AirFrieght/";

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
       /*  objfun.msgshow(
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
    setState(() {
      progress = true;
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
  void clear() {
    BillType = "0";
    SaleOrderId = 0;
    StatusId = 0;
    txtStatus.text = "";
    txtJobNo.text = "";
    txtJobType.text = "";
    txtAWBNo.text = "";
    checkBoxImageUpload = false;
    imagenetwork = [];

    setState(() {
      progress = true;
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
        'FileName' :'/Upload/${objfun.Comid}/SalesOrder/$SaleOrderId/AirFrieght/${imagenetwork[index]}',
        'SubFolderName' : 'AirFrieght'
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
                      imageUrl: "${objfun.imagepath}SalesOrder/$SaleOrderId/AirFrieght/${imagenetwork[index]}",
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
      var Imagesource = await objfun.upload(File(pickedFile.path), objfun.apiPostimage , SaleOrderId,'SalesOrder','AirFrieght');
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
        top: objfun.MalevaScreen == 1
            ?appBarBox!.size.height + height * 0.12 + 10 :appBarBox!.size.height + height * 0.25 + 10,
        left: objfun.MalevaScreen == 1
            ?10 :70,
        right: objfun.MalevaScreen == 1
            ?10 :500,
        child: Material(
          color: colour.commonColorLight,
          elevation: 1,
          textStyle: GoogleFonts.lato(
            textStyle:TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: objfun.FontLow,
              letterSpacing: 0.3)),
          child:
          SizedBox(height: 350, child: ListView(children: suggestions)),
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

  Future UpdateAirFrieghtDetails() async {

    if (txtStatus.text.isEmpty  && !checkBoxImageUpload) {
      objfun.toastMsg('Enter Details to update', '', context);
      return;
    }
    if (txtJobNo.text.isEmpty) {
      objfun.toastMsg('Enter Job No', '', context);
      return;
    }
    if (txtAWBNo.text.isEmpty) {
      objfun.toastMsg('Enter AWB No', '', context);
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


        Map<String?, dynamic> master = {};
        master =
        {
          'Id': SaleOrderId,
          'Comid': objfun.Comid,
          'Jobid': txtJobNo.text,
          'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
          'StatusRefId': StatusId,
          'AWBNO' : txtAWBNo.text

        };
        Map<String, String> header = {
          'Content-Type': 'application/json; charset=UTF-8',
        };
        await objfun
            .apiAllinoneSelectArray(
            objfun.apiUpdateAirFrieghtDetails,
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
              clear();
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);
  }
}
