import 'dart:async';

import 'dart:io';
import '../../MasterSearch/Location.dart';
import 'package:maleva/MasterSearch/JobAllStatus.dart';
import 'package:maleva/MasterSearch/JobType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/Transaction/SaleOrder/SalesOrderView.dart';

import '../../MasterSearch/AddressList.dart';
import '../../MasterSearch/Agent.dart';
import '../../MasterSearch/AgentCompany.dart';
import '../../MasterSearch/CargoStatus.dart';
import '../../MasterSearch/CommodityType.dart';
import '../../MasterSearch/Customer.dart';
import '../../MasterSearch/Employee.dart';
import '../../MasterSearch/Port.dart';
import '../../MasterSearch/Product.dart';
import '../../MasterSearch/VesselType.dart';

part 'package:maleva/Transaction/SaleOrder/mobileSalesOrderAdd.dart';
part 'package:maleva/Transaction/SaleOrder/tabletSalesOrderAdd.dart';

class SalesOrderAdd extends StatefulWidget {
  final List<SaleEditDetailModel>? SaleDetails;
  final List<dynamic>? SaleMaster;
  //final List<SaleEditMasterModel>? SaleMaster;
  const SalesOrderAdd({super.key, this.SaleDetails, this.SaleMaster});

  @override
  SalesOrderAddState createState() => SalesOrderAddState();
}

