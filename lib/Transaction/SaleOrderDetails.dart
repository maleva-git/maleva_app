import 'dart:async';
import 'dart:io';
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

part 'package:maleva/Transaction/mobileSaleOrderDetails.dart';
part 'package:maleva/Transaction/tabletSaleOrderDetails.dart';

class SaleOrderDetails extends StatefulWidget {
  final List<SaleEditDetailModel>? SaleDetails;
  final List<dynamic>? SaleMaster;
  const SaleOrderDetails({super.key, this.SaleDetails, this.SaleMaster});

  @override
  SaleOrderDetailsState createState() => SaleOrderDetailsState();
}

class SaleOrderDetailsState extends State<SaleOrderDetails>
    with TickerProviderStateMixin {
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
  final txtDeliveryAddress = TextEditingController();
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
  bool checkBoxValueLETB = false;
  bool checkBoxValueLETD = false;
  bool checkBoxValuePickUp = false;
  bool checkBoxValueDelivery = false;
  bool checkBoxValueWHEntry = false;
  bool checkBoxValueWHExit = false;

  bool VisibleOffVessel = true;
  bool VisibleLoadingVessel = true;
  bool VisibleLETA = true;
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
  int EditId = 0;
  var Coinage = 0.0;
  double TotalAmount = 0.00;
  double TaxAmount = 0.0;
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


  String dropdownValue = BillType.first;
  List<SaleEditDetailModel> ProductViewList = [];
  List<dynamic> PickUpAddressList = [];
  List<dynamic> DeliveryAddressList = [];

  String? dropdownValueFW1;
  String? dropdownValueFW2;
  String? dropdownValueFW3;
  String? dropdownValueZB2;
  String? dropdownValueZB1;
  List<dynamic> _filteredAddress = [];

  static const List<String> BillType = <String>['MY', 'TR'];
  static const List<String> ForwardingNo = <String>['K1', 'K2', 'K3', 'K8'];
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
    txtProductSDId.dispose();
    txtSaleOrderMasterRefId.dispose();
    txtItemMasterRefId.dispose();
    txtENRef1.dispose();
    txtENRef2.dispose();
    txtENRef3.dispose();
    txtSmk1.dispose();
    txtSmk2.dispose();
    txtSmk3.dispose();
    txtSealByEmp1.dispose();
    txtSealByEmp2.dispose();
    txtSealByEmp3.dispose();
    txtBreakByEmp1.dispose();
    txtBreakByEmp2.dispose();
    txtBreakByEmp3.dispose();
    txtExRef1.dispose();
    txtExRef2.dispose();
    txtExRef3.dispose();
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

    super.dispose();
  }

  Future startup() async {
    await OnlineApi.MaxSaleOrderNo(context, dropdownValue);
    await OnlineApi.SelectAddressList(context);
    await OnlineApi.SelectAgentCompany(context);
    await OnlineApi.SelectEmployee(context, '', 'Operation');
    setState(() {
      _filteredAddress = objfun.AddressList;
      txtJobNo.text = objfun.MaxSaleOrderNum;
      progress = true;
    });
    loaddata();
  }

  Future loaddata() async {
    if (widget.SaleDetails != null && widget.SaleDetails!.isNotEmpty) {

    }
    if (widget.SaleMaster != null && widget.SaleMaster!.isNotEmpty) {
      await OnlineApi.SelectCustomer(context);
      await OnlineApi.SelectJobType(context);
      await OnlineApi.SelectAllJobStatus(
          context, widget.SaleMaster![0]["JobMasterRefId"]);
      await OnlineApi.SelectAgentAll(
          context, widget.SaleMaster![0]["AgentCompanyRefId"]);

      EditId = widget.SaleMaster![0]["Id"];
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

      DisabledBillType = true;
      DisabledAmount1 = true;
      DisabledAmount2 = true;
      EnableVisibility();

    }
  }

  Column loadgridheader() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  "SNo",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Code",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Description",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  "Qty",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "SaleRate",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "GST",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    "Amount",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: colour.ButtonForeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: objfun.FontLow,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
                const Expanded(flex: 2, child: Text(""))
              ],
            )),
      ],
    );
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
  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    return true;
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
