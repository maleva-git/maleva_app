import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/Material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../MasterSearch/Employee.dart';
part 'package:maleva/Operation/mobileFWUpdate.dart';
part 'package:maleva/Operation/tabletFWUpdate.dart';

class FWUpdate extends StatefulWidget {

  const FWUpdate({super.key});

  @override
  FWUpdateState createState() => FWUpdateState();
}

class FWUpdateState extends State<FWUpdate> with TickerProviderStateMixin{
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";

  bool checkBoxImageUpload = false;
  List<String> imagenetwork = [];
  final ImagePicker _picker = ImagePicker();

  bool checkBoxImageUpload2 = false;
  List<String> imagenetwork2 = [];
  final ImagePicker _picker2 = ImagePicker();

  bool checkBoxImageUpload3 = false;
  List<String> imagenetwork3 = [];
  final ImagePicker _picker3 = ImagePicker();

  late TabController _tabController;

  int SealEmpId1 = 0;
  int SealEmpId2 = 0;
  int SealEmpId3 = 0;
  int BreakEmpId1 = 0;
  int BreakEmpId2 = 0;
  int BreakEmpId3 = 0;
  int SaleOrderId = 0;
  final txtSmk1 = TextEditingController();
  final txtSmk2 = TextEditingController();
  final txtSmk3 = TextEditingController();
  final txtENRef1 = TextEditingController();
  final txtENRef2 = TextEditingController();
  final txtENRef3 = TextEditingController();
  final txtSealByEmp1 = TextEditingController();
  final txtSealByEmp2 = TextEditingController();
  final txtSealByEmp3 = TextEditingController();
  final txtBreakByEmp1 = TextEditingController();
  final txtBreakByEmp2 = TextEditingController();
  final txtBreakByEmp3 = TextEditingController();
  final txtExRef1 = TextEditingController();
  final txtExRef2 = TextEditingController();
  final txtExRef3 = TextEditingController();

  @override
  void initState() {
     OnlineApi.GetJobNoForwarding(context,3);
    startup();
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
  txtSmk1.dispose();
  txtSmk2.dispose();
  txtSmk3.dispose();
  txtENRef1.dispose();
  txtENRef2.dispose();
  txtENRef3.dispose();
  txtSealByEmp1.dispose();
  txtSealByEmp2.dispose();
  txtSealByEmp3.dispose();
  txtBreakByEmp1.dispose();
  txtBreakByEmp2.dispose();
  txtBreakByEmp3.dispose();
  txtExRef1.dispose();
  txtExRef2.dispose();
  txtExRef3.dispose();
    super.dispose();
  }

