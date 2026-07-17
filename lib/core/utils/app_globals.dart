export 'dialog_helper.dart';
export 'printer_helper.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:core' as cc;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter/material.dart' as col;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:app_version_update/app_version_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/view/home_tab.dart';
import '../../features/mastersearch/Employee.dart';
import '../network/api_services/auth_api.dart';
import 'app_preferences.dart';
import '../network/api_constants.dart';
import '../network/api_client.dart';
import 'dialog_helper.dart';
import 'package:maleva/core/models/shared/list_item.dart';
import 'package:maleva/core/models/shared/agent_company_model.dart';
import 'package:maleva/features/operations/models/job_all_status_model.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';
import 'package:maleva/core/models/shared/barcode_print_model.dart';
import 'package:maleva/core/models/shared/address_details_model.dart';
import 'package:maleva/features/auth/models/user_login_model.dart';
import 'package:maleva/core/models/shared/mainsetting_model.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';
import 'package:maleva/core/models/shared/ware_house_model.dart';
import 'package:maleva/features/operations/models/forwarding_model.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'package:maleva/core/models/shared/agent_model.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/core/models/shared/product_model.dart';
import 'package:maleva/features/operations/models/job_type_details_model.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/core/models/shared/menu_master_model.dart';
import 'package:maleva/core/models/shared/location_model.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';

class AppGlobals {
  AppGlobals._();

  static String appversion="1.1.10+114";
  static bool homepagecall = false;
  static AssetImage logo = const AssetImage('assets/company/logo.png');
  static AssetImage splashlogo = const AssetImage('assets/company/roundlogo.png');
  static AssetImage calendar = const AssetImage('assets/common/calendar.png');
  static AssetImage lockimg = const AssetImage('assets/common/lockImg.png');

  // String port0 = "http://192.168.1.100:8085/";
  // String port = "http://192.168.1.13:9007/";
  //String port = "http://103.215.139.8:8001/";
  // String port = "http://192.168.1.101:8003/";

  //String port = "http://103.215.139.121:9001/"; //Demos

  //String port = "http://103.215.139.8:8001/"; //Demolatest

  //String port = "https://maleva.my"; //Live

  static String port = ApiConstants.port;

  //String razorpaykey = "rzp_live_GmuWNB2PVXAnLt";

  static String imagepath = "$port/Upload/$Comid/";
  //String apiPostimage = port + "/api/SaleOrderApp/ImageUpload/";



  //New



  //Employee






  /// Declear the  varibale  call  for the  checlsaleorder invoice








  //PreAlert Report








  //Fuel Entry

  //Driver view
    //comit
  //Stock






  static final navigatorKey = GlobalKey<NavigatorState>();
  static SharedPreferences storagenew = storagenew;
  static final txtLoginEmployee = TextEditingController();
  static final txtLoginPassword = TextEditingController();
  static var commonexpirydays = 15;
  static var ExpenseDueDays = 5;
  static var apadbonamexpirydays = 60;
  static var ExpServiceAligmentGreecedays = 5;
  static int DriverLogin = 0;
  static int DriverTruckRefId = 0;
  static int MalevaScreen = storagenew.getInt('DeviceView') ?? 1;
  static String DriverTruckName='';



  static Map<String, String> buildRequestHeaders(Map<String, String>? customHeaders, {bool skipAuth = false}) {
  final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    if (!skipAuth) {
  String token = "";
  String Userid = storagenew.getString('Userid') ?? "";
  String Profile = storagenew.getString('Profile') ?? "";
      if (token != "") {
        headers['Authorization'] = 'Bearer $token';
        headers['Userid'] = Userid;
        headers['Profile'] = Profile;
      }
    }
    return headers;
  }









  static Toast tls = Toast.LENGTH_SHORT;
  static Toast tll = Toast.LENGTH_LONG;
  static ToastGravity tgc = ToastGravity.CENTER;

