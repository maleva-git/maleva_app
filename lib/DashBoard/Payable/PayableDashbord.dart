import 'dart:io';
import 'package:flutter/Material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

part 'mobilePayableDashbord.dart';

class PayableDashbord extends StatefulWidget {
  final String? JobNo;
  final int? JobId;
  const PayableDashbord({super.key, this.JobNo, this.JobId});

  @override
  PayableDashbordState createState() => PayableDashbordState();
}

//test
class PayableDashbordState extends State<PayableDashbord> {
  bool progress = false;
  List<FuelFilling> fuelFillingRecords = [];
  List<EngineHoursdata> EngineHoursRecords = [];
  List <SpeedingView> speedingRecords=[];
  List<dynamic> engineHoursRecords = [];
  List<DriverViewModel> DriverViewRecords = [];
  List<FuelselectModel> fuelDifferenceRecords = [];
  List<TruckDetailsModel> TruckViewRecords = [];
  List<BillViewModel> BillorderViewRecords = [];
  List<PettyCashMasterModel> PettyCashRecords = [];

  List<FuelselectModel> fulerecord = [];
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  String dtpFromDate = DateFormat("yyyy-MM-dd").format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
  @override
  void initState() {
    super.initState();
    startup();
  }

  Future startup() async {
    loadFuelFilling();
    loadSpeeding();
    loadEngineHours();
    loadFuelDifference();
    loadfueldifference();
    LoadDriverViewRecords();
    LoadTruckViewRecords();
    LoadBillorderview();
    setState(() {
      progress = true;
    });
  }

  Future<void> loadSpeeding() async {
    await loadMonthlyReport<SpeedingView>(
      apiEndpoint: objfun.apiSelectSpeedingReport,
      fromJson: (json) => SpeedingView.fromJson(json),
      onDataLoaded: (records) => speedingRecords = records,
      selectedFromDate: selectedFromDate,
      selectedToDate: selectedToDate,
    );
  }

  Future<void> loadFuelFilling() async {
    await loadMonthlyReport<FuelFilling>(
      apiEndpoint: objfun.apiSelectFuelFillingReport,
      fromJson: (json) => FuelFilling.fromJson(json),
      onDataLoaded: (records) => fuelFillingRecords = records,
      selectedFromDate: selectedFromDate,
      selectedToDate: selectedToDate,
    );
  }