  Future startup() async {
    setState(() {
      progress = true;
    });
  }
  // Future<void> pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //
  //   if (result != null) {
  //     PlatformFile file = result.files.first;
  //     var Imagesource = await objfun.upload(
  //         File(file.path!), objfun.apiPostfile, SaleOrderId,
  //         'SalesOrder', txtSmk1.text);
  //     List<String> ImagesourceList = Imagesource.split(',');
  //     for(var i = 0 ; i < ImagesourceList.length ; i++ ) {
  //     var convert = objfun.port + json.decode(ImagesourceList[i]);
  //     if (!imagenetwork.contains(convert)) {
  //       imagenetwork.add(convert);
  //
  //     }
  //     //objfun.launchInBrowser(convert);
  //     }
  //     setState(() {
  //
  //     });
  //     print('File name: ${file.name}');
  //     print('File size: ${file.size}');
  //     print('File path: ${file.path}');
  //   } else {
  //
  //   }
  // }
  Future<void> _pickImage(ImageSource source,int type) async {
    if(type == 1) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        var Imagesource = await objfun.upload(
            File(pickedFile.path), objfun.apiPostimage, SaleOrderId,
            'SalesOrder', txtSmk1.text);

        setState(() {
          imagenetwork.add(Imagesource);
        });
      }
    }
    else if(type == 2) {
      final XFile? pickedFile2 = await _picker2.pickImage(source: source);
      if (pickedFile2 != null) {
        var Imagesource = await objfun.upload(
            File(pickedFile2.path), objfun.apiPostimage, SaleOrderId,
            'SalesOrder', txtSmk2.text);
        setState(() {
          imagenetwork2.add(Imagesource);
        });
      }
    }
    else if(type == 3) {
      final XFile? pickedFile3 = await _picker3.pickImage(source: source);
      if (pickedFile3 != null) {
        var Imagesource = await objfun.upload(
            File(pickedFile3.path), objfun.apiPostimage, SaleOrderId,
            'SalesOrder', txtSmk3.text);
        setState(() {
          imagenetwork3.add(Imagesource);
        });
      }
    }
  }
  Future DeleteImages(int index,int type) async {
    var smkUpload = "";
    var networkImg = "";
if(type == 1){
  smkUpload = txtSmk1.text;
  networkImg = imagenetwork[index];
}
else if(type == 2){
  smkUpload = txtSmk2.text;
  networkImg = imagenetwork2[index];
}
else if(type == 3){
  smkUpload = txtSmk3.text;
  networkImg = imagenetwork3[index];
}

    if (smkUpload.isEmpty) {
      objfun.toastMsg('Enter SMK No', '', context);
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
        'FileName' :'/Upload/${objfun.Comid}/SalesOrder/$SaleOrderId/$smkUpload/$networkImg',
        'SubFolderName' : smkUpload
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
      if(type == 1){
        imagenetwork.removeAt(index);
      }
      else if(type == 2){
        imagenetwork2.removeAt(index);
      }
      else if(type == 3){
        imagenetwork3.removeAt(index);
      }


    }
  }
  Future<void> _showDialogPreviewImage(int index,int type) async {
    var smkUpload = "";
    if(type == 1){
      smkUpload = txtSmk1.text;
    }
    else if(type == 2){
      smkUpload = txtSmk2.text;
    }
    else if(type == 3){
      smkUpload = txtSmk3.text;
    }
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
                      imageUrl: "${objfun.imagepath}SalesOrder/$SaleOrderId/$smkUpload/${imagenetwork[index]}",
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
  Future loaddata(int type) async {
    var smkUpload = "";
    if(type == 1){
      smkUpload = txtSmk1.text;
    }
    else if(type == 2){
      smkUpload = txtSmk2.text;
    }
    else if(type == 3){
      smkUpload = txtSmk3.text;
    }
    await OnlineApi.EditSalesOrder(
        context, SaleOrderId, 0);
    await OnlineApi.SelectEmployee(context, '', 'Operation');
    txtENRef1.text = objfun.SaleEditMasterList[0]["ForwardingEnterRef"] ?? "";
    txtENRef2.text = objfun.SaleEditMasterList[0]["ForwardingEnterRef2"] ?? "";
    txtENRef3.text = objfun.SaleEditMasterList[0]["ForwardingEnterRef3"] ?? "";
    txtExRef1.text = objfun.SaleEditMasterList[0]["ForwardingExitRef"] ?? "";
    txtExRef2.text = objfun.SaleEditMasterList[0]["ForwardingExitRef2"] ?? "";
    txtExRef3.text = objfun.SaleEditMasterList[0]["ForwardingExitRef3"] ?? "";
    if(objfun.SaleEditMasterList[0]["SealbyRefid"] !=0 )
    {
      SealEmpId1 = objfun.SaleEditMasterList[0]["SealbyRefid"];
      var SealByEmp1 = objfun.EmployeeList.where(
              (item) => item.Id == SealEmpId1).toList();
      txtSealByEmp1.text = SealByEmp1[0].AccountName;
    } else{
      SealEmpId1 = 0;
      txtSealByEmp1.text = "";
    }
    if(objfun.SaleEditMasterList[0]["SealbyRefid2"] !=0 )
    {
      SealEmpId2 = objfun.SaleEditMasterList[0]["SealbyRefid2"];
      var SealByEmp2 = objfun.EmployeeList.where(
              (item) => item.Id == SealEmpId2).toList();
      txtSealByEmp2.text = SealByEmp2[0].AccountName;
    } else{
      SealEmpId2 = 0;
      txtSealByEmp2.text = "";
    }
    if(objfun.SaleEditMasterList[0]["SealbyRefid3"] !=0 )
    {
      SealEmpId3 = objfun.SaleEditMasterList[0]["SealbyRefid3"];
      var SealByEmp3 = objfun.EmployeeList.where(
              (item) => item.Id == SealEmpId3).toList();
      if(SealByEmp3.length != 0) {
        txtSealByEmp3.text = SealByEmp3[0].AccountName;
      }
    } else{
      SealEmpId3 = 0;
      txtSealByEmp3.text = "";
    }
    if(objfun.SaleEditMasterList[0]["SealbreakbyRefid"] !=0 )
    {
      BreakEmpId1 = objfun.SaleEditMasterList[0]["SealbreakbyRefid"];
      var BSealByEmp1 = objfun.EmployeeList.where(
              (item) => item.Id == BreakEmpId1).toList();
      txtBreakByEmp1.text = BSealByEmp1[0].AccountName;
    } else{
      BreakEmpId1 = 0;
      txtBreakByEmp1.text = "";
    }
    if(objfun.SaleEditMasterList[0]["SealbreakbyRefid2"] !=0 )
    {
      BreakEmpId2 = objfun.SaleEditMasterList[0]["SealbreakbyRefid2"];
      var BSealByEmp2 = objfun.EmployeeList.where(
              (item) => item.Id == BreakEmpId2).toList();
      txtBreakByEmp2.text = BSealByEmp2[0].AccountName;
    } else{
      BreakEmpId2 = 0;
      txtBreakByEmp2.text = "";
    }
    if(objfun.SaleEditMasterList[0]["SealbreakbyRefid3"] !=0 )
    {
      BreakEmpId3 = objfun.SaleEditMasterList[0]["SealbreakbyRefid3"];
      var BSealByEmp3 = objfun.EmployeeList.where(
              (item) => item.Id == BreakEmpId3).toList();
      txtBreakByEmp3.text = BSealByEmp3[0].AccountName;
    } else{
      BreakEmpId3 = 0;
      txtBreakByEmp3.text = "";
    }
    String ImageDirectory = "/Upload/${objfun.Comid}/SalesOrder/$SaleOrderId/$smkUpload/";

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
            if(type ==1){
              imagenetwork.add(resultData[i]);
            }
            else if(type ==2){
              imagenetwork2.add(resultData[i]);
            }
            else if(type ==3){
              imagenetwork3.add(resultData[i]);
            }

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

  void clear() {
    SealEmpId1 = 0;
    SealEmpId2 = 0;
    SealEmpId3 = 0;
     BreakEmpId1 = 0;
     BreakEmpId2 = 0;
     BreakEmpId3 = 0;
     SaleOrderId = 0;

      txtSmk1.text = "";
      txtSmk2.text = "";
      txtSmk3.text = "";
      txtENRef1.text = "";
      txtENRef2.text = "";
      txtENRef3.text = "";
      txtSealByEmp1.text = "";
      txtSealByEmp2.text = "";
      txtSealByEmp3.text = "";
      txtBreakByEmp1.text = "";
      txtBreakByEmp2.text = "";
      txtBreakByEmp3.text = "";
      txtExRef1.text = "";
      txtExRef2.text = "";
      txtExRef3.text = "";
setState(() {
  progress =true;
});

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
  GlobalKey appBarKey = GlobalKey();
  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(String place, bool show, int type) async {

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
        if(type==1){
          predictions = objfun.JobNoList
              .where((element) => element['ForwardingSMKNo'].toString().contains(place))
              .toList();
        }
        else if(type==2){
          predictions = objfun.JobNoList
              .where((element) => element['ForwardingSMKNo2'].toString().contains(place))
              .toList();
        }
        else{
          predictions = objfun.JobNoList
              .where((element) => element['ForwardingSMKNo3'].toString().contains(place))
              .toList();
        }

      }
      if (predictions.isNotEmpty) {
        for (int i = 0; i < predictions.length; i++) {
          suggestions.add(InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(type==1?predictions[i]['ForwardingSMKNo']:type==2?predictions[i]['ForwardingSMKNo2']:predictions[i]['ForwardingSMKNo3'].toString()) ,
            ),
            onTap: () async {
              SaleOrderId = predictions[i]['Id'];
              if(type == 1){
                txtSmk1.text = predictions[i]['ForwardingSMKNo'].toString();
                loaddata(1);
              }
              else if(type == 2){
                txtSmk2.text = predictions[i]['ForwardingSMKNo2'].toString();
                loaddata(2);
              }
              else{
                txtSmk3.text = predictions[i]['ForwardingSMKNo3'].toString();
                loaddata(3);

              }
              FocusScope.of(context).requestFocus(FocusNode());


              clearOverlay();
            },
          ));
        }
      }
      if(suggestions.isEmpty){
        objfun.toastMsg("Enter Correct SMK No", " ", context);
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
        top:appBarBox!.size.height + height * 0.12 + 10,
        left: objfun.MalevaScreen == 1
            ?10 :100,
        right: objfun.MalevaScreen == 1
            ?10 :100,
        child: Material(
            color: colour.commonColorLight,
            elevation: 1,
          textStyle:GoogleFonts.lato(
            textStyle: TextStyle(
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
  Future UpdateForwarding() async {


    if (txtSmk1.text.isEmpty && txtSmk2.text.isEmpty && txtSmk3.text.isEmpty ) {
      objfun.toastMsg('Enter Entry SMK No', '', context);
      return;
    }

    if((txtSmk1.text.isNotEmpty && txtSmk2.text.isNotEmpty) || (txtSmk1.text.isNotEmpty && txtSmk3.text.isNotEmpty)|| (txtSmk2.text.isNotEmpty && txtSmk3.text.isNotEmpty)){
      objfun.toastMsg('Enter Proper Entry Details', '', context);
      return;
    }

    bool result =
    await objfun.ConfirmationMsgYesNo(context, "Are you sure to Update ?");
    if (result == true) {
      setState(() {
        progress = false;
      });
      Map<String?,dynamic> master = {};
      master =
        {
          'Id': SaleOrderId,
          'Comid': objfun.Comid,
          'Jobid' : 0,
          'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
          'SealbyRefid': SealEmpId1,
          'SealbreakbyRefid': BreakEmpId1,
          'SealbyRefid2': SealEmpId2,
          'SealbreakbyRefid2': BreakEmpId2,
          'SealbyRefid3': SealEmpId3,
          'SealbreakbyRefid3': BreakEmpId3,
          'ForwardingEnterRef': txtENRef1.text,
          'ForwardingExitRef': txtExRef1.text,
          'ForwardingEnterRef2': txtENRef2.text,
          'ForwardingExitRef2': txtExRef2.text,
          'ForwardingEnterRef3': txtENRef3.text,
          'ForwardingExitRef3': txtExRef3.text,
        };

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      await objfun
          .apiAllinoneSelectArray(
          objfun.apiUpdateForwarding,
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);
  }
}