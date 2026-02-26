import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;


import '../MasterSearch/Employee.dart';

part 'package:maleva/Operation/mobileFWBreakSealUpdate.dart';
part 'package:maleva/Operation/tabletFWBreakSealUpdate.dart';
class FWUpdateBreakSeal extends StatefulWidget {

  const FWUpdateBreakSeal({super.key});

  @override
  FWUpdateBreakSealState createState() => FWUpdateBreakSealState();
}

class FWUpdateBreakSealState extends State<FWUpdateBreakSeal> with TickerProviderStateMixin{
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";


  late TabController _tabController;

  int BreakEmpId1 = 0;
  int BreakEmpId2 = 0;
  int BreakEmpId3 = 0;
  int SaleOrderId = 0;

  final txtSmk1 = TextEditingController();
  final txtSmk2 = TextEditingController();
  final txtSmk3 = TextEditingController();
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

  void clear() {

    BreakEmpId1 = 0;
    BreakEmpId2 = 0;
    BreakEmpId3 = 0;
    SaleOrderId = 0;

    txtSmk1.text = "";
    txtSmk2.text = "";
    txtSmk3.text = "";
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
  void autoCompleteSearch(String place, bool show , int type) async {

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
              await OnlineApi.EditSalesOrder(
                  context, SaleOrderId, predictions[i]['CNumber']);
              await OnlineApi.SelectEmployee(context, '', 'Operation');

              if(type == 1){
                txtSmk1.text = predictions[i]['ForwardingSMKNo'].toString();
                txtExRef1.text = objfun.SaleEditMasterList[0]["ForwardingExitRef"] ?? "";
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
              }
              else if(type == 2){
                txtSmk2.text = predictions[i]['ForwardingSMKNo2'].toString();
                txtExRef2.text = objfun.SaleEditMasterList[0]["ForwardingExitRef2"] ?? "";
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
              }
              else{
                  txtSmk3.text = predictions[i]['ForwardingSMKNo3'].toString();
                  txtExRef3.text = objfun.SaleEditMasterList[0]["ForwardingExitRef3"] ?? "";
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
              }
              FocusScope.of(context).requestFocus(FocusNode());
             setState(() {
               progress = true;
             });
              clearOverlay();
            },
          ));
        }
      }
      if(suggestions.isEmpty){
        objfun.toastMsg("Enter Correct Smk No", " ", context);
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
          textStyle: GoogleFonts.lato(
            textStyle:TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: objfun.FontLow,
              letterSpacing: 0.3),
        ),
          child:
          SizedBox(height: 350, child: ListView(shrinkWrap:true ,children: suggestions))),
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
    if((txtExRef1.text.isNotEmpty && txtExRef2.text.isNotEmpty) || (txtExRef1.text.isNotEmpty && txtExRef3.text.isNotEmpty)|| (txtExRef2.text.isNotEmpty && txtExRef3.text.isNotEmpty)){
      objfun.toastMsg('Enter Proper Exit Ref Details', '', context);
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
        'Jobid' : txtSmk1.text,
        'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'SealbyRefid': 0,
        'SealbreakbyRefid': BreakEmpId1,
        'SealbyRefid2': 0,
        'SealbreakbyRefid2': BreakEmpId2,
        'SealbyRefid3': 0,
        'SealbreakbyRefid3': BreakEmpId3,
        'ForwardingEnterRef': objfun.SaleEditMasterList[0]["ForwardingEnterRef"] ?? "",
        'ForwardingExitRef': txtExRef1.text,
        'ForwardingEnterRef2': objfun.SaleEditMasterList[0]["ForwardingEnterRef2"] ?? "",
        'ForwardingExitRef2': txtExRef2.text,
        'ForwardingEnterRef3': objfun.SaleEditMasterList[0]["ForwardingEnterRef3"] ?? "",
        'ForwardingExitRef3': txtExRef3.text,
        'Forwarding': null,
        'Forwarding2': null,
        'Forwarding3': null,

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