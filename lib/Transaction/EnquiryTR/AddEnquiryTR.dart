import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../MasterSearch/Customer.dart';
import '../../MasterSearch/JobType.dart';
import '../../MasterSearch/Location.dart';

part 'package:maleva/Transaction/EnquiryTR/mobileAddEnquiryTR.dart';
part 'package:maleva/Transaction/EnquiryTR/tabletAddEnquiryTR.dart';

class AddEnquiryTR extends StatefulWidget {
  final Map<String, dynamic>? SaleMaster;

  const AddEnquiryTR({super.key, this.SaleMaster});

  @override
  AddEnquiryTRState createState() => AddEnquiryTRState();
}

class AddEnquiryTRState extends State<AddEnquiryTR> with TickerProviderStateMixin{
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";


  late TabController _tabController;


  int EditId = 0;
  int CustId = 0;
  int OriginId = 0;
  int DestinationId = 0;
  int JobTypeId = 0;

  final txtCustomer = TextEditingController();
  final txtOrigin = TextEditingController();
  final txtDestination = TextEditingController();
  final txtJobType = TextEditingController();
  final txtQuantity = TextEditingController();
  final txtWeight = TextEditingController();
  final txtLPort = TextEditingController();
  final txtOPort = TextEditingController();

  String dtpNotfiydate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpCollectiondate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