  static String currentdate(int days)  {
  DateTime currentDate = DateTime.now();

    // Add the days
  DateTime newDate = currentDate.add(Duration(days: days));

    // Format the new date
  String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
    return formattedDate;

  }
  static bool downloadprogress = false;
  static double? progress = 0;
  get downloadProgress => progress;


  static String networkimage = '';






  static String barcodestring = '';
  static bool barcodeerror = false;

  Map<String, dynamic> printrow = {
    'Id': 0,
  };
  //Variables
  static int cashierLoginId = 0;
  static String cashierloginname = '';
  static int loginId = 1;
  static String loginname = '';
  static String loginpower = '';
  static int CloudTrial = 0;
  static DateTime Cloud_Ldate = DateTime.now();
  static bool networkConnection = false;
  static int maxytryconnection = 5;
  static int currenttryconnection = 6;
  static int numberofapicalls = 0;
  static int mCompanyRefid = 2;
  static bool onlineMirrorTable = false;
  // int CompanyRefid = 1;
  static int reducesize = 0;
  static double progresspercentage = 0.00;
  static String progresspercentagestring = "0.0";
  static String downlaodname = "";
  static bool downloadbreak = false;
  //Company Details
  static String companyname = 'Maleva';
  static String caddress1 = 'No.1/184A, Vijayalakshmi';
  static String caddress2 = 'Nagar 2nd Street,Abinadhan Nagar';
  static String ccity = 'Chennai';
  static String cmobileno = '+91 87540 31480';
  static String cgstino = 'GST-X123456';
  static String cwebsite = 'https://www.webpos.in/';
  static String cfootermsg1 = 'This is Footer Msg1';
  static String cfootermsg2 = 'This is Footer Msg2';
  static String selectedCompanyName = "";
  static String tcompanyname = 'TabletPOS';
  static String tcaddress1 = 'No.1/184A, Vijayalakshmi';
  static String tcaddress2 = 'Nagar 2nd Street,Abinadhan Nagar';
  static String tccity = 'Chennai';

  static List<MenuMasterModel> objMenuMaster = [];
  static List<MenuMasterModel> parentclass = [];

  static List<MainsettingModel> mainsettinglist = [];

  static List<EmployeeModel> EmployeeList = [];
  static EmployeeModel SelectEmployeeList = EmployeeModel.Empty();
  static List<UserLoginModel> UserList = [];
  static List<CustomerModel> CustomerList = [];
  static List<LocationModel> LocationList = [];
  static List<WareHouseModel> WareHouseList = [];
  static List<WareHouseModel> StockJobList = [];
  static CustomerModel SelectCustomerList = CustomerModel.Empty();
  static LocationModel SelectLocationList = LocationModel.Empty();
  static List<JobStatusModel> JobStatusList = [];
  static JobStatusModel SelectJobStatusList = JobStatusModel.Empty();
  static List<JobTypeModel> JobTypeList = [];
  static JobTypeModel SelectJobTypeList = JobTypeModel.Empty();
  static List<JobAllStatusModel> JobAllStatusList = [];
  static JobAllStatusModel SelectAllStatusList = JobAllStatusModel.Empty();
  static List<AgentCompanyModel> AgentCompanyList = [];
  static AgentCompanyModel SelectAgentCompanyList = AgentCompanyModel.Empty();
  static List<AgentModel> AgentAllList = [];
  static AgentModel SelectAgentAllList = AgentModel.Empty();
  static List<ProductModel> ProductList = [];
  static ProductModel SelectProductList = ProductModel.Empty();
  static List<ForwardingModel> ForwardingList = [];
  static ForwardingModel SelectForwardingList = ForwardingModel.Empty();
  static List<GetTruckModel> GetTruckList = [];




  static GetTruckModel SelectTruckList = GetTruckModel.Empty();
  static List<JobTypeDetailsModel> JobTypeDetailsList = [];
  static List<TruckDetailsModel> TruckDetailsList = [];

