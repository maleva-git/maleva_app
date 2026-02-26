import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '/../MasterSearch/Employee.dart';
import 'package:flutter/material.dart';

part 'package:maleva/Operation/ForwardingSalary/mobileForwardingSalaryUpdate.dart';
part 'package:maleva/Operation/ForwardingSalary/tabletForwardingSalaryUpdate.dart';


class ForwardingSalaryUpdate extends StatefulWidget {

  const ForwardingSalaryUpdate({super.key});

  @override
  ForwardingSalaryUpdateState createState() => ForwardingSalaryUpdateState();
}

GlobalKey appBarKey = GlobalKey();
OverlayEntry? overlayEntry;
bool showsearch = false;

void clearOverlay() {
  if (overlayEntry != null) {
    overlayEntry!.remove();
    overlayEntry = null;
  }
  showsearch = false;
}



class ForwardingSalaryUpdateState extends State<ForwardingSalaryUpdate> with TickerProviderStateMixin {
  String BillType = "0";
  int SealEmpId1 = 0;
  int EditId = 0;
  GlobalKey appBarKey = GlobalKey();
  String UserName = objfun.storagenew.getString('Username') ?? "";
  late TabController _tabController;
  bool progress = false;
  final txtJobNo = TextEditingController();
  final txtSealByEmp1 = TextEditingController();
  final txtExRef1 = TextEditingController();
  final txtExRef2 = TextEditingController();
  final txtBreakByEmp1 = TextEditingController();
  int BreakEmpId1 = 0;
  String previousSearchTerm = '';
  int SaleOrderId = 0;
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    OnlineApi.GetRTINoForwarding(context,int.parse(BillType));
    startup();
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }
  Future startup() async {
    await OnlineApi.SelectEmployee(context, '', 'Operation');

    setState(() {
      progress = true;
    });
    await OnlineApi.loadComboS1(
        context, 0);

  }

  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
    showsearch = false;
  }
  Future<bool> _onBackPressed() async {
    if(overlayEntry != null){
      clearOverlay();
      return false;
    }

    Navigator.of(context).pop();
    return true;
  }
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
        objfun.toastMsg("Enter Correct RTI No", " ", context);
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

  void resetFormFields() {
    txtBreakByEmp1.clear();
    txtSealByEmp1.clear();
    txtExRef1.clear();
    txtExRef2.clear();
    txtJobNo.clear();

    SealEmpId1 = 0;
    BreakEmpId1 = 0;
    SaleOrderId = 0;
    EditId = 0;
  }


  Future<void> UpdateForwarding() async {
    // Step 1: Basic field validation
    if (txtSealByEmp1.text.isEmpty || txtBreakByEmp1.text.isEmpty || txtJobNo.text.isEmpty) {
      objfun.toastMsg('Please fill all required fields', '', context);
      return;
    }

    // Step 2: Confirm before saving
    bool result = await objfun.ConfirmationMsgYesNo(context, "Are you sure to Save?");
    if (!result) return;

    setState(() {
      progress = false; // Show loading spinner
    });

    final int comId = objfun.storagenew.getInt('Comid') ?? 0;

    // Step 3: Prepare body data
    Map<String, dynamic> master ={

          "Id": EditId,
          "CompanyRefId": comId,
          "EmployeeMasterRefId": SealEmpId1,
          "EmployeeMasterRefId1": BreakEmpId1,
          "RTIMasterRefId": SaleOrderId,
          "Salary1": double.tryParse(txtExRef1.text) ?? 0.0,
          "Salary2": double.tryParse(txtExRef2.text) ?? 0.0,

    };

    // Step 4: Header for API
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {

      var resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiInsertForwarding,
        [master],
        header,
        context,
      );

      setState(() {
        progress = true; // Hide spinner
      });

      // Step 6: Handle API response
      if (resultData != null && resultData is Map<String, dynamic>) {
        if (resultData["Result"] == 1 || resultData["IsSuccess"] == true) {
          await objfun.ConfirmationOK('Saved Successfully', context);
          resetFormFields();
        } else {
          objfun.msgshow(
            resultData["Msg"] ?? "Failed to save",
            '',
            Colors.white,
            Colors.red,
            null,
            18.00 - objfun.reducesize,
            objfun.tll,
            objfun.tgc,
            context,
            2,
          );
        }
      } else {
        objfun.msgshow(
          "Invalid response from server",
          '',
          Colors.white,
          Colors.red,
          null,
          18.00 - objfun.reducesize,
          objfun.tll,
          objfun.tgc,
          context,
          2,
        );
      }
    } catch (error, stackTrace) {
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
        2,
      );
    }
  }

Future<void> loaddata() async {
    setState(() {
      progress = false;
    });
    final int comId = objfun.storagenew.getInt('comid') ?? 6;
    Map<String,dynamic> body = {
      "Comid" : comId,
      "RTIMasterRefId" : SaleOrderId,
    };
    Map<String,String> header = {
      "Content-Type": 'application/json;charset=UTF-8',
    };
    try {
      var result = await objfun.apiAllinoneSelectArray(objfun.apiSelectForwarding,body,header,context,);

      setState(() {
        progress = true;
      });
      if(result["IsSuccess"] == true){
        var data = result["Data1"][0];
        txtSealByEmp1.text = data["SealByEmpName"]?.toString() ?? "";

        SealEmpId1 = data["EmployeeMasterRefId"] ?? 0;
        EditId= data["Id"] ;

        if (SealEmpId1 != 0 && SealEmpId1 != null) {
          var sealByEmp = objfun.EmployeeList.firstWhere(
                (item) => item.Id == SealEmpId1,
            orElse: () => EmployeeModel.Empty(),
          );

          txtSealByEmp1.text = sealByEmp.AccountName;
        } else {
          txtSealByEmp1.text = "";
        }

        // txtBreakByEmp1.text = data["BreakByEmpName"]?.toString() ?? "";
        BreakEmpId1 = data["EmployeeMasterRefId1"] ?? 0;

        if (BreakEmpId1 != 0 && BreakEmpId1 != null) {
          var sealByEmp = objfun.EmployeeList.firstWhere(
                (item) => item.Id == BreakEmpId1,
            orElse: () => EmployeeModel.Empty(),
          );

          txtBreakByEmp1.text = sealByEmp.AccountName;
        } else {
          txtBreakByEmp1.text = "";
        }

        txtExRef1.text = data["Salary1"]?.toString() ?? "";
        txtExRef2.text = data["Salary2"]?.toString() ?? "";

      }
      else{
        // objfun.toastMsg("No data found", "", context);

      }


    } catch(e){
      setState(() {
        progress = true;
      });
      // objfun.toastMsg("Failed to load data", "", context);

    }
}

  Widget build(BuildContext context) {
      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;

      return objfun.MalevaScreen == 1
          ? mobiledesign(this, context)
          : tabletdesign(this, context);
  }


}