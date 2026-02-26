import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

part 'package:maleva/Operation/mobileFWSmkUpdate.dart';
part 'package:maleva/Operation/tabletFWSmkUpdate.dart';

class FWSmkUpdate extends StatefulWidget {

  const FWSmkUpdate({super.key});

  @override
  FWSmkUpdateState createState() => FWSmkUpdateState();
}

class FWSmkUpdateState extends State<FWSmkUpdate> with TickerProviderStateMixin{
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";


  late TabController _tabController;

  String? dropdownValueFW1;
  String? dropdownValueFW2;
  String? dropdownValueFW3;
  static const List<String> ForwardingNo = <String>['K1', 'K2', 'K3', 'K8'];

  String BillType = "0";
  int SaleOrderId = 0;
  final txtJobNo = TextEditingController();
  final txtSmkNo = TextEditingController();
  final txtSmkNo2 = TextEditingController();
  final txtSmkNo3 = TextEditingController();
  final txtENRef1 = TextEditingController();
  final txtENRef2 = TextEditingController();
  final txtENRef3 = TextEditingController();
  final txtForwarding1S1 = TextEditingController();
  final txtForwarding1S2 = TextEditingController();
  final txtForwarding2S1 = TextEditingController();
  final txtForwarding2S2 = TextEditingController();
  final txtForwarding3S1 = TextEditingController();
  final txtForwarding3S2 = TextEditingController();

  String dtpFW1date = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFW2date = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpFW3date = DateFormat("yyyy-MM-dd").format(DateTime.now());
  bool checkBoxValueFW1 = false;
  bool checkBoxValueFW2 = false;
  bool checkBoxValueFW3 = false;

  @override
  void initState() {
    OnlineApi.GetJobNoForwarding(context,int.parse(BillType));
    startup();
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    txtJobNo.dispose();
    txtSmkNo.dispose();
    txtSmkNo2.dispose();
    txtSmkNo3.dispose();
    txtENRef1.dispose();
    txtENRef2.dispose();
    txtENRef3.dispose();

    txtForwarding1S1.dispose();
    txtForwarding1S2.dispose();
    txtForwarding2S1.dispose();
    txtForwarding2S2.dispose();
    txtForwarding3S1.dispose();
    txtForwarding3S2.dispose();
    super.dispose();
  }
  Future startup() async {
    setState(() {
      progress = true;
    });
    await OnlineApi.loadComboS1(
        context, 0);

  }
  Future loaddata() async {
    // await OnlineApi.EditSalesOrder(
    //     context, SaleOrderId, int.parse(txtJobNo.text));
    await OnlineApi.EditSalesOrder(
        context, SaleOrderId, 0);

    await OnlineApi.SelectEmployee(context, '', 'Operation');
    dropdownValueFW1 = objfun.SaleEditMasterList[0]["Forwarding"] == "" ? null :objfun.SaleEditMasterList[0]["Forwarding"];
    dropdownValueFW2 = objfun.SaleEditMasterList[0]["Forwarding2"] == "" ? null :objfun.SaleEditMasterList[0]["Forwarding2"];
    dropdownValueFW3 = objfun.SaleEditMasterList[0]["Forwarding3"] == "" ? null : objfun.SaleEditMasterList[0]["Forwarding3"];
    txtSmkNo.text = objfun.SaleEditMasterList[0]["ForwardingSMKNo"] ?? "";
    txtSmkNo2.text = objfun.SaleEditMasterList[0]["ForwardingSMKNo2"] ?? "";
    txtSmkNo3.text = objfun.SaleEditMasterList[0]["ForwardingSMKNo3"] ?? "";
    txtENRef1.text = objfun.SaleEditMasterList[0]["ForwardingEnterRef"] ?? "";
    txtENRef2.text = objfun.SaleEditMasterList[0]["ForwardingEnterRef2"] ?? "";
    txtENRef3.text = objfun.SaleEditMasterList[0]["ForwardingEnterRef3"] ?? "";
    txtForwarding1S1.text = objfun.SaleEditMasterList[0]["Forwarding1S1"] ?? "";
    txtForwarding1S2.text = objfun.SaleEditMasterList[0]["Forwarding1S2"] ?? "";
    txtForwarding2S1.text = objfun.SaleEditMasterList[0]["Forwarding2S1"] ?? "";
    txtForwarding2S2.text = objfun.SaleEditMasterList[0]["Forwarding2S2"] ?? "";
    txtForwarding3S1.text = objfun.SaleEditMasterList[0]["Forwarding3S1"] ?? "";
    txtForwarding3S2.text = objfun.SaleEditMasterList[0]["Forwarding3S2"] ?? "";

    if (objfun.SaleEditMasterList[0]["ForwardingDate"] != null) {
      checkBoxValueFW1 = true;
      var FwDate = DateTime.parse(objfun.SaleEditMasterList[0]["ForwardingDate"].toString());
      dtpFW1date = DateFormat("yyyy-MM-dd").format(FwDate);
    }
    else{
      checkBoxValueFW1 = false;
    }
    if (objfun.SaleEditMasterList[0]["Forwarding2Date"] != null) {
      checkBoxValueFW2 = true;
      var FwDate = DateTime.parse(objfun.SaleEditMasterList[0]["Forwarding2Date"].toString());
      dtpFW2date = DateFormat("yyyy-MM-dd").format(FwDate);
    }
    else{
      checkBoxValueFW2 = false;
    }
    if (objfun.SaleEditMasterList[0]["Forwarding3Date"] != null) {
      checkBoxValueFW3 = true;
      var FwDate = DateTime.parse(objfun.SaleEditMasterList[0]["Forwarding3Date"].toString());
      dtpFW3date = DateFormat("yyyy-MM-dd").format(FwDate);
    }
    else{
      checkBoxValueFW3 = false;
    }
    setState(() {
      progress = true;
    });
  }