class SalesOrderAddState extends State<SalesOrderAdd>
    with TickerProviderStateMixin {


  Map<String, bool> fieldPermission = {};

  bool progress = false;
  late MenuMasterModel menuControl;
  String dtpDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  final FocusNode _focusQty = FocusNode();
  final FocusNode _focusSaleRate = FocusNode();
  final FocusNode _focusGst = FocusNode();
  static var txtkey = TextEditingController();

  String dtpSaleOrderdate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String dtpOETAdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpOETBdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpOETDdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpLETAdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpFlightTimedate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpLETBdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpLETDdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpPickUpdate =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpDeliverydate =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpWHEntrydate =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpWHExitdate =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  final format = DateFormat("yyyy-MM-dd HH:mm");
  late DateTime _selectedDateTime;
  final txtForwarding1S1 = TextEditingController();
  final txtForwarding1S2 = TextEditingController();
  final txtForwarding2S1 = TextEditingController();
  final txtForwarding2S2 = TextEditingController();
  final txtForwarding3S1 = TextEditingController();
  final txtForwarding3S2 = TextEditingController();

  final txtRemarks = TextEditingController();
  final txtDoDescription = TextEditingController();
  final txtJobNo = TextEditingController();
  final txtCustomer = TextEditingController();
  final txtJobType = TextEditingController();
  final txtJobStatus = TextEditingController();

  final txtWeight = TextEditingController();
  final txtQuantity = TextEditingController();
  final txtTruckSize = TextEditingController();
  final txtAWBNo = TextEditingController();
  final txtBLCopy = TextEditingController();
  final txtPTWNo = TextEditingController();
  final txtCommodityType = TextEditingController();
  final txtCargo = TextEditingController();

  final txtLAgentCompany = TextEditingController();
  final txtLAgentName = TextEditingController();
  final txtLoadingVessel = TextEditingController();
  final txtLSCN = TextEditingController();
  final txtLVesselType = TextEditingController();
  final txtLPort = TextEditingController();

  final txtOAgentCompany = TextEditingController();
  final txtOAgentName = TextEditingController();
  final txtOffVessel = TextEditingController();
  final txtOSCN = TextEditingController();
  final txtOVesselType = TextEditingController();
  final txtOPort = TextEditingController();

  final txtPickUpAddress = TextEditingController();
  final txtPickUpQuantity = TextEditingController();
  final txtDeliveryAddress = TextEditingController();
  final txtDeliveryQuantity = TextEditingController();
  final txtWarehouseAddress = TextEditingController();
  final txtOrigin = TextEditingController();
  final txtDestination = TextEditingController();

  final txtProductCode = TextEditingController();
  final txtProductDescription = TextEditingController();
  final txtProductQty = TextEditingController();
  final txtProductSaleRate = TextEditingController();
  final txtProductGst = TextEditingController();
  final txtProductAmount = TextEditingController();
  final txtProductId = TextEditingController();
  final txtProductLandingCost = TextEditingController();
  final txtProductPurchaseRate = TextEditingController();
  final txtProductMRP = TextEditingController();
  final txtProductNetSalesRate = TextEditingController();
  final txtProductDiscPer = TextEditingController();
  final txtProductDiscAmount = TextEditingController();
  final txtProductGSTAmount = TextEditingController();
  final txtProductUOM = TextEditingController();
  final txtProductSDId = TextEditingController();
  final txtProductActualAmount = TextEditingController();
  final txtProductCurrencyValue = TextEditingController();
  final txtSaleOrderMasterRefId = TextEditingController();
  final txtItemMasterRefId = TextEditingController();

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
  final txtZB1 = TextEditingController();
  final txtZB2 = TextEditingController();
  final txtZBRef1 = TextEditingController();
  final txtZBRef2 = TextEditingController();
  final txtBoardingOfficer1 = TextEditingController();
  final txtBoardingOfficer2 = TextEditingController();
  final txtAmount1 = TextEditingController();
  final txtAmount2 = TextEditingController();
  final txtPortChargeRef1 = TextEditingController();
  final txtPortCharges = TextEditingController();

  bool checkBoxValueOETA = false;
  bool checkBoxValueOETB = false;
  bool checkBoxValueOETD = false;
  bool checkBoxValueLETA = false;
  bool checkBoxValueFlightTime = false;
  bool checkBoxValueLETB = false;
  bool checkBoxValueLETD = false;
  bool checkBoxValuePickUp = false;
  bool checkBoxValueDelivery = false;
  bool checkBoxValueWHEntry = false;
  bool checkBoxValueWHExit = false;

  bool VisibleOffVessel = true;
  bool VisibleLoadingVessel = true;
  bool VisibleLETA = true;
  bool VisibleFlightTime = true;
  bool VisibleLETB = true;
  bool VisibleLETD = true;
  bool VisibleAWBNo = true;
  bool VisibleBLCopy = true;
  bool VisibleFORKLIFT = true;
  bool VisibleSealBy = true;
  bool VisibleBreakSealBy = true;
  bool VisibleFORWARDING = true;
  bool VisibleOrigin = true;
  bool VisibleDestination = true;
  bool VisibleZB = true;
  bool VisibleOETA = true;
  bool VisibleOETB = true;
  bool VisibleOETD = true;
  bool VisibleOShippingAgent = true;
  bool VisibleOAgentName = true;
  bool VisibleOScn = true;
  bool VisibleLScn = true;
  bool VisibleLShippingAgent = true;
  bool VisibleLAgentName = true;
  bool VisibleLVesselType = true;
  bool VisibleOVesselType = true;
  bool VisibleOPort = true;
  bool VisibleLPort = true;
  bool VisibleProductview = false;
  bool VisibleFW1 = false;
  bool VisibleFW2 = false;
  bool VisibleFW3 = false;
  bool VisibleGC = false;

  bool DisabledBillType = false;
  bool DisabledAmount1 = false;
  bool DisabledAmount2 = false;

  int CustId = 0;
  int StatusId = 0;
  int JobTypeId = 0;
  int AgentCompanyId = 0;
  int AgentId = 0;
  int LAgentCompanyId = 0;
  int LAgentId = 0;
  int LVesselTypeId = 0;
  int LPortId = 0;
  int OAgentCompanyId = 0;
  int OAgentId = 0;
  int OVesselTypeId = 0;
  int OPortId = 0;
  int SealEmpId1 = 0;
  int SealEmpId2 = 0;
  int SealEmpId3 = 0;
  int BreakEmpId1 = 0;
  int BreakEmpId2 = 0;
  int BreakEmpId3 = 0;
  int BoardOfficerId1 = 0;
  int BoardOfficerId2 = 0;
  int Originid = 0;
  int Destinationid = 0;
  int EditId = 0;
  int EnquiryId = 0;
  var Coinage = 0.0;
  double TotalAmount = 0.00;
  double TaxAmount = 0.0;
  double CurrencyValue = 0.0;
  double ActualAmount = 0.0;
  String UserName = objfun.storagenew.getString('Username') ?? "";

  int? ProductUpdateIndex;
  TimeOfDay? selectedTime;
  late final formattedTime;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  TimeOfDay? selectedTimeETA;
  late final formattedETATime;
  TextDirection textDirection = TextDirection.LTR;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = false;
  Orientation? orientation;
  TimeOfDay SelectedTime = TimeOfDay.now();

  var ETADatetxt = "";
  var ETATimetxt = "";

  bool _isTextFieldEnabled = false;
  final ListItem _selectedItemCustomer = ListItem(0, 'EMPTY');
  List<DropdownMenuItem<ListItem>> dropdownMenuCustomer = [];
  final ListItem _selectedItemJobType = ListItem(0, 'EMPTY');
  List<DropdownMenuItem<ListItem>> dropdownMenuJobType = [];
  final ListItem _selectedItemAllJobStatus = ListItem(0, 'EMPTY');
  List<DropdownMenuItem<ListItem>> dropdownMenuAllJobStatus = [];
  String dropdownValue = BillType.first;
  List<SaleEditDetailModel> ProductViewList = [];
  List<dynamic> PickUpAddressList = [];
  List<dynamic> PickUpQuantityList = [];
  List<dynamic> DeliveryAddressList = [];
  List<dynamic> DeliveryQuantityList = [];

  String dtpFW1date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpFW2date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpFW3date = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  bool checkBoxValueFW1 = false;
  bool checkBoxValueFW2 = false;
  bool checkBoxValueFW3 = false;

  String? dropdownValueTruckSize;
  String? dropdownValueFW1;
  String? dropdownValueFW2;
  String? dropdownValueFW3;
  String? dropdownValueZB2;
  String? dropdownValueZB1;
  List<dynamic> _filteredAddress = [];

  static const List<String> BillType = <String>['MY', 'TR'];
  static const List<String> ForwardingNo = <String>['K1', 'K2', 'K3', 'K8'];
  static const List<String> TruckSizeList = <String>['1 Tonner', '3 Tonner', '5 Tonner', '10 Tonner', '40 FT Truck'];
  static const List<String> ZBNo = <String>['ZB1', 'ZB2'];

  late TabController _tabController;




  @override
  void initState() {
    startup();
    super.initState();
    _tabController = TabController(vsync: this, length: 6);

  }

  @override
  void dispose() {
    _focusQty.dispose();
    _focusSaleRate.dispose();
    _focusGst.dispose();
    txtRemarks.dispose();
    txtQuantity.dispose();
    txtTruckSize.dispose();
    txtAWBNo.dispose();
    txtBLCopy.dispose();
    txtPTWNo.dispose();
    txtCommodityType.dispose();
    txtCargo.dispose();
    txtLAgentCompany.dispose();
    txtLAgentName.dispose();
    txtLoadingVessel.dispose();
    txtLSCN.dispose();
    txtLVesselType.dispose();
    txtLPort.dispose();
    txtOAgentCompany.dispose();
    txtOAgentName.dispose();
    txtOffVessel.dispose();
    txtOSCN.dispose();
    txtOVesselType.dispose();
    txtOPort.dispose();
    txtPickUpAddress.dispose();
    txtDeliveryAddress.dispose();
    txtWarehouseAddress.dispose();
    txtOrigin.dispose();
    txtDestination.dispose();
    txtProductCode.dispose();
    txtProductDescription.dispose();
    txtProductQty.dispose();
    txtProductSaleRate.dispose();
    txtProductGst.dispose();
    txtProductAmount.dispose();
    txtProductId.dispose();
    txtProductLandingCost.dispose();
    txtProductPurchaseRate.dispose();
    txtProductMRP.dispose();
    txtProductNetSalesRate.dispose();
    txtProductDiscPer.dispose();
    txtProductDiscAmount.dispose();
    txtProductGSTAmount.dispose();
    txtProductUOM.dispose();
    txtProductActualAmount.dispose();
    txtProductCurrencyValue.dispose();
    txtProductSDId.dispose();
    txtSaleOrderMasterRefId.dispose();
    txtItemMasterRefId.dispose();
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
    txtSmk1.dispose();
    txtSmk2.dispose();
    txtSmk3.dispose();
    txtZB1.dispose();
    txtZB2.dispose();
    txtZBRef1.dispose();
    txtZBRef2.dispose();
    txtBoardingOfficer1.dispose();
    txtBoardingOfficer2.dispose();
    txtAmount1.dispose();
    txtAmount2.dispose();
    txtPortChargeRef1.dispose();
    txtPortCharges.dispose();
    txtForwarding1S1.dispose();
    txtForwarding1S2.dispose();
    txtForwarding2S1.dispose();
    txtForwarding2S2.dispose();
    txtForwarding3S1.dispose();
    txtForwarding3S2.dispose();

    super.dispose();
  }

  void keypress(String key) {
    if (_focusQty.hasFocus == true) {
      txtkey = txtProductQty;
    } else if (_focusSaleRate.hasFocus == true) {
      txtkey = txtProductSaleRate;
    } else if (_focusGst.hasFocus == true) {
      txtkey = txtProductGst;
    }
    if (key == '1') {
      txtkey.text = '${txtkey.text}1';
    } else if (key == '2') {
      txtkey.text = '${txtkey.text}2';
    } else if (key == '3') {
      txtkey.text = '${txtkey.text}3';
    } else if (key == '4') {
      txtkey.text = '${txtkey.text}4';
    } else if (key == '5') {
      txtkey.text = '${txtkey.text}5';
    } else if (key == '6') {
      txtkey.text = '${txtkey.text}6';
    } else if (key == '7') {
      txtkey.text = '${txtkey.text}7';
    } else if (key == '8') {
      txtkey.text = '${txtkey.text}8';
    } else if (key == '9') {
      txtkey.text = '${txtkey.text}9';
    } else if (key == '0') {
      txtkey.text = '${txtkey.text}0';
    } else if (key == '.') {
      txtkey.text = '${txtkey.text}.';
    } else if (key == 'C') {
      txtkey.text = txtkey.text
          .replaceRange(txtkey.text.length - 1, txtkey.text.length, '')
          .trim();
    } else if (key == 'CLEAR') {
      txtkey.text = '';
    }
    Calculation();
  }

  Future startup() async {
    await OnlineApi.MaxSaleOrderNo(context, dropdownValue);
    await OnlineApi.SelectAddressList(context);
    await OnlineApi.SelectAgentCompany(context);
    await OnlineApi.SelectEmployee(context, '', 'Operation');
    applySpecialUserRights();
    setState(() {
      _filteredAddress = objfun.AddressList;
      txtJobNo.text = objfun.MaxSaleOrderNum;
      progress = true;
    });
   var chkEnq = objfun.storagenew.getString('EnquiryOpen');
   if(chkEnq == "false"){
     loaddata();
   }
   else{
     loadEnqdata();
     objfun.storagenew.setString('EnquiryOpen',"false");
   }

  }
  bool showsearch = false;
  OverlayEntry? overlayEntry;
  String previousSearchTerm = '';
  GlobalKey appBarKey = GlobalKey();
  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
    showsearch = false;
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
  Future loaddata() async {
    if (widget.SaleDetails != null && widget.SaleDetails!.isNotEmpty) {
      ProductViewList = widget.SaleDetails!;
    }
    if (widget.SaleMaster != null && widget.SaleMaster!.isNotEmpty) {
      await OnlineApi.SelectCustomer(context);
      await OnlineApi.SelectJobType(context);
      await OnlineApi.SelectAllJobStatus(
          context, widget.SaleMaster![0]["JobMasterRefId"]);
      await OnlineApi.SelectAgentAll(
          context, widget.SaleMaster![0]["AgentCompanyRefId"]);
      await OnlineApi.loadCustomerCurrency(
          context, widget.SaleMaster![0]["CustomerRefId"]);
      CurrencyValue = objfun.CustomerCurrencyValue;
      EditId = widget.SaleMaster![0]["Id"];
      Originid = widget.SaleMaster![0]["OriginRefId"] ?? 0;
      Destinationid = widget.SaleMaster![0]["DestinationRefId"] ?? 0;
      EnquiryId = 0;
      if (widget.SaleMaster![0]["OAgentCompanyRefId"] != 0 &&
          widget.SaleMaster![0]["OAgentCompanyRefId"] != null) {
        AgentCompanyId = widget.SaleMaster![0]["OAgentCompanyRefId"];
        var AgentCompany = objfun.AgentCompanyList.where((item) =>
            item.Id == widget.SaleMaster![0]["OAgentCompanyRefId"]).toList();
        txtOAgentCompany.text = AgentCompany[0].Name;
      }
      if (widget.SaleMaster![0]["OAgentMasterRefId"] != 0 &&
          widget.SaleMaster![0]["OAgentMasterRefId"] != null) {
        AgentId = widget.SaleMaster![0]["OAgentMasterRefId"];
        var AgentName = objfun.AgentAllList.where(
                (item) => item.Id == widget.SaleMaster![0]["OAgentMasterRefId"])
            .toList();
        txtOAgentName.text = AgentName[0].AgentName;
      }
      if (widget.SaleMaster![0]["AgentCompanyRefId"] != 0 &&
          widget.SaleMaster![0]["AgentCompanyRefId"] != null) {
        LAgentCompanyId = widget.SaleMaster![0]["AgentCompanyRefId"];
        var LAgentCompany = objfun.AgentCompanyList.where(
                (item) => item.Id == widget.SaleMaster![0]["AgentCompanyRefId"])
            .toList();
        txtLAgentCompany.text = LAgentCompany[0].Name;
      }
      if (widget.SaleMaster![0]["AgentMasterRefId"] != 0 &&
          widget.SaleMaster![0]["AgentMasterRefId"] != null) {
        LAgentId = widget.SaleMaster![0]["AgentMasterRefId"];
        var LAgentName = objfun.AgentAllList.where(
                (item) => item.Id == widget.SaleMaster![0]["AgentMasterRefId"])
            .toList();
        txtLAgentName.text = LAgentName[0].AgentName;
      }
      if (widget.SaleMaster![0]["CustomerRefId"] != 0 &&
          widget.SaleMaster![0]["CustomerRefId"] != null) {
        CustId = widget.SaleMaster![0]["CustomerRefId"];
        var CustomerName = objfun.CustomerList.where(
                (item) => item.Id == widget.SaleMaster![0]["CustomerRefId"]).toList();
        txtCustomer.text = CustomerName[0].AccountName;
      }
      if (widget.SaleMaster![0]["JobMasterRefId"] != 0 &&
          widget.SaleMaster![0]["JobMasterRefId"] != null) {
        JobTypeId = widget.SaleMaster![0]["JobMasterRefId"];
        var JobType = objfun.JobTypeList.where(
                (item) => item.Id == widget.SaleMaster![0]["JobMasterRefId"])
            .toList();
        txtJobType.text = JobType[0].Name;
      }

      var SaleDate =
          DateTime.parse(widget.SaleMaster![0]["SaleDate"].toString());
      dtpSaleOrderdate = DateFormat("yyyy-MM-dd").format(SaleDate);
      txtDoDescription.text = widget.SaleMaster![0]["DODescription"] ?? "";
      txtTruckSize.text = widget.SaleMaster![0]["TruckSize"] != null ? widget.SaleMaster![0]["TruckSize"].toString() : "";
      dropdownValue = widget.SaleMaster![0]["BillType"];
      txtJobNo.text = widget.SaleMaster![0]["CNumber"] != null ? widget.SaleMaster![0]["CNumber"].toString() : "";
      Coinage = widget.SaleMaster![0]["Coinage"];
      TaxAmount = widget.SaleMaster![0]["TaxAmount"];
     // CurrencyValue = widget.SaleMaster![0]["CurrencyValue"];
      ActualAmount = widget.SaleMaster![0]["ActualNetAmount"];
      txtRemarks.text = widget.SaleMaster![0]["Remarks"] ?? "";
      txtOffVessel.text = widget.SaleMaster![0]["Offvesselname"] ?? "";
      txtLoadingVessel.text = widget.SaleMaster![0]["Loadingvesselname"] ?? "";
      txtLPort.text = widget.SaleMaster![0]["SPort"] ?? " ";
      txtOPort.text = widget.SaleMaster![0]["OPort"] ?? " ";
      txtSmk1.text = widget.SaleMaster![0]["ForwardingSMKNo"] ?? "";
      txtSmk2.text = widget.SaleMaster![0]["ForwardingSMKNo2"] ?? "";
      txtSmk3.text = widget.SaleMaster![0]["ForwardingSMKNo3"] ?? "";
      if (widget.SaleMaster![0]["ETA"] != null) {
        checkBoxValueLETA = true;
        var ETADate = DateTime.parse(widget.SaleMaster![0]["ETA"].toString());

        dtpLETAdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(ETADate);
      }
      if (widget.SaleMaster![0]["FlighTime"] != null) {
        checkBoxValueFlightTime = true;
        var FlightTimeDate = DateTime.parse(widget.SaleMaster![0]["FlighTime"].toString());

        dtpFlightTimedate = DateFormat("yyyy-MM-dd HH:mm:ss").format(FlightTimeDate);
      }
      if (widget.SaleMaster![0]["ETB"] != null) {
        checkBoxValueLETB = true;
        var ETBDate = DateTime.parse(widget.SaleMaster![0]["ETB"].toString());

        dtpLETBdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(ETBDate);
      }
      if (widget.SaleMaster![0]["ETD"] != null) {
        checkBoxValueLETD = true;
        var ETDDate = DateTime.parse(widget.SaleMaster![0]["ETD"].toString());

        dtpLETDdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(ETDDate);
      }
      if (widget.SaleMaster![0]["OETA"] != null) {
        checkBoxValueOETA = true;
        var OETADate = DateTime.parse(widget.SaleMaster![0]["OETA"].toString());

        dtpOETAdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(OETADate);
      }
      if (widget.SaleMaster![0]["OETB"] != null) {
        checkBoxValueOETB = true;
        var OETBDate = DateTime.parse(widget.SaleMaster![0]["OETB"].toString());

        dtpOETBdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(OETBDate);
      }
      if (widget.SaleMaster![0]["OETD"] != null) {
        checkBoxValueOETD = true;
        var OETDDate = DateTime.parse(widget.SaleMaster![0]["OETD"].toString());

        dtpOETDdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(OETDDate);
      }
      if (widget.SaleMaster![0]["ForwardingDate"] != null) {
        checkBoxValueFW1 = true;
        var FwDate = DateTime.parse(widget.SaleMaster![0]["ForwardingDate"].toString());
        dtpFW1date = DateFormat("yyyy-MM-dd HH:mm:ss").format(FwDate);
      }
      else{
        checkBoxValueFW1 = false;
      }
      if (widget.SaleMaster![0]["Forwarding2Date"] != null) {
        checkBoxValueFW2 = true;
        var FwDate = DateTime.parse(widget.SaleMaster![0]["Forwarding2Date"].toString());
        dtpFW2date = DateFormat("yyyy-MM-dd HH:mm:ss").format(FwDate);
      }
      else{
        checkBoxValueFW2 = false;
      }
      if (widget.SaleMaster![0]["Forwarding3Date"] != null) {
        checkBoxValueFW3 = true;
        var FwDate = DateTime.parse(widget.SaleMaster![0]["Forwarding3Date"].toString());
        dtpFW3date = DateFormat("yyyy-MM-dd HH:mm:ss").format(FwDate);
      }
      else{
        checkBoxValueFW3 = false;
      }

      txtAWBNo.text = widget.SaleMaster![0]["AWBNo"] ?? "";
      txtBLCopy.text = widget.SaleMaster![0]["BLCopy"] ?? "";
      txtOSCN.text = widget.SaleMaster![0]["SCN"] ?? "";
      txtLVesselType.text = widget.SaleMaster![0]["Vessel"] ?? "";
      txtOVesselType.text = widget.SaleMaster![0]["OVessel"] ?? "";
      txtCommodityType.text = widget.SaleMaster![0]["Commodity"] ?? "";
      txtWeight.text = widget.SaleMaster![0]["TotalWeight"] != null ? widget.SaleMaster![0]["TotalWeight"].toString() : "";
      txtQuantity.text = widget.SaleMaster![0]["Quantity"] != null ? widget.SaleMaster![0]["Quantity"].toString() : "";
      Originid = widget.SaleMaster![0]["OriginRefId"] ?? 0;
      Destinationid = widget.SaleMaster![0]["DestinationRefId"] ?? 0;
      if (widget.SaleMaster![0]["JStatus"] != 0 &&
          widget.SaleMaster![0]["JStatus"] != null) {
        StatusId = widget.SaleMaster![0]["JStatus"];
        var JobStatus = objfun.JobAllStatusList.where(
            (item) => item.Status == widget.SaleMaster![0]["JStatus"]).toList();
        txtJobStatus.text = JobStatus[0].StatusName;
      }
      if (widget.SaleMaster![0]["SealbyRefid"] != 0 &&
          widget.SaleMaster![0]["SealbyRefid"] != null) {
        SealEmpId1 = widget.SaleMaster![0]["SealbyRefid"];
        var SealByEmp1 = objfun.EmployeeList.where(
            (item) => item.Id == widget.SaleMaster![0]["SealbyRefid"]).toList();
        txtSealByEmp1.text = SealByEmp1[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbreakbyRefid"] != 0 &&
          widget.SaleMaster![0]["SealbreakbyRefid"] != null) {
        BreakEmpId1 = widget.SaleMaster![0]["SealbreakbyRefid"];
        var BreakByEmp1 = objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbreakbyRefid"])
            .toList();
        txtBreakByEmp1.text = BreakByEmp1[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbyRefid2"] != 0 &&
          widget.SaleMaster![0]["SealbyRefid2"] != null) {
        SealEmpId2 = widget.SaleMaster![0]["SealbyRefid2"];
        var SealByEmp2 = objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbyRefid2"]).toList();
        txtSealByEmp2.text = SealByEmp2[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbreakbyRefid2"] != 0 &&
          widget.SaleMaster![0]["SealbreakbyRefid2"] != null) {
        BreakEmpId2 = widget.SaleMaster![0]["SealbreakbyRefid2"];
        var BreakByEmp2 = objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbreakbyRefid2"])
            .toList();
        txtBreakByEmp2.text = BreakByEmp2[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbyRefid3"] != 0 &&
          widget.SaleMaster![0]["SealbyRefid3"] != null) {
        SealEmpId3 = widget.SaleMaster![0]["SealbyRefid3"];
        var SealByEmp3 = objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbyRefid3"]).toList();
        txtSealByEmp3.text = SealByEmp3[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbreakbyRefid3"] != 0 &&
          widget.SaleMaster![0]["SealbreakbyRefid3"] != null) {
        BreakEmpId3 = widget.SaleMaster![0]["SealbreakbyRefid3"];
        var BreakByEmp3= objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbreakbyRefid3"])
            .toList();
        txtBreakByEmp3.text = BreakByEmp3[0].AccountName;
      }
      if (widget.SaleMaster![0]["PickupDate"] != null) {
        checkBoxValuePickUp = true;
        var PickUpDate =
            DateTime.parse(widget.SaleMaster![0]["PickupDate"].toString());

        dtpPickUpdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(PickUpDate);
      }

      if (widget.SaleMaster![0]["DeliveryDate"] != null) {
        checkBoxValueDelivery = true;
        var DeliveryDate =
            DateTime.parse(widget.SaleMaster![0]["DeliveryDate"].toString());

        dtpDeliverydate =
            DateFormat("yyyy-MM-dd HH:mm:ss").format(DeliveryDate);
      }
      if (widget.SaleMaster![0]["WareHouseEnterDate"] != null) {
        checkBoxValueWHEntry = true;
        var WHEntryDate = DateTime.parse(
            widget.SaleMaster![0]["WareHouseEnterDate"].toString());

        dtpWHEntrydate = DateFormat("yyyy-MM-dd HH:mm:ss").format(WHEntryDate);
      }
      if (widget.SaleMaster![0]["WareHouseExitDate"] != null) {
        checkBoxValueWHExit = true;
        var WHExitDate = DateTime.parse(
            widget.SaleMaster![0]["WareHouseExitDate"].toString());

        dtpWHExitdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(WHExitDate);
      }

      if (widget.SaleMaster![0]["PickupAddress"].contains('{@}')) {
        PickUpAddressList = widget.SaleMaster![0]["PickupAddress"].split('{@}');
        txtPickUpAddress.text = PickUpAddressList[0];
      } else {
        txtPickUpAddress.text = widget.SaleMaster![0]["PickupAddress"];
      }

      if (widget.SaleMaster![0]["pickupQuantityList"].contains('{@}')) {
        PickUpQuantityList = widget.SaleMaster![0]["pickupQuantityList"].split('{@}');
        txtPickUpQuantity.text = PickUpQuantityList[0];
      } else {
        txtPickUpQuantity.text = widget.SaleMaster![0]["pickupQuantityList"];
      }

      if (widget.SaleMaster![0]["DeliveryAddress"].contains('{@}')) {
        DeliveryAddressList =
            widget.SaleMaster![0]["DeliveryAddress"].split('{@}');
        txtDeliveryAddress.text = DeliveryAddressList[0];
      } else {
        txtDeliveryAddress.text = widget.SaleMaster![0]["DeliveryAddress"];
      }

      if (widget.SaleMaster![0]["DeliveryQuantityList"].contains('{@}')) {
        DeliveryQuantityList =
            widget.SaleMaster![0]["DeliveryQuantityList"].split('{@}');
        txtDeliveryQuantity.text = DeliveryQuantityList[0];
      } else {
        txtDeliveryQuantity.text = widget.SaleMaster![0]["DeliveryQuantityList"];
      }

      txtWarehouseAddress.text = widget.SaleMaster![0]["WareHouseAddress"] ?? "";
      dropdownValueFW1 = widget.SaleMaster![0]["Forwarding"] != ""
          ? widget.SaleMaster![0]["Forwarding"]
          : null;
      dropdownValueTruckSize =  widget.SaleMaster![0]["TruckSize"] != "" ? widget.SaleMaster![0]["TruckSize"].toString() : null;
      txtOrigin.text = widget.SaleMaster![0]["Origin"] ?? "";
      txtDestination.text = widget.SaleMaster![0]["Destination"] ?? "";
      dropdownValueZB1 = widget.SaleMaster![0]["Zb"] != ""
          ? widget.SaleMaster![0]["Zb"]
          : null;
      txtPTWNo.text = widget.SaleMaster![0]["PTW"] ?? "";
      if (widget.SaleMaster![0]["BoardingOfficerRefid"] != 0 &&
          widget.SaleMaster![0]["BoardingOfficerRefid"] != null) {
        BoardOfficerId1 = widget.SaleMaster![0]["BoardingOfficerRefid"];
        var BroardBy1 = objfun.EmployeeList.where((item) =>
            item.Id == widget.SaleMaster![0]["BoardingOfficerRefid"]).toList();
        txtBoardingOfficer1.text = BroardBy1[0].AccountName;
      }
      if (widget.SaleMaster![0]["BoardingOfficer1Refid"] != 0 &&
          widget.SaleMaster![0]["BoardingOfficer1Refid"] != null) {
        BoardOfficerId2 = widget.SaleMaster![0]["BoardingOfficer1Refid"];
        var BroardBy2 = objfun.EmployeeList.where((item) =>
            item.Id == widget.SaleMaster![0]["BoardingOfficer1Refid"]).toList();
        txtBoardingOfficer2.text = BroardBy2[0].AccountName;
      }
      txtAmount1.text = widget.SaleMaster![0]["BoardingAmount"] != null ? widget.SaleMaster![0]["BoardingAmount"].toString() : "";
      txtAmount2.text = widget.SaleMaster![0]["BoardingAmount1"] != null ? widget.SaleMaster![0]["BoardingAmount1"].toString() : "";
      txtENRef1.text = widget.SaleMaster![0]["ForwardingEnterRef"] ?? "";
      txtExRef1.text = widget.SaleMaster![0]["ForwardingExitRef"] ?? "";
      txtENRef2.text = widget.SaleMaster![0]["ForwardingEnterRef2"] ?? "";
      txtExRef2.text = widget.SaleMaster![0]["ForwardingExitRef2"] ?? "";
      txtENRef3.text = widget.SaleMaster![0]["ForwardingEnterRef3"] ?? "";
      txtExRef3.text = widget.SaleMaster![0]["ForwardingExitRef3"] ?? "";
      txtPortChargeRef1.text = widget.SaleMaster![0]["PortChargesRef"] ?? "";
      txtPortCharges.text = widget.SaleMaster![0]["PortCharges"] != null ? widget.SaleMaster![0]["PortCharges"].toString() : "";
      dropdownValueFW2 = widget.SaleMaster![0]["Forwarding2"] != ""
          ? widget.SaleMaster![0]["Forwarding2"]
          : null;
      dropdownValueFW3 = widget.SaleMaster![0]["Forwarding3"] != ""
          ? widget.SaleMaster![0]["Forwarding3"]
          : null;
      dropdownValueZB2 = widget.SaleMaster![0]["Zb2"] != ""
          ? widget.SaleMaster![0]["Zb2"]
          : null;
      txtZBRef1.text = widget.SaleMaster![0]["ZbRef"] ?? "";
      txtZBRef2.text = widget.SaleMaster![0]["ZbRef2"] ?? "";
      txtLSCN.text = widget.SaleMaster![0]["LSCN"] ?? "";
      txtCargo.text = widget.SaleMaster![0]["Cargo"] ?? "";
      txtForwarding1S1.text = widget.SaleMaster![0]["Forwarding1S1"] ?? "";
      txtForwarding1S2.text = widget.SaleMaster![0]["Forwarding1S2"] ?? "";
      txtForwarding2S1.text = widget.SaleMaster![0]["Forwarding2S1"] ?? "";
      txtForwarding2S2.text = widget.SaleMaster![0]["Forwarding2S2"] ?? "";
      txtForwarding3S1.text = widget.SaleMaster![0]["Forwarding3S1"] ?? "";
      txtForwarding3S2.text = widget.SaleMaster![0]["Forwarding3S2"] ?? "";

      DisabledBillType = true;
      DisabledAmount1 = true;
      DisabledAmount2 = true;
      EnableVisibility();
      if(txtJobType.text ==
          "GENARAL CARGO"){
        VisibleOrigin = false;
        VisibleDestination = false;
        VisibleGC = true;
      }
      else{
        VisibleGC = false;
      }
      Calculation();
    }
  }
  Future loadEnqdata() async {

      ProductViewList = [];
    if (widget.SaleMaster != null && widget.SaleMaster!.isNotEmpty) {
      await OnlineApi.MaxSaleOrderNo(context, dropdownValue);
      await OnlineApi.SelectCustomer(context);

      await OnlineApi.SelectJobType(context);
      if(widget.SaleMaster![0]["JobMasterRefId"] != null){
        await OnlineApi.SelectAllJobStatus(
            context, widget.SaleMaster![0]["JobMasterRefId"]);
      }


      await OnlineApi.loadCustomerCurrency(
          context, widget.SaleMaster![0]["CustomerRefId"]);

      CurrencyValue = objfun.CustomerCurrencyValue;
      EditId =0;
      EnquiryId = widget.SaleMaster![0]["Id"];
      Originid = widget.SaleMaster![0]["OriginRefId"];
      Destinationid = widget.SaleMaster![0]["DestinationRefId"];
      if (widget.SaleMaster![0]["OAgentCompanyRefId"] != 0 &&
          widget.SaleMaster![0]["OAgentCompanyRefId"] != null) {
        AgentCompanyId = widget.SaleMaster![0]["OAgentCompanyRefId"];
        var AgentCompany = objfun.AgentCompanyList.where((item) =>
            item.Id == widget.SaleMaster![0]["OAgentCompanyRefId"]).toList();
        txtOAgentCompany.text = AgentCompany[0].Name;
      }
      if (widget.SaleMaster![0]["OAgentMasterRefId"] != 0 &&
          widget.SaleMaster![0]["OAgentMasterRefId"] != null) {
        AgentId = widget.SaleMaster![0]["OAgentMasterRefId"];
        var AgentName = objfun.AgentAllList.where(
                (item) => item.Id == widget.SaleMaster![0]["OAgentMasterRefId"])
            .toList();
        txtOAgentName.text = AgentName[0].AgentName;
      }
      if (widget.SaleMaster![0]["AgentCompanyRefId"] != 0 &&
          widget.SaleMaster![0]["AgentCompanyRefId"] != null) {
        LAgentCompanyId = widget.SaleMaster![0]["AgentCompanyRefId"];
        var LAgentCompany = objfun.AgentCompanyList.where(
                (item) => item.Id == widget.SaleMaster![0]["AgentCompanyRefId"])
            .toList();
        txtLAgentCompany.text = LAgentCompany[0].Name;
      }
      if (widget.SaleMaster![0]["AgentMasterRefId"] != 0 &&
          widget.SaleMaster![0]["AgentMasterRefId"] != null) {
        LAgentId = widget.SaleMaster![0]["AgentMasterRefId"];
        var LAgentName = objfun.AgentAllList.where(
                (item) => item.Id == widget.SaleMaster![0]["AgentMasterRefId"])
            .toList();
        txtLAgentName.text = LAgentName[0].AgentName;
      }
      if (widget.SaleMaster![0]["CustomerRefId"] != 0 &&
          widget.SaleMaster![0]["CustomerRefId"] != null) {
        CustId = widget.SaleMaster![0]["CustomerRefId"];
        var CustomerName = objfun.CustomerList.where(
                (item) => item.Id == widget.SaleMaster![0]["CustomerRefId"]).toList();
        txtCustomer.text = CustomerName[0].AccountName;
      }
      if (widget.SaleMaster![0]["JobMasterRefId"] != 0 &&
          widget.SaleMaster![0]["JobMasterRefId"] != null) {
        JobTypeId = widget.SaleMaster![0]["JobMasterRefId"];
        var JobType = objfun.JobTypeList.where(
                (item) => item.Id == widget.SaleMaster![0]["JobMasterRefId"])
            .toList();
        txtJobType.text = JobType[0].Name;
      }


      txtDoDescription.text = widget.SaleMaster![0]["DODescription"] ?? "";
      txtTruckSize.text = widget.SaleMaster![0]["TruckSize"] != null ? widget.SaleMaster![0]["TruckSize"].toString() : "";
      dropdownValue = widget.SaleMaster![0]["BillType"];

      Coinage = widget.SaleMaster![0]["Coinage"];
      TaxAmount = widget.SaleMaster![0]["TaxAmount"];
     // CurrencyValue = widget.SaleMaster![0]["CurrencyValue"];
      ActualAmount = widget.SaleMaster![0]["ActualNetAmount"];
      txtRemarks.text = widget.SaleMaster![0]["Remarks"] ?? "";
      txtOffVessel.text = widget.SaleMaster![0]["Offvesselname"] ?? "";
      txtLoadingVessel.text = widget.SaleMaster![0]["Loadingvesselname"] ?? "";
      txtLPort.text = widget.SaleMaster![0]["SPort"] ?? " ";
      txtOPort.text = widget.SaleMaster![0]["OPort"] ?? " ";
      txtSmk1.text = widget.SaleMaster![0]["ForwardingSMKNo"] ?? "";
      txtSmk2.text = widget.SaleMaster![0]["ForwardingSMKNo2"] ?? "";
      txtSmk3.text = widget.SaleMaster![0]["ForwardingSMKNo3"] ?? "";
      if (widget.SaleMaster![0]["ETA"] != null) {
        checkBoxValueLETA = true;
        var ETADate = DateTime.parse(widget.SaleMaster![0]["ETA"].toString());

        dtpLETAdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(ETADate);
      }
      if (widget.SaleMaster![0]["FlighTime"] != null) {
        checkBoxValueFlightTime = true;
        var FlightTimeDate = DateTime.parse(widget.SaleMaster![0]["FlighTime"].toString());

        dtpFlightTimedate = DateFormat("yyyy-MM-dd HH:mm:ss").format(FlightTimeDate);
      }
      if (widget.SaleMaster![0]["ETB"] != null) {
        checkBoxValueLETB = true;
        var ETBDate = DateTime.parse(widget.SaleMaster![0]["ETB"].toString());

        dtpLETBdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(ETBDate);
      }
      if (widget.SaleMaster![0]["ETD"] != null) {
        checkBoxValueLETD = true;
        var ETDDate = DateTime.parse(widget.SaleMaster![0]["ETD"].toString());

        dtpLETDdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(ETDDate);
      }
      if (widget.SaleMaster![0]["OETA"] != null) {
        checkBoxValueOETA = true;
        var OETADate = DateTime.parse(widget.SaleMaster![0]["OETA"].toString());

        dtpOETAdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(OETADate);
      }
      if (widget.SaleMaster![0]["OETB"] != null) {
        checkBoxValueOETB = true;
        var OETBDate = DateTime.parse(widget.SaleMaster![0]["OETB"].toString());

        dtpOETBdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(OETBDate);
      }
      if (widget.SaleMaster![0]["OETD"] != null) {
        checkBoxValueOETD = true;
        var OETDDate = DateTime.parse(widget.SaleMaster![0]["OETD"].toString());

        dtpOETDdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(OETDDate);
      }

      if (widget.SaleMaster![0]["Forwarding2Date"] != null) {
        checkBoxValueFW2 = true;
        var FwDate = DateTime.parse(widget.SaleMaster![0]["Forwarding2Date"].toString());
        dtpFW2date = DateFormat("yyyy-MM-dd HH:mm:ss").format(FwDate);
      }
      else{
        checkBoxValueFW2 = false;
      }
      if (widget.SaleMaster![0]["Forwarding3Date"] != null) {
        checkBoxValueFW3 = true;
        var FwDate = DateTime.parse(widget.SaleMaster![0]["Forwarding3Date"].toString());
        dtpFW3date = DateFormat("yyyy-MM-dd HH:mm:ss").format(FwDate);
      }
      else{
        checkBoxValueFW3 = false;
      }

      txtAWBNo.text = widget.SaleMaster![0]["AWBNo"] ?? "";
      txtBLCopy.text = widget.SaleMaster![0]["BLCopy"] ?? "";
      txtOSCN.text = widget.SaleMaster![0]["SCN"] ?? "";
      txtLVesselType.text = widget.SaleMaster![0]["Vessel"] ?? "";
      txtOVesselType.text = widget.SaleMaster![0]["OVessel"] ?? "";
      txtCommodityType.text = widget.SaleMaster![0]["Commodity"] ?? "";
      txtWeight.text = widget.SaleMaster![0]["TotalWeight"] != null ? widget.SaleMaster![0]["TotalWeight"].toString() : "";
      txtQuantity.text = widget.SaleMaster![0]["Quantity"] != null ? widget.SaleMaster![0]["Quantity"].toString() : "";
      if (widget.SaleMaster![0]["JStatus"] != 0 &&
          widget.SaleMaster![0]["JStatus"] != null) {
        StatusId = widget.SaleMaster![0]["JStatus"];
        var JobStatus = objfun.JobAllStatusList.where(
            (item) => item.Status == widget.SaleMaster![0]["JStatus"]).toList();
        txtJobStatus.text = JobStatus[0].StatusName;
      }
      if (widget.SaleMaster![0]["SealbyRefid"] != 0 &&
          widget.SaleMaster![0]["SealbyRefid"] != null) {
        SealEmpId1 = widget.SaleMaster![0]["SealbyRefid"];
        var SealByEmp1 = objfun.EmployeeList.where(
            (item) => item.Id == widget.SaleMaster![0]["SealbyRefid"]).toList();
        txtSealByEmp1.text = SealByEmp1[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbreakbyRefid"] != 0 &&
          widget.SaleMaster![0]["SealbreakbyRefid"] != null) {
        BreakEmpId1 = widget.SaleMaster![0]["SealbreakbyRefid"];
        var BreakByEmp1 = objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbreakbyRefid"])
            .toList();
        txtBreakByEmp1.text = BreakByEmp1[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbyRefid2"] != 0 &&
          widget.SaleMaster![0]["SealbyRefid2"] != null) {
        SealEmpId2 = widget.SaleMaster![0]["SealbyRefid2"];
        var SealByEmp2 = objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbyRefid2"]).toList();
        txtSealByEmp2.text = SealByEmp2[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbreakbyRefid2"] != 0 &&
          widget.SaleMaster![0]["SealbreakbyRefid2"] != null) {
        BreakEmpId2 = widget.SaleMaster![0]["SealbreakbyRefid2"];
        var BreakByEmp2 = objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbreakbyRefid2"])
            .toList();
        txtBreakByEmp2.text = BreakByEmp2[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbyRefid3"] != 0 &&
          widget.SaleMaster![0]["SealbyRefid3"] != null) {
        SealEmpId3 = widget.SaleMaster![0]["SealbyRefid3"];
        var SealByEmp3 = objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbyRefid3"]).toList();
        txtSealByEmp3.text = SealByEmp3[0].AccountName;
      }
      if (widget.SaleMaster![0]["SealbreakbyRefid3"] != 0 &&
          widget.SaleMaster![0]["SealbreakbyRefid3"] != null) {
        BreakEmpId3 = widget.SaleMaster![0]["SealbreakbyRefid3"];
        var BreakByEmp3= objfun.EmployeeList.where(
                (item) => item.Id == widget.SaleMaster![0]["SealbreakbyRefid3"])
            .toList();
        txtBreakByEmp3.text = BreakByEmp3[0].AccountName;
      }
      if (widget.SaleMaster![0]["PickupDate"] != null) {
        checkBoxValuePickUp = true;
        var PickUpDate =
            DateTime.parse(widget.SaleMaster![0]["PickupDate"].toString());

        dtpPickUpdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(PickUpDate);
      }

      if (widget.SaleMaster![0]["DeliveryDate"] != null) {
        checkBoxValueDelivery = true;
        var DeliveryDate =
            DateTime.parse(widget.SaleMaster![0]["DeliveryDate"].toString());

        dtpDeliverydate =
            DateFormat("yyyy-MM-dd HH:mm:ss").format(DeliveryDate);
      }
      if (widget.SaleMaster![0]["WareHouseEnterDate"] != null) {
        checkBoxValueWHEntry = true;
        var WHEntryDate = DateTime.parse(
            widget.SaleMaster![0]["WareHouseEnterDate"].toString());

        dtpWHEntrydate = DateFormat("yyyy-MM-dd HH:mm:ss").format(WHEntryDate);
      }
      if (widget.SaleMaster![0]["WareHouseExitDate"] != null) {
        checkBoxValueWHExit = true;
        var WHExitDate = DateTime.parse(
            widget.SaleMaster![0]["WareHouseExitDate"].toString());

        dtpWHExitdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(WHExitDate);
      }

      if (widget.SaleMaster![0]["PickupAddress"].contains('{@}')) {
        PickUpAddressList = widget.SaleMaster![0]["PickupAddress"].split('{@}');
        txtPickUpAddress.text = PickUpAddressList[0];
      } else {
        txtPickUpAddress.text = widget.SaleMaster![0]["PickupAddress"];
      }
      if (widget.SaleMaster![0]["DeliveryAddress"].contains('{@}')) {
        DeliveryAddressList =
            widget.SaleMaster![0]["DeliveryAddress"].split('{@}');
        txtDeliveryAddress.text = DeliveryAddressList[0];
      } else {
        txtDeliveryAddress.text = widget.SaleMaster![0]["DeliveryAddress"];
      }
      txtWarehouseAddress.text = widget.SaleMaster![0]["WareHouseAddress"] ?? "";
      dropdownValueFW1 = widget.SaleMaster![0]["Forwarding"] != ""
          ? widget.SaleMaster![0]["Forwarding"]
          : null;
      dropdownValueTruckSize =  widget.SaleMaster![0]["TruckSize"] != "" ? widget.SaleMaster![0]["TruckSize"].toString() : null;
      txtOrigin.text = widget.SaleMaster![0]["Origin"] ?? "";
      txtDestination.text = widget.SaleMaster![0]["Destination"] ?? "";
      dropdownValueZB1 = widget.SaleMaster![0]["Zb"] != ""
          ? widget.SaleMaster![0]["Zb"]
          : null;
      txtPTWNo.text = widget.SaleMaster![0]["PTW"] ?? "";
      if (widget.SaleMaster![0]["BoardingOfficerRefid"] != 0 &&
          widget.SaleMaster![0]["BoardingOfficerRefid"] != null) {
        BoardOfficerId1 = widget.SaleMaster![0]["BoardingOfficerRefid"];
        var BroardBy1 = objfun.EmployeeList.where((item) =>
            item.Id == widget.SaleMaster![0]["BoardingOfficerRefid"]).toList();
        txtBoardingOfficer1.text = BroardBy1[0].AccountName;
      }
      if (widget.SaleMaster![0]["BoardingOfficer1Refid"] != 0 &&
          widget.SaleMaster![0]["BoardingOfficer1Refid"] != null) {
        BoardOfficerId2 = widget.SaleMaster![0]["BoardingOfficer1Refid"];
        var BroardBy2 = objfun.EmployeeList.where((item) =>
            item.Id == widget.SaleMaster![0]["BoardingOfficer1Refid"]).toList();
        txtBoardingOfficer2.text = BroardBy2[0].AccountName;
      }
      txtAmount1.text = widget.SaleMaster![0]["BoardingAmount"] != null ? widget.SaleMaster![0]["BoardingAmount"].toString() : "";
      txtAmount2.text = widget.SaleMaster![0]["BoardingAmount1"] != null ? widget.SaleMaster![0]["BoardingAmount1"].toString() : "";
      txtENRef1.text = widget.SaleMaster![0]["ForwardingEnterRef"] ?? "";
      txtExRef1.text = widget.SaleMaster![0]["ForwardingExitRef"] ?? "";
      txtENRef2.text = widget.SaleMaster![0]["ForwardingEnterRef2"] ?? "";
      txtExRef2.text = widget.SaleMaster![0]["ForwardingExitRef2"] ?? "";
      txtENRef3.text = widget.SaleMaster![0]["ForwardingEnterRef3"] ?? "";
      txtExRef3.text = widget.SaleMaster![0]["ForwardingExitRef3"] ?? "";
      txtPortChargeRef1.text = widget.SaleMaster![0]["PortChargesRef"] ?? "";
      txtPortCharges.text = widget.SaleMaster![0]["PortCharges"] != null ? widget.SaleMaster![0]["PortCharges"].toString() : "";
      dropdownValueFW2 = widget.SaleMaster![0]["Forwarding2"] != ""
          ? widget.SaleMaster![0]["Forwarding2"]
          : null;
      dropdownValueFW3 = widget.SaleMaster![0]["Forwarding3"] != ""
          ? widget.SaleMaster![0]["Forwarding3"]
          : null;
      dropdownValueZB2 = widget.SaleMaster![0]["Zb2"] != ""
          ? widget.SaleMaster![0]["Zb2"]
          : null;
      txtZBRef1.text = widget.SaleMaster![0]["ZbRef"] ?? "";
      txtZBRef2.text = widget.SaleMaster![0]["ZbRef2"] ?? "";
      txtLSCN.text = widget.SaleMaster![0]["LSCN"] ?? "";
      txtCargo.text = widget.SaleMaster![0]["Cargo"] ?? "";
      txtForwarding1S1.text = widget.SaleMaster![0]["Forwarding1S1"] ?? "";
      txtForwarding1S2.text = widget.SaleMaster![0]["Forwarding1S2"] ?? "";
      txtForwarding2S1.text = widget.SaleMaster![0]["Forwarding2S1"] ?? "";
      txtForwarding2S2.text = widget.SaleMaster![0]["Forwarding2S2"] ?? "";
      txtForwarding3S1.text = widget.SaleMaster![0]["Forwarding3S1"] ?? "";
      txtForwarding3S2.text = widget.SaleMaster![0]["Forwarding3S2"] ?? "";

      DisabledBillType = true;
      DisabledAmount1 = true;
      DisabledAmount2 = true;
      EnableVisibility();
      if(txtJobType.text ==
          "GENARAL CARGO"){
        VisibleOrigin = false;
        VisibleDestination = false;
        VisibleGC = true;
      }
      else{
        VisibleGC = false;
      }
      Calculation();
    }
  }



  Future Productclear() async {
    txtProductDescription.text = "";
    txtProductCode.text = "";
    txtProductQty.text = "";
    txtProductSaleRate.text = "";
    txtProductGst.text = "";
    txtProductAmount.text = "";
    txtProductMRP.text = "";
    txtProductPurchaseRate.text = "";
    txtProductId.text = "";
    txtProductLandingCost.text = "";
    txtProductNetSalesRate.text = "";
    txtProductDiscPer.text = "";
    txtProductDiscAmount.text = "";
    txtProductGSTAmount.text = "";
    txtProductSDId.text = "";
    txtItemMasterRefId.text = "";
    txtSaleOrderMasterRefId.text = "";
    txtProductUOM.text = "";
    txtProductActualAmount.text = "";
    txtProductCurrencyValue.text = "";


    objfun.SelectProductList = ProductModel.Empty();
  }

  Future ProductAdd() async {
    SaleEditDetailModel productadd = SaleEditDetailModel(
        txtProductId.text != "" ? int.parse(txtProductId.text) : 0,
        txtProductSDId.text != "" ? int.parse(txtProductSDId.text) : 0,
        txtSaleOrderMasterRefId.text != ""
            ? int.parse(txtSaleOrderMasterRefId.text)
            : 0,
        txtItemMasterRefId.text != "" ? int.parse(txtItemMasterRefId.text) : 0,
        txtProductMRP.text != "" ? double.parse(txtProductMRP.text) : 0.0,
        txtProductPurchaseRate.text != ""
            ? double.parse(txtProductPurchaseRate.text)
            : 0.0,
        txtProductQty.text != "" ? double.parse(txtProductQty.text) : 0.0,
        txtProductDiscPer.text != ""
            ? double.parse(txtProductDiscPer.text)
            : 0.0,
        txtProductDiscAmount.text != ""
            ? double.parse(txtProductDiscAmount.text)
            : 0.0,
        txtProductLandingCost.text != ""
            ? double.parse(txtProductLandingCost.text)
            : 0.0,
        txtProductGst.text != "" ? double.parse(txtProductGst.text) : 0.0,
        txtProductGSTAmount.text != ""
            ? double.parse(txtProductGSTAmount.text)
            : 0.0,
        txtProductSaleRate.text != ""
            ? double.parse(txtProductSaleRate.text)
            : 0.0,
        txtProductNetSalesRate.text != ""
            ? double.parse(txtProductNetSalesRate.text)
            : 0.0,
        txtProductAmount.text != "" ? double.parse(txtProductAmount.text) : 0.0,
        txtProductCode.text,
        txtProductDescription.text,
        txtProductUOM.text,
        txtProductActualAmount.text != "" ? double.parse(txtProductActualAmount.text) : 0.0,
        txtProductCurrencyValue.text != "" ? double.parse(txtProductCurrencyValue.text) : 0.0

    );


    if (ProductUpdateIndex != null) {
      ProductViewList[ProductUpdateIndex!] = productadd;

      //ProductViewList.insert(ProductUpdateIndex, productadd);
    } else {
      ProductViewList.add(productadd);
    }
    Calculation();
    setState(() {});
  }

  Future Calculation() async {
    var Amt = 0.0;
    var Gst = 0.0;
    var GstAmt = 0.0;
    var producttotal = 0.0;
    int decimalPlaces = 2;
    TaxAmount = 0.0;
    Gst = txtProductGst.text != "" ? double.parse(txtProductGst.text) : 0.0;
    var Qty = txtProductQty.text != "" ? double.parse(txtProductQty.text) : 0.0;
    var SaleRate = txtProductSaleRate.text != ""
        ? double.parse(txtProductSaleRate.text)
        : 0.0;
    var NetAmount = Qty * SaleRate;
    if (Gst != 0.0) {
      GstAmt = ((NetAmount * Gst) / 100);
      Amt = NetAmount + GstAmt;
    } else {
      Amt = (NetAmount * (10 * decimalPlaces)).round() / (10 * decimalPlaces);
    }

    txtProductGSTAmount.text = GstAmt.toString();
    txtProductAmount.text = Amt.toStringAsFixed(2);
    txtProductCurrencyValue.text = CurrencyValue.toString();


    for (var i = 0; i < ProductViewList.length; i++) {
      ProductViewList[i].CurrencyValue = CurrencyValue;
      producttotal = producttotal + ProductViewList[i].Amount;
      TaxAmount = TaxAmount + ProductViewList[i].TaxAmount;
      if(double.parse(txtProductCurrencyValue.text) != 0  ){
        var CalActualAmt = double.parse(txtProductCurrencyValue.text);
        txtProductActualAmount.text = (CalActualAmt * ProductViewList[i].Amount).toStringAsFixed(2);
        ProductViewList[i].ActualAmount = CalActualAmt * ProductViewList[i].Amount;
      }
      else{
        txtProductActualAmount.text = (ProductViewList[i].Amount).toStringAsFixed(2);
        ProductViewList[i].ActualAmount =ProductViewList[i].Amount;
      }
    }
    var GrossAmt = producttotal + TaxAmount;
    if (decimalPlaces == 2) {
      double roundedAmt = GrossAmt.roundToDouble();
      double coinage = (roundedAmt - GrossAmt).abs();
      Coinage = double.parse(coinage.toStringAsFixed(2));
    }


    setState(() {
      TotalAmount = double.parse(producttotal.toStringAsFixed(2));
      ActualAmount = double.parse((producttotal * CurrencyValue).toStringAsFixed(2));
    });
  }

  Future EnableVisibility() async {
    setState(() {
      VisibleOffVessel = false;
      VisibleLoadingVessel = false;
      VisibleLETA = false;
      VisibleLETB = false;
      VisibleLETD = false;
      VisibleAWBNo = false;
      VisibleBLCopy = false;
      VisibleFORKLIFT = false;
      VisibleSealBy = false;
      VisibleBreakSealBy = false;
      VisibleFORWARDING = false;
      VisibleOrigin = false;
      VisibleDestination = false;
      VisibleZB = false;
      VisibleOETA = false;
      VisibleOETB = false;
      VisibleOETD = false;
      VisibleOShippingAgent = false;
      VisibleOAgentName = false;
      VisibleOScn = false;
      VisibleLScn = false;
      VisibleLShippingAgent = false;
      VisibleLAgentName = false;
      VisibleLVesselType = false;
      VisibleOVesselType = false;
      VisibleOPort = false;
      VisibleLPort = false;

      for (var i = 0; i < objfun.JobTypeDetailsList.length; i++) {
        if (objfun.JobTypeDetailsList[i].Description == "OFF VESSEL NAME") {
          VisibleOffVessel = true;
        } else if (objfun.JobTypeDetailsList[i].Description ==
            "LOAD VESSEL NAME") {
          VisibleLoadingVessel = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "L ETA") {
          VisibleLETA = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "L ETB") {
          VisibleLETB = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "L ETD") {
          VisibleLETD = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "AWB NO") {
          VisibleAWBNo = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "BL COPY") {
          VisibleBLCopy = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "FORKLIFT") {
          VisibleFORKLIFT = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "SEAL BY") {
          VisibleSealBy = true;
        } else if (objfun.JobTypeDetailsList[i].Description ==
            "BREAK SEAL BY") {
          VisibleBreakSealBy = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "FORWARDING") {
          VisibleFORWARDING = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "ORIGIN") {
          VisibleOrigin = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "DESTINATION") {
          VisibleDestination = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "ZB") {
          VisibleZB = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "O ETA") {
          VisibleOETA = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "O ETB") {
          VisibleOETB = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "O ETD") {
          VisibleOETD = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "O AGENT") {
          VisibleOAgentName = true;
        } else if (objfun.JobTypeDetailsList[i].Description ==
            "O AGENT COMPANY") {
          VisibleOShippingAgent = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "O SCN") {
          VisibleOScn = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "L SCN") {
          VisibleLScn = true;
        } else if (objfun.JobTypeDetailsList[i].Description ==
            "L AGENT COMPANY") {
          VisibleLShippingAgent = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "L AGENT") {
          VisibleLAgentName = true;
        } else if (objfun.JobTypeDetailsList[i].Description ==
            "L VESSEL TYPE") {
          VisibleLVesselType = true;
        } else if (objfun.JobTypeDetailsList[i].Description ==
            "O VESSEL TYPE") {
          VisibleOVesselType = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "O PORT") {
          VisibleOPort = true;
        } else if (objfun.JobTypeDetailsList[i].Description == "L PORT") {
          VisibleLPort = true;
        }
      }
    });
    setState(() {
      progress = true;
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
  Future ConfirmEnquiry(int Id) async {
    setState(() {
      progress = false;
    });


    var Comid = objfun.storagenew.getInt('Comid') ?? 0;
    var Status = "CONFIRMED";
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiUpdateEnquiryMaster}$Id&Comid=$Comid&StatusName=$Status", null, header, context)
        .then((resultData) async {
    }).onError((error, stackTrace) {
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
    setState(() {
      progress = true;
    });
  }
  Future SaveSalesOrder() async {
    if (txtCustomer.text.isEmpty) {
      objfun.toastMsg('Enter Customer Name', '', context);
      return;
    }
    if (txtJobType.text.isEmpty) {
      objfun.toastMsg('Enter Job Type', '', context);
      return;
    }
    if (ProductViewList.isEmpty) {
      objfun.toastMsg('Add Product Details', '', context);
      return;
    }

    var TruckSizeSelected = "";
    if(dropdownValueTruckSize == '1 Tonner'){
      TruckSizeSelected = 'OneTon';

    }
    else  if(dropdownValueTruckSize == '3 Tonner'){
      TruckSizeSelected = 'ThreeTon';
    }
    else  if(dropdownValueTruckSize == '5 Tonner'){
      TruckSizeSelected = 'FiveTon';
    }
    else  if(dropdownValueTruckSize == '10 Tonner'){
      TruckSizeSelected = 'TenTon';
    }
    else  if(dropdownValueTruckSize == '40 FT Truck'){
      TruckSizeSelected = 'FourtyFeet';
    }
    bool result =
        await objfun.ConfirmationMsgYesNo(context, "Do You Want to Save ?");
    if (result == true) {
      setState(() {
        progress = false;
      });
      List<dynamic> master = [];
      master = [
        {
          'Id': EditId,
          'CompanyRefId': objfun.Comid,
          'UserRefId': null,
          'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
          'AgentCompanyRefId': LAgentCompanyId == 0 ? null : LAgentCompanyId,
          'AgentMasterRefId': LAgentId == 0 ? null : LAgentId,
          'OAgentCompanyRefId': OAgentCompanyId == 0 ? null : OAgentCompanyId,
          'OAgentMasterRefId': OAgentId == 0 ? null : OAgentId,
          'CustomerRefId': CustId,
          'JobMasterRefId': JobTypeId,
          'SaleDate': DateTime.parse(dtpSaleOrderdate).toIso8601String(),
          'SaleType': "",
          'CNumberDisplay': 0,
          'CNumber': 0,
          'Coinage': Coinage,
          'GrossAmount': TotalAmount,
          'TaxAmount': TaxAmount,
          'DiscountAmount': 0,
          'Remarks': txtRemarks.text,
          'PlusAmount': 0,
          'MinusAmount': 0,
          'DODescription': txtDoDescription.text,
          'Amount': TotalAmount,
          'Offvesselname': txtOffVessel.text,
          'Loadingvesselname': txtLoadingVessel.text,
          'BillType': dropdownValue,
          'SPort': txtLPort.text,
          'OPort': txtOPort.text,
          'Vessel': txtLVesselType.text,
          'OVessel': txtOVesselType.text,
          'Commodity': txtCommodityType.text,
          'Cargo': txtCargo.text,
          'ETA': checkBoxValueLETA == true
              ? DateTime.parse(dtpLETAdate).toIso8601String()
              : null,
          'FlighTime': checkBoxValueFlightTime == true
              ? DateTime.parse(dtpFlightTimedate).toIso8601String()
              : null,
          'ETB': checkBoxValueLETB == true
              ? DateTime.parse(dtpLETBdate).toIso8601String()
              : null,
          'ETD': checkBoxValueLETD == true
              ? DateTime.parse(dtpLETDdate).toIso8601String()
              : null,
          'OETA': checkBoxValueOETA == true
              ? DateTime.parse(dtpOETAdate).toIso8601String()
              : null,
          'OETB': checkBoxValueOETB == true
              ? DateTime.parse(dtpOETBdate).toIso8601String()
              : null,
          'OETD': checkBoxValueOETD == true
              ? DateTime.parse(dtpOETDdate).toIso8601String()
              : null,
          'DOCNo': null,
          'InvoiceNo': null,
          'TruckRefid': null,
          'DriverRefid': null,
          'AWBNo': txtAWBNo.text,
          'BLCopy': txtBLCopy.text,
          'Quantity': txtQuantity.text,
          'TotalWeight': txtWeight.text,
          'TruckSize': txtTruckSize.text,
          'JStatus': StatusId == 0 ? null : StatusId,
          'OStatus': 0,
          'ForkliftbyRefid': null,
          'SealbyRefid': SealEmpId1,
          'SealbreakbyRefid': BreakEmpId1,
          'SealbyRefid2': SealEmpId2,
          'SealbreakbyRefid2': BreakEmpId2,
          'SealbyRefid3': SealEmpId3,
          'SealbreakbyRefid3': BreakEmpId3,
          'BoardingOfficerRefid': BoardOfficerId1,
          'BoardingOfficer1Refid': BoardOfficerId2,
          'BoardingAmount': txtAmount1.text,
          'BoardingAmount1': txtAmount1.text,
          'ForwardingEnterRef': txtENRef1.text,
          'ForwardingExitRef': txtExRef1.text,
          'ForwardingEnterRef2': txtENRef2.text,
          'ForwardingExitRef2': txtExRef1.text,
          'ForwardingEnterRef3': txtENRef3.text,
          'ForwardingExitRef3': txtExRef3.text,
          'ForwardingSMKNo': txtSmk1.text,
          'ForwardingSMKNo2': txtSmk2.text,
          'ForwardingSMKNo3': txtSmk3.text,
          'PortChargesRef': txtPortChargeRef1.text,
          'PortCharges': txtPortCharges.text,
          'SealAmount': 0,
          'BreakSealAmount': 0,
          'BoatCPop': 0,
          'ForwardingCPop': 0,
          'PermitCPop': 0,
          'LiveCPop': 0,
          'MMHECPop': 0,
          'AFpoCPop': 0,
          'PPFpoCPop': 0,
          'SFWpoCPop': 0,
          'BoatCPop1': 0,
          'PFPPCPop1': 0,
          'SFEWpoCPop': 0,
          'OriginRefId': Originid,
          'DestinationRefId': Destinationid,
          'SealAmount2': 0,
          'BreakSealAmount2': 0,
          'SealAmount3': 0,
          'BreakSealAmount3': 0,
          'PickupDate': checkBoxValuePickUp == true
              ? DateTime.parse(dtpPickUpdate).toIso8601String()
              : null,
          'DeliveryDate': checkBoxValueDelivery == true
              ? DateTime.parse(dtpDeliverydate).toIso8601String()
              : null,
          'WareHouseEnterDate': checkBoxValueWHEntry == true
              ? DateTime.parse(dtpWHEntrydate).toIso8601String()
              : null,
          'WareHouseExitDate': checkBoxValueWHExit == true
              ? DateTime.parse(dtpWHExitdate).toIso8601String()
              : null,
          'WareHouseAddress': txtWarehouseAddress.text,
          //working
          'PickupAddress': PickUpAddressList.length <= 1
              ? txtPickUpAddress.text
              : PickUpAddressList.map((e) => e.toString()).join("{@}"),
          'pickupQuantitylist': PickUpQuantityList.length <= 1
              ? txtPickUpQuantity.text
              : PickUpQuantityList.map((e) => e.toString()).join("{@}"),
          'DeliveryAddress': DeliveryAddressList.length <= 1
              ? txtDeliveryAddress.text
              : DeliveryAddressList.map((e) => e.toString()).join("{@}"),
          'DeliveryQuantitylist': DeliveryQuantityList.length <= 1
              ? txtDeliveryQuantity.text
              : DeliveryQuantityList.map((e) => e.toString()).join("{@}"),
          'Forwarding': dropdownValueFW1,
          'Forwarding2': dropdownValueFW2,
          'Forwarding3': dropdownValueFW3,
          'trucksize2': TruckSizeSelected,
          'Origin': txtOrigin.text,
          'Destination': txtDestination.text,
          'SCN': txtOSCN.text,
          'LSCN': txtLSCN.text,
          'Zb': dropdownValueZB1,
          'PTW': txtPTWNo.text,
          'Zb2': dropdownValueZB2,
          'ZbRef': txtZBRef1.text,
          'ZbRef2': txtZBRef2.text,
          'Forwarding1S1': txtForwarding1S1.text,
          'Forwarding1S2': txtForwarding1S2.text,
          'Forwarding2S1': txtForwarding2S1.text,
          'Forwarding2S2': txtForwarding2S2.text,
          'Forwarding3S1': txtForwarding3S1.text,
          'Forwarding3S2': txtForwarding3S2.text,
          'CurrencyValue' : CurrencyValue,
          'ActualNetAmount' :ActualAmount,
          'ForwardingDate' :checkBoxValueFW1 == true ? DateTime.parse(dtpFW1date).toIso8601String() : null ,
          'Forwarding2Date' :checkBoxValueFW2 == true ? DateTime.parse(dtpFW2date).toIso8601String() : null ,
          'Forwarding3Date' :checkBoxValueFW3 == true ? DateTime.parse(dtpFW3date).toIso8601String() : null ,
          'SaleDetails': ProductViewList,
        }
      ];

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

await objfun
          .apiAllinoneSelectArray(
              "${objfun.apiInsertSalesOrder}?Comid=${objfun.Comid}",
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
            await objfun.ConfirmationOK('Created Successfully ', context);
           if( EnquiryId != 0){
             ConfirmEnquiry(EnquiryId);
           }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SalesOrderAdd()),
            );
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

  Future<void> applySpecialUserRights() async {

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    setState(() {

      final allFields = [
        "txtCustomer",
        "txtJobType",
        "txtJobStatus",
        "txtRemarks",
        "txtDoDescription",
        "ProductViewList",
        "txtCommodityType",
        "txtOrigin",
        "txtWeight",
        "txtQuantity",
        "txtTruckSize",
        "txtAWBNo",
        "txtBLCopy",
        "txtCargo",
        "txtPTWNo",
        "dtpLETAdate",
        "dtpLETBdate",
        "dtpLETDdate",
        "txtLAgentCompany",
        "txtLAgentName",
        "txtLSCN",
        "dtpFlightTimedate",
        "txtLoadingVessel",
        "txtLPort",
        "txtLVesselType",
        "cmbBillType",
        "dtpOETAdate",
        "dtpOETDdate",
        "txtOAgentCompany",
        "txtOAgentName",
        "txtOSCN",
        "txtOffVessel",
        "txtOPort",
        "txtOVesselType",
        "dtpPickUpdate",
        "dtpDeliverydate",
        "dtpWHEntrydate",
        "dtpWHExitdate",
        "txtOrigin",
        "txtDestination",
        "txtPickUpAddress",
        "txtPickUpQuantity",
        "txtDeliveryAddress",
        "txtDeliveryQuantity",
        "txtWarehouseAddress",
        "dtpFW1date",
        "txtSmk1",
        "txtENRef1",
        "txtSealByEmp1",
        "txtBreakByEmp1",
        "txtForwarding1S1",
        "txtForwarding1S2",
        "dropdownValueFW2",
        "dtpFW2date",
        "txtENRef2",
        "txtExRef2",
        "txtSealByEmp2",
        "txtBreakByEmp2",
        "txtForwarding2S1",
        "txtForwarding2S2",
        "dropdownValueFW3",
        "dtpFW3date",
        "txtSmk3",
        "txtENRef3",
        "txtSealByEmp3",
        "txtBreakByEmp3",
        "txtForwarding3S2",
        "dropdownValueZB1",
        "txtZBRef1",
        "dropdownValueZB2",
        "txtZBRef2",
        "txtBoardingOfficer1",
        "txtBoardingOfficer2",
        "txtAmount1",
        "txtAmount2",
        "txtPortCharges",
        "chkLETA",
        "chkOETA",
        "chkLETB",
        "chkOETB",
        "chkLETD",
        "chkOETD",
        "chkPickup",
        "chkDelivery",
        "chkWareHouseEntry",
        "chkWareHouseExit",
        "chkFlightTime",
        "SAVE",
        "VIEW",
        "addProduct",
        "dropdownValueFW1",
        "dropdownValueFW2",
        "checkBoxValueFW2",
        "txtSmk2",
        "dropdownValueFW3",
        "dropdownValueZB1",
        "dropdownValueZB2",
        "checkBoxValueFW1",
        "checkBoxValueFW3",
      ];



      final restrictedIds = [
        138, 50, 127, 35, 75, 38, 68, 128, 100, 117, 121
      ];

      if (!restrictedIds.contains(objfun.EmpRefId)) {
        fieldPermission = {
          for (var field in allFields) field: true,
        };
        return;
      }


      fieldPermission = {
        for (var field in allFields) field: false,
      };


      const allowedFields = [
        "txtBoardingOfficer1",
        "txtBoardingOfficer2",
        "txtAmount1",
        "txtAmount2",
        "SAVE",
        "VIEW",
      ];

      for (var field in allowedFields) {
        fieldPermission[field] = true;
      }
    });
  }

  bool isAllowed(String field) {
    return fieldPermission[field] ?? false;
  }




  late File ff;
  bool show = false;

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);

  }
}