  static TruckDetailsModel SelectTruckDetails = TruckDetailsModel.Empty();
  static List<BarcodePrintModel> BarcodeList=[];

  static WareHouseModel SelectWareHouseList = WareHouseModel.Empty();
  static List<WareHouseModel> WareHouseModelAllList = [];

  static List<dynamic> AddressList = [];
  static List<dynamic> SaleOrderMasterList = [];
  static List<dynamic> SaleOrderDetailList = [];
  static List<dynamic> PlanningMasterList = [];
  static List<dynamic> PlanningDetailsList = [];
  static List<dynamic> PlanningEditList = [];
  static List<dynamic> VesselPlanningMasterList = [];
  static List<dynamic> VesselPlanningDetailsList = [];
  static List<dynamic> VesselPlanningEditList = [];
  static List<SaleEditDetailModel> SaleEditDetailList = [];
  static List<dynamic> SaleEditMasterList = [];
  static List<dynamic> ComboS1List = [];
  static List<dynamic> GetImagesList = [];
  static List<AddressDetailsModel> AddressDetailedList = [];
  static List<GetTruckModel> GetDriverList = [];
  static GetTruckModel SelectDriverList = GetTruckModel.Empty();
  static List<dynamic> RTIViewMasterList = [];
  static List<dynamic> RTIViewDetailList = [];

  static List<RTIDetailsViewModel> RTIViewDetailList1 = [];

  static List<RTIDetailsViewModel> RTIDetailsDetailList = [];
  static List<dynamic> EnquiryMasterList = [];
  static List<dynamic> PickupQuantityList = [];
  //List<SaleEditMasterModel> SaleEditMasterList = [];
  static String SelectAddressList = "";

  static List<dynamic> JobNoList = [];
  static String MaxSaleOrderNum = '';
  static String MaxStockNum = '';
  static int EmpRefId = 0;
  static int LoginEmpId = 0;
  static int Comid = 0;
  static double CustomerCurrencyValue = 0.0;
  static int SelectedId = 0;
  static double FontKeypad = 26;
  static double FontLarge = 24;
  static double FontMedium = 20;
  static double FontLow = 18;
  static double FontCardText = 14;
  static String SelectedName = '';
  static String SelectedPortName = '';
  static String SelectedVesselTypeName = '';
  static String SelectedCommodityName = '';
  static String SelectedCargoName = '';

  static List<ListItem> Paymentload = [
    ListItem(1, 'GPAY'),
    ListItem(2, 'HDFC'),
    ListItem(3, 'CASH')
  ];

  static List<ListItem> MisHoursload = [
    ListItem(1, 'Software Demo(Direct)'),
    ListItem(2, 'Software Demo(Online)'),
    ListItem(3, 'Software Installation(Online)'),
    ListItem(4, 'Software Installation(Direct)'),
    ListItem(5, 'Software Demo-Installation(Online)'),
    ListItem(6, 'Staff Meeting'),
    ListItem(7, 'Quotation'),
    ListItem(8, 'Leave'),
  ];