  String dtpDeliverydate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String dtpOETAdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());


  bool checkBoxValueCollection = false;
  bool checkBoxValueLETA = false;
  bool checkBoxValueOETA = false;

  @override
  void initState() {

    startup();
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {

  txtLPort.dispose();
  txtOPort.dispose();
  txtQuantity.dispose();
  txtWeight.dispose();
  txtCustomer.dispose();
  txtOrigin.dispose();
  txtDestination.dispose();
  txtJobType.dispose();
    super.dispose();
  }

  Future startup() async {
    setState(() {
      progress = true;
    });
    loaddata();
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
  Future loaddata() async {

    if (widget.SaleMaster != null && widget.SaleMaster!.isNotEmpty) {

      txtLPort.text = widget.SaleMaster!["SPort"] ?? "";
      txtOPort.text = widget.SaleMaster!["OPort"] ?? "";

      txtQuantity.text = widget.SaleMaster!["Quantity"] ?? "";
      txtWeight.text = widget.SaleMaster!["TotalWeight"] ?? "";
      txtCustomer.text = widget.SaleMaster!["CustomerName"] ?? "";
      txtOrigin.text = widget.SaleMaster!["Origin"] ?? "";
      txtDestination.text = widget.SaleMaster!["Destination"] ?? "";
      txtJobType.text = widget.SaleMaster!["JobType"] ?? "";
       EditId =widget.SaleMaster!["Id"];
       CustId =widget.SaleMaster!["CustomerRefId"];
      OriginId =widget.SaleMaster!["OriginRefId"];
      DestinationId =widget.SaleMaster!["DestinationRefId"];
       JobTypeId =widget.SaleMaster!["JobMasterRefId"];
      var SaleDate =
      DateTime.parse(widget.SaleMaster!["ForwardingDate"].toString());
      dtpNotfiydate = DateFormat("yyyy-MM-dd HH:mm:ss").format(SaleDate);

      if (widget.SaleMaster!["PickupDate"] != null) {
        checkBoxValueCollection = true;
        var ETADate = DateTime.parse(widget.SaleMaster!["PickupDate"].toString());

        dtpCollectiondate = DateFormat("yyyy-MM-dd HH:mm:ss").format(ETADate);
      }
      if (widget.SaleMaster!["DeliveryDate"] != null) {
        checkBoxValueLETA = true;
        var DeliveryDate = DateTime.parse(widget.SaleMaster!["DeliveryDate"].toString());

        dtpDeliverydate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DeliveryDate);
      }


    }
    // await OnlineApi.EditSalesOrder(
    //     context, SaleOrderId, 0);
    // await OnlineApi.SelectEmployee(context, '', 'Operation');
    // txtENRef1.text = objfun.SaleEditMasterList[0]["ForwardingEnterRef"] ?? "";
    // txtENRef2.text = objfun.SaleEditMasterList[0]["ForwardingEnterRef2"] ?? "";
    // txtENRef3.text = objfun.SaleEditMasterList[0]["ForwardingEnterRef3"] ?? "";
    // txtExRef1.text = objfun.SaleEditMasterList[0]["ForwardingExitRef"] ?? "";
    // txtExRef2.text = objfun.SaleEditMasterList[0]["ForwardingExitRef2"] ?? "";
    // txtExRef3.text = objfun.SaleEditMasterList[0]["ForwardingExitRef3"] ?? "";
    // if(objfun.SaleEditMasterList[0]["SealbyRefid"] !=0 )
    // {
    //   SealEmpId1 = objfun.SaleEditMasterList[0]["SealbyRefid"];
    //   var SealByEmp1 = objfun.EmployeeList.where(
    //           (item) => item.Id == SealEmpId1).toList();
    //   txtSealByEmp1.text = SealByEmp1[0].AccountName;
    // } else{
    //   SealEmpId1 = 0;
    //   txtSealByEmp1.text = "";
    // }
    // if(objfun.SaleEditMasterList[0]["SealbyRefid2"] !=0 )
    // {
    //   SealEmpId2 = objfun.SaleEditMasterList[0]["SealbyRefid2"];
    //   var SealByEmp2 = objfun.EmployeeList.where(
    //           (item) => item.Id == SealEmpId2).toList();
    //   txtSealByEmp2.text = SealByEmp2[0].AccountName;
    // } else{
    //   SealEmpId2 = 0;
    //   txtSealByEmp2.text = "";
    // }
    // if(objfun.SaleEditMasterList[0]["SealbyRefid3"] !=0 )
    // {
    //   SealEmpId3 = objfun.SaleEditMasterList[0]["SealbyRefid3"];
    //   var SealByEmp3 = objfun.EmployeeList.where(
    //           (item) => item.Id == SealEmpId3).toList();
    //   txtSealByEmp3.text = SealByEmp3[0].AccountName;
    // } else{
    //   SealEmpId3 = 0;
    //   txtSealByEmp3.text = "";
    // }
    // if(objfun.SaleEditMasterList[0]["SealbreakbyRefid"] !=0 )
    // {
    //   BreakEmpId1 = objfun.SaleEditMasterList[0]["SealbreakbyRefid"];
    //   var BSealByEmp1 = objfun.EmployeeList.where(
    //           (item) => item.Id == BreakEmpId1).toList();
    //   txtBreakByEmp1.text = BSealByEmp1[0].AccountName;
    // } else{
    //   BreakEmpId1 = 0;
    //   txtBreakByEmp1.text = "";
    // }
    // if(objfun.SaleEditMasterList[0]["SealbreakbyRefid2"] !=0 )
    // {
    //   BreakEmpId2 = objfun.SaleEditMasterList[0]["SealbreakbyRefid2"];
    //   var BSealByEmp2 = objfun.EmployeeList.where(
    //           (item) => item.Id == BreakEmpId2).toList();
    //   txtBreakByEmp2.text = BSealByEmp2[0].AccountName;
    // } else{
    //   BreakEmpId2 = 0;
    //   txtBreakByEmp2.text = "";
    // }
    // if(objfun.SaleEditMasterList[0]["SealbreakbyRefid3"] !=0 )
    // {
    //   BreakEmpId3 = objfun.SaleEditMasterList[0]["SealbreakbyRefid3"];
    //   var BSealByEmp3 = objfun.EmployeeList.where(
    //           (item) => item.Id == BreakEmpId3).toList();
    //   txtBreakByEmp3.text = BSealByEmp3[0].AccountName;
    // } else{
    //   BreakEmpId3 = 0;
    //   txtBreakByEmp3.text = "";
    // }
    setState(() {
      progress = true;
    });
  }

  void clear() {

    CustId = 0;
    OriginId = 0;
    DestinationId = 0;
    JobTypeId = 0;

    txtCustomer.text = "";
    txtOrigin.text = "";
    txtDestination.text = "";
    txtJobType.text = "";
    txtQuantity.text = "";
    txtWeight.text = "";
    txtLPort.text = "";
    txtOPort.text = "";

     dtpNotfiydate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
     dtpCollectiondate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
     dtpDeliverydate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
     dtpOETAdate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

     checkBoxValueCollection = false;
     checkBoxValueLETA = false;
     checkBoxValueOETA = false;

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

  Future SaveEnquiry() async {
    if (txtCustomer.text.isEmpty) {
      objfun.toastMsg('Enter Customer Name', '', context);
      return;
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
          'AgentCompanyRefId':  null ,
          'AgentMasterRefId':  null,
          'OAgentCompanyRefId': null ,
          'OAgentMasterRefId': null ,
          'CustomerRefId': CustId,
          'JobMasterRefId': JobTypeId,
         // 'SaleDate': DateTime.parse(dtpSaleOrderdate).toIso8601String(),
          'SaleType': "",
          'CNumberDisplay': "",
          'CNumber': 0,
          'Coinage': 0,
          'GrossAmount': 0,
          'TaxAmount': 0,
          'DiscountAmount': 0,
          'Remarks': "",
          'PlusAmount': 0,
          'MinusAmount': 0,
          'DODescription': "",
          'Amount': 0,
          'Offvesselname': "",
          'Loadingvesselname': "",
          'BillType': "TR",
          'SPort': txtLPort.text,
          'OPort': txtOPort.text,
          'Vessel': "",
          'OVessel': "",
          'Commodity': "",
          'Cargo': "",
          'ETA': null,
          'ETB':  null,
          'ETD':null,
          'OETA': null,
          'OETB':  null,
          'OETD':  null,
          'DOCNo': null,
          'InvoiceNo': null,
          'TruckRefid': null,
          'DriverRefid': null,
          'AWBNo': "",
          'BLCopy': "",
          'Quantity': txtQuantity.text,
          'TotalWeight': txtWeight.text,
          'OriginRefId': OriginId,
          'DestinationRefId': DestinationId,
          'TruckSize': "",
          'JStatus': null ,
          'OStatus': 0,
          'ForkliftbyRefid': null,
          'SealbyRefid': null,
          'SealbreakbyRefid': null,
          'SealbyRefid2': null,
          'SealbreakbyRefid2': null,
          'SealbyRefid3': null,
          'SealbreakbyRefid3': null,
          'BoardingOfficerRefid': null,
          'BoardingOfficer1Refid': null,
          'BoardingAmount': 0,
          'BoardingAmount1': 0,
          'ForwardingEnterRef': "",
          'ForwardingExitRef': "",
          'ForwardingEnterRef2': "",
          'ForwardingExitRef2': "",
          'ForwardingEnterRef3': "",
          'ForwardingExitRef3': "",
          'ForwardingSMKNo': "",
          'ForwardingSMKNo2': "",
          'ForwardingSMKNo3': "",
          'PortChargesRef': "",
          'PortCharges': 0,
          'SealAmount': 0,
          'BreakSealAmount': 0,
          'SealAmount2': 0,
          'BreakSealAmount2': 0,
          'SealAmount3': 0,
          'BreakSealAmount3': 0,
          'PickupDate': checkBoxValueCollection == true
              ? DateTime.parse(dtpCollectiondate).toIso8601String()
              : null,
          'DeliveryDate':checkBoxValueLETA == true
              ? DateTime.parse(dtpDeliverydate).toIso8601String()
              : null,
          'WareHouseEnterDate': null,
          'WareHouseExitDate':  null,
          'WareHouseAddress': "",
          'PickupAddress':"",
          'DeliveryAddress': "",
          'Forwarding': "",
          'Forwarding2': "",
          'Forwarding3': "",
          'Origin':txtOrigin.text,
          'Destination': txtDestination.text,
          'SCN': "",
          'LSCN': "",
          'Zb': "",
          'PTW':"",
          'Zb2': "",
          'ZbRef': "",
          'ZbRef2': "",
          'Forwarding1S1': "",
          'Forwarding1S2': "",
          'Forwarding2S1': "",
          'Forwarding2S2':"",
          'Forwarding3S1': "",
          'Forwarding3S2': "",
          'CurrencyValue' : 0,
          'ActualNetAmount' :0,
          'ForwardingDate' : DateTime.parse(dtpNotfiydate).toIso8601String()  ,
          'Forwarding2Date' : null ,
          'Forwarding3Date' : null ,

        }
      ];

      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      await objfun
          .apiAllinoneSelectArray(
          "${objfun.apiInsertEnquiry}?Comid=${objfun.Comid}",
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AddEnquiryTR()),
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

  Future<bool> _onBackPressed() async {
    if(overlayEntry != null){
      clearOverlay();
      return false;
    }

    Navigator.of(context).pop();
    return true;
  }
  Future UpdateForwarding() async {

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