  void clear() {
    BillType = "0";
    SaleOrderId = 0;

    txtJobNo.text = "";
    txtSmkNo.text = "";
    txtSmkNo2.text = "";
    txtSmkNo3.text = "";
    txtENRef1.text = "";
    txtENRef2.text = "";
    txtENRef3.text = "";

    txtForwarding1S1.text = "";
    txtForwarding1S2.text = "";
    txtForwarding2S1.text = "";
    txtForwarding2S2.text = "";
    txtForwarding3S1.text = "";
    txtForwarding3S2.text = "";
    dropdownValueFW1 = null;
    dropdownValueFW2 = null;
    dropdownValueFW3 = null;
    dtpFW1date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    dtpFW2date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    dtpFW3date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    checkBoxValueFW1 = false;
    checkBoxValueFW2 = false;
    checkBoxValueFW3 = false;
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
            ?appBarBox!.size.height + height * 0.12 + 10 :appBarBox!.size.height + height * 0.18 + 10,
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
              letterSpacing: 0.3),
        ),
          child:
          SizedBox(height: 350, child: ListView(children: suggestions))),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }
  void autoCompleteSearchS1(String place, bool show ,int type) async {

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
        if(type==1){
          predictions = objfun.ComboS1List[0]['Forwarding1S1'];
        }
        else  if(type==2){
          predictions = objfun.ComboS1List[1]['Forwarding1S2'];
        }
        else  if(type==3){
          predictions = objfun.ComboS1List[2]['Forwarding2S1'];
        }
        else  if(type==4){
          predictions = objfun.ComboS1List[3]['Forwarding2S2'];
        }
        else  if(type==5){
          predictions = objfun.ComboS1List[4]['Forwarding3S1'];
        }
        else  if(type==6){
          predictions = objfun.ComboS1List[5]['Forwarding3S2'];
        }


      } else {
        if(type==1){
          predictions =  objfun.ComboS1List[0]
              .where((element) =>
              element['Forwarding1S1'].toString().contains(place))
              .toList();
        }
        else  if(type==2){
          predictions =  objfun.ComboS1List[1]
              .where((element) =>
              element['Forwarding1S2'].toString().contains(place))
              .toList();
        }
        else  if(type==3){
          predictions =  objfun.ComboS1List[2]
              .where((element) =>
              element['Forwarding2S1'].toString().contains(place))
              .toList();
        }
        else  if(type==4){
          predictions =  objfun.ComboS1List[3]
              .where((element) =>
              element['Forwarding2S2'].toString().contains(place))
              .toList();
        }
        else  if(type==5){
          predictions =  objfun.ComboS1List[4]
              .where((element) =>
              element['Forwarding3S1'].toString().contains(place))
              .toList();
        }
        else  if(type==6){
          predictions =  objfun.ComboS1List[5]
              .where((element) =>
              element['Forwarding3S2'].toString().contains(place))
              .toList();
        }

      }
      if (predictions.isNotEmpty) {
        for (int i = 0; i < predictions.length; i++) {
          suggestions.add(InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child:
          Text(
        type ==1  ?
              predictions[i]['Forwarding1S1'].toString():
        type ==2 ?
              predictions[i]['Forwarding1S2'].toString():
        type ==3 ?
               predictions[i]['Forwarding2S1'].toString():
        type ==4 ?
               predictions[i]['Forwarding2S2'].toString():
        type ==5 ?
        predictions[i]['Forwarding3S1'].toString():
        predictions[i]['Forwarding3S2'].toString()
          ) ,


            ),
            onTap: () async {
              if (type ==1){
                txtForwarding1S1.text = predictions[i]['Forwarding1S1'].toString();

               }
              else if (type ==2){
                txtForwarding1S2.text = predictions[i]['Forwarding1S2'].toString();

              }
              else if (type ==3){
                txtForwarding2S1.text = predictions[i]['Forwarding2S1'].toString();

              }
              else if (type ==4){
                txtForwarding2S2.text = predictions[i]['Forwarding2S2'].toString();

              }
              else if (type ==5){
                txtForwarding3S1.text = predictions[i]['Forwarding3S1'].toString();

              }
              else if (type ==6){
                txtForwarding3S2.text = predictions[i]['Forwarding3S2'].toString();

              }

              FocusScope.of(context).requestFocus(FocusNode());
              loaddata();

              clearOverlay();
            },
          ));
        }
      }
      if(suggestions.isEmpty){
       // objfun.toastMsg("Enter Correct Job No", " ", context);
        return;
      }
      displayAutoCompleteSuggestionsS1(suggestions,context,type);
    } finally {}
  }

  void displayAutoCompleteSuggestionsS1(List<Widget> suggestions,context,type) {

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
            ?type == 1 || type == 2?
        appBarBox!.size.height + height * 0.33 + 100 :
        appBarBox!.size.height + height * 0.22 + 100
            :appBarBox!.size.height + height * 0.18 + 10,
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
              letterSpacing: 0.3),
        ),
          child:
          SizedBox(height: 350, child: ListView(children: suggestions))),
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
    if (dropdownValueFW1 == null && dropdownValueFW2 == null && dropdownValueFW3 == null ) {
      objfun.toastMsg('Select FW', '', context);
      return;
    }
    if (txtJobNo.text.isEmpty) {
      objfun.toastMsg('Enter Job No', '', context);
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
        'Jobid' : txtJobNo.text,
        'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'ForwardingSMKNo': txtSmkNo.text,
        'ForwardingSMKNo2': txtSmkNo2.text,
        'ForwardingSMKNo3': txtSmkNo3.text,
        'Forwarding': dropdownValueFW1,
        'Forwarding2': dropdownValueFW2,
        'Forwarding3': dropdownValueFW3,
        'ForwardingEnterRef': txtENRef1.text,
        'ForwardingEnterRef2': txtENRef2.text,
        'ForwardingEnterRef3': txtENRef3.text,
        'Forwarding1S1': txtForwarding1S1.text,
        'Forwarding1S2': txtForwarding1S2.text,
        'Forwarding2S1': txtForwarding2S1.text,
        'Forwarding2S2': txtForwarding2S2.text,
        'Forwarding3S1': txtForwarding3S1.text,
        'Forwarding3S2': txtForwarding3S2.text,
        'ForwardingDate' :checkBoxValueFW1 == true ? DateTime.parse(dtpFW1date).toIso8601String() : null ,
        'Forwarding2Date' :checkBoxValueFW2 == true ? DateTime.parse(dtpFW2date).toIso8601String() : null ,
        'Forwarding3Date' :checkBoxValueFW3 == true ? DateTime.parse(dtpFW3date).toIso8601String() : null ,
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