  static List<ListItem> Portlist = [
    ListItem(1, 'WESTPORT-B18'),
    ListItem(2, 'NORTHPORT- B10'),
    ListItem(3, 'SOUTHPORT-B11'),
    ListItem(4, 'WESTPORT LBT- B7X'),
    ListItem(5, 'WESTPORT DRY BULK- B7Y'),
    ListItem(6, 'PULAU KETAM JETTY'),
    ListItem(7, 'KAPAR POWERSTATION-B11'),
    ListItem(8, 'WESTPORT CRIUSE TERMINAL-B7S'),
    ListItem(9, 'PTP-J33'),
    ListItem(10, 'PASIRGUDANG PORT- J15'),
    ListItem(11, 'TANJUNG LANGSAT-J76'),
    ListItem(12, 'TANJUNG BIN- J33'),
    ListItem(13, 'PASIR PUTIH JETTY'),
    ListItem(14, 'PENGERENG PORT-J15'),
    ListItem(15, 'PENDAS JETTY'),
    ListItem(16, 'PARMESWARA JETTY MELAKA- M14'),
    ListItem(17, 'TANJUNG BRUAS MELAKA-M14'),
    ListItem(18, 'SUNGAI UDANG MELAKA-M15'),
    ListItem(19, 'SUNGAI LINGGI-M23'),
    ListItem(20, 'PORT DICKSON- N11'),
    ListItem(21, 'KUANTAN PORT -C13'),
    ListItem(22, 'KEMAMAN PORT (KSB)- T16'),
    ListItem(23, 'LIKIR BULK TERMINAL LUMUT A22'),
    ListItem(24, 'MARITIME TERMINAL LUMUT A22'),
    ListItem(25, 'VALI PORT A13'),
    ListItem(26, 'KERTEH'),
    ListItem(27, 'MMHE'),
    ListItem(28, 'BWCT -PENANG P15'),
    ListItem(29, 'BUTTERWORTH'),
    ListItem(30, 'PBCT-PENANG P88'),
    ListItem(31, 'NBCT-PENANG P14'),
    ListItem(32, 'SPCT-PENANG P20'),
    ListItem(33, 'TOK BALI'),
    ListItem(34, 'KSB WEST KEMAMAN T15'),
    ListItem(35, 'KPK KEMAMAN T16'),
    ListItem(36, 'KEMAMAN PORT (KSB) T16'),
    ListItem(37, 'LUMUT PORT-A22'),
    ListItem(38, 'SAPANGAR BAY CONTAINER PORT'),
    ListItem(39, 'KOTA KINABALU PORT'),
    ListItem(40, 'SAPANGAR BAY OIL TERMINAL'),
    ListItem(41, 'KUDAT PORT'),
    ListItem(42, 'SANDAKAN PORT'),
    ListItem(43, 'LAHAD DATU PORT'),
    ListItem(44, 'KUNAK PORT'),
    ListItem(45, 'TAWAU PORT'),
    ListItem(46, 'LABUAN PORT'),
    ListItem(47, 'MIRI PORT'),
    ListItem(48, 'SAMALAJU PORT'),
    ListItem(49, 'RAJANG PORT'),
    ListItem(50, 'TANJUNG MANIS PORT'),
    ListItem(51, 'KUCHING PORT'),
    ListItem(52, 'SIBU PORT'),
    ListItem(53, 'SARIKEI PORT'),
    ListItem(54, 'BINTULU PORT'),
  ];


  col.AppBar Appbar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      );
  }




  //Firebase Credentials---------------------------------------
  static String channeltopic="MALEVA";
  static String channelId = "MALEVA"; //Required for Android 8.0 or after
  static String channelName = "MALEVA channel"; //Required for Android 8.0 or after
  static String channelDescription = "this is our MALEVA channel";
  static String mobiletoken="";
  static getDeviceToken() async {

  FirebaseMessaging fcm = FirebaseMessaging.instance;
    String? fcmToken = await fcm.getToken();
    if (fcmToken != null) {
      mobiletoken = fcmToken;
      await AppPreferences.setFcmToken(fcmToken);
      print_(mobiletoken);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
    // fcm.subscribeToTopic('puppies');
    // fcm.unsubscribeFromTopic('puppies');
  }


  static void print_(dynamic msg) {
    if (kDebugMode) {
      print(msg);
    }
  }

}

class SizeConfig {
  static MediaQueryData _mediaQueryData = const MediaQueryData();
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;

  static double _safeAreaHorizontal = 0;
  static double _safeAreaVertical = 0;
  static double safeBlockHorizontal = 0;
  static double safeBlockVertical = 0;
static   int reducesize = 0;

static   void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    if (screenWidth < 412) {
double hh = 411 - screenWidth;
int sizereduce = (hh / 20).round();
      reducesize = sizereduce;
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
final String title;

const CustomAppBar({super.key, required this.title});

  @override
Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