  Future<void> selectFromDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        dtpFromDate = DateFormat("yyyy-MM-dd").format(picked);
        selectedFromDate = picked;
        if (selectedToDate == null) {
          dtpToDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
          selectedToDate = DateTime.now();
        }
      });
    }
  }

  Future<void> selectToDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        dtpToDate = DateFormat("yyyy-MM-dd").format(picked);
        selectedToDate = picked;
      });
    }
  }

  Future<void> loadEingeHours() async {
    await loadMonthlyReport<EngineHoursdata>(
      apiEndpoint: objfun.apiSelectEangiehoursReport,
      fromJson: (json) => EngineHoursdata.fromJson(json),
      onDataLoaded: (records) => EngineHoursRecords = records,
    );
  }
  Future<void> LoadTruckViewRecords() async {
    setState(() {
      TruckViewRecords = [];
      progress = false;
    });

    var comid = objfun.storagenew.getInt('Comid') ?? 0;
    final keyword = ''; // ensure empty string
    final Column = 'All';

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final apiUrl =
      //"${objfun.apiDriverViewRecords}$comid&Startindex=0&PageCount=100&keyword=$keyword&Column=";
          "${objfun.apiEditTruckDetails}$comid&Startindex=0&PageCount=0&Keyword=$keyword&Column=$Column&type=";

      final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl,
        '',
        header,
        context,
      );
     // if (resultData != null && resultData is List)
        if (resultData != null && resultData is List) {
        final dataList = resultData;

        if (dataList != null && dataList is List && dataList.isNotEmpty) {
          final List<TruckDetailsModel> convertedList = dataList
              .map((item) => TruckDetailsModel.fromJson(item as Map<String, dynamic>))
              .toList();

          setState(() {
            TruckViewRecords = convertedList;
            progress = true;
          });
        } else {
          setState(() {
            progress = true;
          });
        }
      }


    } catch (e, st) {
      objfun.msgshow(
        e.toString(),
        st.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
      setState(() {
        progress = true;
      });
    }
  }
  Future<void> LoadDriverViewRecords() async {
    setState(() {
      DriverViewRecords = [];
      progress = false;
    });

    var comid = objfun.storagenew.getInt('Comid') ?? 0;
    final keyword = ''; // ensure empty string


    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final apiUrl =
          "${objfun.apiDriverViewRecords}$comid&Startindex=0&PageCount=100&keyword=$keyword&Column=";

      final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl,
        '',
        header,
        context,
      );

      if (resultData != null && resultData is Map<String, dynamic>) {
        final dataList = resultData['Data1'];

        if (dataList != null && dataList is List && dataList.isNotEmpty) {
          final List<DriverViewModel> convertedList = dataList
              .map((item) => DriverViewModel.fromJson(item as Map<String, dynamic>))
              .toList();

          setState(() {
            DriverViewRecords = convertedList;
            progress = true;
          });
        } else {
          setState(() {
            progress = true;
          });
        }
      }


    } catch (e, st) {
      objfun.msgshow(
        e.toString(),
        st.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
      setState(() {
        progress = true;
      });
    }
  }
  Future<void> LoadBillorderview() async {
    setState(() {
      BillorderViewRecords = [];
      progress = false;
    });

    final Fromdate = dtpFromDate;
    final Todate = dtpToDate;
    final comid = objfun.storagenew.getInt('Comid') ?? 0;

    final Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final apiUrl = "${objfun.apiBillorderview}$comid&Fromdate=$Fromdate&Todate=$Todate";

      final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl,
        '',
        header,
        context,
      );

      // ✅ Your backend returns a LIST directly, not a map with Data1.
      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<BillViewModel> convertedList = resultData
            .map((item) => BillViewModel.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          BillorderViewRecords = convertedList;
          progress = true;
        });
      } else {
        setState(() {
          progress = true;
        });
        debugPrint("No data found or empty list");
      }
    } catch (e, st) {
      objfun.msgshow(
        e.toString(),
        st.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
      setState(() {
        progress = true;
      });
    }
  }



  Future<void> LoadPettycashview() async {
    setState(() {
      PettyCashRecords = [];
      progress = false;
    });

    final Fromdate = dtpFromDate;
    final Todate = dtpToDate;
    final comid = objfun.storagenew.getInt('Comid') ?? 0;

    final Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final apiUrl = "${objfun.apiPettyCashview}$comid&Fromdate=$Fromdate&Todate=$Todate&Employeeid=0&Search=&PaymentStatus=&PaymentTo=";

      final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl,
        '',
        header,
        context,
      );

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final firstItem = resultData[0] as Map<String, dynamic>;
        final masterList = firstItem['PattycashMasterModel'] as List<dynamic>;
        
        final List<PettyCashMasterModel> convertedList = masterList
            .map((item) => PettyCashMasterModel.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          PettyCashRecords = convertedList;
          progress = true;
        });
      } else {
        setState(() {
          progress = true;
        });
        debugPrint("No petty cash data found");
      }
    } catch (e, st) {
      objfun.msgshow(
        e.toString(),
        st.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
      setState(() {
        progress = true;
      });
    }
  }

  

  Future loadfueldifference() async {
    setState(() {
      fulerecord = [];
      progress = false;
    });

    Map<String, dynamic> master = {
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': dtpFromDate,
      'Todate': dtpToDate,
      'Employeeid': 0,
      'DId': 0,
      'TId': 0,
      'Search': '',
    };

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectFuelEntry,
        master,
        header,
        context,
      );

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        // 🔹 Convert List<dynamic> → List<FuelEntryModel>
        final List<FuelselectModel> convertedList = resultData
            .map((item) => FuelselectModel.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          fulerecord = convertedList;
          progress = true;
        });
      } else {
        setState(() {
          progress = true;
        });
      }
    } catch (e, st) {
      objfun.msgshow(
        e.toString(),
        st.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );

      setState(() {
        progress = true;
      });
    }
  }

  void loadSpeedingDifference() {
    loadSpeeding();
  }

  void loadEngineHoursDifference() {
    loadEngineHours();
  }

  void loadFuelDifferenceDifference() {
    loadFuelDifference();
  }

  void loadCurrentTabData() {
    final currentIndex = DefaultTabController.of(context)?.index ?? 0;
    
    switch (currentIndex) {
      case 0: // Fuel tab
        loadFuelFilling();
        break;
      case 1: // Speed tab
        loadSpeeding();
        break;
      case 2: // Engine Hours tab
        loadEngineHours();
        break;
      case 3: // Fuel Difference tab
        loadFuelDifference();
        break;
      case 4: // Driver View tab
        LoadDriverViewRecords();
        break;
      case 5: // Truck View tab
        LoadTruckViewRecords();
        break;
      case 6: // Bill Order View tab
        LoadBillorderview();
        break;
      case 7: // Petty Cash View tab
        LoadPettycashview();
        break;
      default:
        loadFuelFilling();
    }
  }

  Future<void> loadFuelDifference() async {
    await loadMonthlyReport<FuelselectModel>(
      apiEndpoint: objfun.apiSelectFuelEntry,
      fromJson: (json) => FuelselectModel.fromJson(json),
      onDataLoaded: (records) => fuelDifferenceRecords = records,
      selectedFromDate: selectedFromDate,
      selectedToDate: selectedToDate,
    );
  }

  Future<void> loadEngineHours() async {
    await loadMonthlyReport<dynamic>(
      apiEndpoint: objfun.apiSelectEangiehoursReport,
      fromJson: (json) => json,
      onDataLoaded: (records) => engineHoursRecords = records,
      selectedFromDate: selectedFromDate,
      selectedToDate: selectedToDate,
    );
  }

  /// This method:
  /// 1. Calculates the current month's start and end date.
  /// 2. Prepares request body and headers.
  /// 3. Calls the API.
  /// 4. Parses response into a list of model objects.
  /// 5. Handles errors and updates UI state.
  Future<void> loadMonthlyReport<T>({
    required String apiEndpoint,
    required T Function(Map<String, dynamic>) fromJson,
    required void Function(List<T>) onDataLoaded,
    DateTime? selectedFromDate,
    DateTime? selectedToDate,
  }) async {String fromDate;String toDate;

  if (selectedFromDate != null && selectedToDate != null) {
    // Use selected dates
    fromDate = DateFormat('MM/dd/yyyy').format(selectedFromDate);
    toDate = DateFormat('MM/dd/yyyy').format(selectedToDate);
  } else {
    // Use current month dates
    DateTime today = DateTime.now();
    DateTime startOfMonth = DateTime(today.year, today.month, 1);
    DateTime endOfMonth = DateTime(today.year, today.month + 1, 0);
    fromDate = DateFormat('MM/dd/yyyy').format(startOfMonth);
    toDate = DateFormat('MM/dd/yyyy').format(endOfMonth);
  }

  // Request body
  Map<String, dynamic> master = {
    'Todate': toDate,
    'Fromdate': fromDate,
    'Comid': objfun.Comid,
  };

  // Request headers
   Map<String, String> header = {
    'Content-Type': 'application/json; charset=UTF-8',
   };

  try {
    // Call the API
    var resultData = await objfun.apiAllinoneSelectArray(
      apiEndpoint,
      master,
      header,
      context,
    );

    // Parse if not empty
    if (resultData != "" && resultData.isNotEmpty) {
      List<T> records = resultData
          .map<T>((element) => fromJson(element))
          .toList()
          .cast<T>();

      onDataLoaded(records); // Update the list in state
    }
  } catch (error, stackTrace) {
    // Error handling
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
  } finally {
    // Ensure UI updates
    setState(() {
      progress = true;
    });
  }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    bool result = await objfun.ConfirmationMsgYesNo(
        context, "Are you Sure you want to Exit?");
    if (result == true) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    } else {
      return false;
      // Navigator.of(context).pop();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return objfun.MalevaScreen == 1
        ? mobiledesign(this, context)
        : tabletdesign(this, context);
  }

  Widget tabletdesign(PayableDashbordState state, BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('HR Dashboard',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 22)),
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              color: Color(0xFF1E293B),
              child: TabBar(
                indicatorColor: Color(0xFF3B82F6),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
                tabs: [
                  Tab(icon: Icon(Icons.local_gas_station, size: 20), text: 'Fuel\nFilling'),
                  Tab(icon: Icon(Icons.person_off, size: 20), text: 'Driver\nExpiry'),
                  Tab(icon: Icon(Icons.speed, size: 20), text: 'Speed\nReport'),
                  Tab(icon: Icon(Icons.access_time, size: 20), text: 'Engine\nHours'),
                  Tab(icon: Icon(Icons.compare_arrows, size: 20), text: 'Fuel\nDifference'),
                ],
              ),
            ),
          ),
        ),
        drawer: const Menulist(),
        body: TabBarView(
          children: [
            _buildTabletFuelTab(state),
            _buildTabletDriverTab(state),
            _buildTabletSpeedTab(state),
            _buildTabletEngineTab(state),
            _buildTabletFuelDiffTab(state),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletFuelTab(PayableDashbordState state) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTabletHeader('Fuel Reports', 'Track fuel consumption', Icons.local_gas_station, Color(0xFF3B82F6)),
          SizedBox(height: 20),
          _buildTabletDateSelector(state, () => state.loadFuelFilling()),
          SizedBox(height: 20),
          Expanded(
            child: state.fuelFillingRecords.isEmpty
                ? _buildTabletEmptyState('No Fuel Records', 'No fuel data available')
                : _buildTabletFuelList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletDriverTab(PayableDashbordState state) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTabletHeader('Driver Expiry', 'Track license expiry dates', Icons.person_off, Color(0xFFEF4444)),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text('Driver Expiry Data Coming Soon',
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.grey.shade600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletSpeedTab(PayableDashbordState state) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTabletHeader('Speed Reports', 'Monitor vehicle speeds', Icons.speed, Color(0xFFF59E0B)),
          SizedBox(height: 20),
          _buildTabletDateSelector(state, () => state.loadSpeeding()),
          SizedBox(height: 20),
          Expanded(
            child: state.speedingRecords.isEmpty
                ? _buildTabletEmptyState('No Speed Records', 'No speeding violations found')
                : _buildTabletSpeedList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletEngineTab(PayableDashbordState state) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTabletHeader('Engine Hours', 'Track engine usage hours', Icons.access_time, Color(0xFF10B981)),
          SizedBox(height: 20),
          _buildTabletDateSelector(state, () => state.loadEngineHours()),
          SizedBox(height: 20),
          Expanded(
            child: state.engineHoursRecords.isEmpty
                ? _buildTabletEmptyState('No Engine Hours', 'No engine hours data available')
                : _buildTabletEngineList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletFuelDiffTab(PayableDashbordState state) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTabletHeader('Fuel Difference', 'Compare actual vs given fuel', Icons.compare_arrows, Color(0xFF8B5CF6)),
          SizedBox(height: 20),
          _buildTabletDateSelector(state, () => state.loadFuelDifference()),
          SizedBox(height: 20),
          Expanded(
            child: state.fuelDifferenceRecords.isEmpty
                ? _buildTabletEmptyState('No Fuel Difference', 'No fuel difference data available')
                : _buildTabletFuelDiffList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletHeader(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletDateSelector(PayableDashbordState state, VoidCallback onView) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateButton(
              DateFormat("dd MMM yyyy").format(DateTime.parse(state.dtpFromDate)),
                  () => state.selectFromDate(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "to",
              style: GoogleFonts.inter(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: _buildDateButton(
              DateFormat("dd MMM yyyy").format(DateTime.parse(state.dtpToDate)),
                  () => state.selectToDate(),
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: onView,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'View Reports',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 16, color: Color(0xFF3B82F6)),
            SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletFuelList(PayableDashbordState state) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: state.fuelFillingRecords.length,
      itemBuilder: (context, index) {
        final record = state.fuelFillingRecords[index];
        return _buildTabletCard(
          title: record.vehicle ?? 'Unknown Vehicle',
          subtitle: record.driver ?? 'No driver',
          icon: Icons.local_gas_station,
          color: Color(0xFF3B82F6),
          details: [
            'Fuel: ${record.filled ?? 'N/A'}',
            'Location: ${record.location ?? 'N/A'}',
            'Time: ${record.time ?? 'N/A'}',
          ],
        );
      },
    );
  }

  Widget _buildTabletSpeedList(PayableDashbordState state) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: state.speedingRecords.length,
      itemBuilder: (context, index) {
        final record = state.speedingRecords[index];
        return _buildTabletCard(
          title: record.vehicle.isNotEmpty ? record.vehicle : 'Unknown Vehicle',
          subtitle: record.driver.isNotEmpty ? record.driver : 'No driver',
          icon: Icons.speed,
          color: Color(0xFFEF4444),
          details: [
            'Speed: ${record.filled.isNotEmpty ? record.filled + ' km/h' : 'N/A'}',
            'Location: ${record.location.isNotEmpty ? record.location : 'N/A'}',
            'Time: ${record.time.isNotEmpty ? record.time : 'N/A'}',
          ],
        );
      },
    );
  }

  Widget _buildTabletEngineList(PayableDashbordState state) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: state.engineHoursRecords.length,
      itemBuilder: (context, index) {
        final record = state.engineHoursRecords[index];
        return _buildTabletCard(
          title: record['TruckName']?.toString() ?? 'Unknown Vehicle',
          subtitle: 'Mileage: ${record['mileage']?.toString() ?? 'N/A'}',
          icon: Icons.access_time,
          color: Color(0xFF10B981),
          details: [
            'Hours: ${record['totalTime']?.toString() ?? 'N/A'}',
            'Location: ${record['beginLocation']?.toString() ?? 'N/A'}',
            'Time: ${record['beginTime']?.toString() ?? 'N/A'}',
          ],
        );
      },
    );
  }

  Widget _buildTabletFuelDiffList(PayableDashbordState state) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: state.fuelDifferenceRecords.length,
      itemBuilder: (context, index) {
        final record = state.fuelDifferenceRecords[index];
        return _buildTabletCard(
          title: record.truckName ?? 'Unknown Vehicle',
          subtitle: record.driverName ?? 'No driver',
          icon: Icons.compare_arrows,
          color: Color(0xFF8B5CF6),
          details: [
            'A Amount: ${record.aAmount?.toString() ?? 'N/A'}',
            'G Amount: ${record.gAmount?.toString() ?? 'N/A'}',
            'Difference: ${(record.aAmount != null && record.gAmount != null) ? (record.aAmount! - record.gAmount!).toStringAsFixed(2) : 'N/A'}',
          ],
        );
      },
    );
  }

  Widget _buildTabletCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> details,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: details.map((detail) => Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    detail,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
