import 'package:maleva/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../../core/colors/colors.dart' as colour;
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/models/model.dart';
import '../../../../../core/utils/app_globals.dart';
import '../../../../../core/utils/app_preferences.dart';
import '../../../../mastersearch/Port.dart';
import '../../../../mastersearch/Employee.dart';
import '../../../../../core/network/OnlineApi.dart' as OnlineApi;
import '../bloc/vesselplanningweb_bloc.dart';
import '../bloc/vesselplanningweb_event.dart';
import '../bloc/vesselplanningweb_state.dart';
import '../data/vesselplanningweb_repository.dart';
import '../models/vesselplanningweb_model.dart';
import 'vesselplanning_update_sheet.dart';
import 'vesselplanningweb_saved_sheet.dart';
import 'package:maleva/core/models/shared/employee_model.dart';

const kGradient = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, colour.kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class VesselPlanningWebTab extends StatelessWidget {
  final bool pageView;
  final bool pageAdd;
  final bool pageEdit;
  final bool pageDelete;

  const VesselPlanningWebTab({
    super.key,
    this.pageView = true,
    this.pageAdd = true,
    this.pageEdit = true,
    this.pageDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!pageView) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
            child: Text('You do not have permission to view this page.')),
      );
    }

    return BlocProvider(
      create: (context) => VesselPlanningWebBloc(
        repository: VesselPlanningWebRepository(),
      )..add(FetchVesselPlanningSearch(
          fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          etaType: 3,
          searchPorts: '',
          deliveryDone: true,
          employeeId: 0,
        )),
      child: VesselPlanningWebView(
        pageAdd: pageAdd,
        pageEdit: pageEdit,
        pageDelete: pageDelete,
      ),
    );
  }
}

class VesselPlanningWebView extends StatefulWidget {
  final bool pageAdd;
  final bool pageEdit;
  final bool pageDelete;

  const VesselPlanningWebView({
    super.key,
    this.pageAdd = true,
    this.pageEdit = true,
    this.pageDelete = true,
  });

  @override
  _VesselPlanningWebViewState createState() => _VesselPlanningWebViewState();
}

class _VesselPlanningWebViewState extends State<VesselPlanningWebView> {
  // Data State
  List<VesselPlanningWebModel> _currentData = [];
  bool _isSortMode = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  // Master UI State
  final TextEditingController _planningNoCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  final TextEditingController _portStringController = TextEditingController();
  final TextEditingController _dropdownSearchController =
      TextEditingController();

  DateTime _planningDate = DateTime.now();
  DateTime _etaDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  int _etaType = 3; // 1: OETA, 2: L ETA, 3: A ETA
  bool _deliveryDone = true;

  // Employee
  EmployeeModel? _selectedEmployee;

  // Master ID if editing
  int _currentMasterId = 0;

  @override
  void initState() {
    super.initState();
    _planningNoCtrl.text = "NEW";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentMasterId == 0) {
        _fetchMaxPlanningNo();
      }
    });
  }

  Future<void> _fetchMaxPlanningNo() async {
    try {
      final repo = VesselPlanningWebRepository();
      final maxNo = await repo.getMaxVesselPlanningNo();
      if (maxNo.isNotEmpty && mounted) {
        setState(() {
          _planningNoCtrl.text = maxNo;
        });
      }
    } catch (e) {
      print('Error fetching max planning no: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, int type) async {
    DateTime initial = _planningDate;
    if (type == 2) initial = _etaDate;
    if (type == 3) initial = _toDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTokens.invoiceHeaderStart,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: colour.kTextDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (type == 1) _planningDate = picked;
        if (type == 2) _etaDate = picked;
        if (type == 3) _toDate = picked;
      });
    }
  }

  void _populateMasterData(Map<String, dynamic> masterData) {
    setState(() {
      _currentMasterId = masterData['Id'] ?? 0;
      _planningNoCtrl.text = masterData['VESSELPLANINGNoDisplay'] ??
          masterData['VESSELPLANINGNo'] ??
          masterData['CNumberDisplay'] ??
          '';
      _remarksCtrl.text = masterData['Remarks'] ?? '';

      if (masterData['PortName'] != null) {
        _portStringController.text = masterData['PortName'].toString();
      }
      
      if (masterData['Search'] != null && masterData['Search'].toString().isNotEmpty) {
        _portStringController.text = masterData['Search'].toString();
        _searchCtrl.text = masterData['Search'].toString();
        _searchQuery = _searchCtrl.text;
      }

      final empId = masterData['EmployeeId'] ?? masterData['EmployeeRefId'];
      final empName = masterData['EmployeeName'] ?? masterData['AccountName'] ?? 'Employee';
      if (empId != null || masterData['EmployeeName'] != null || masterData['AccountName'] != null) {
        _selectedEmployee = EmployeeModel(empId ?? 0, empName, '');
      }

      try {
        final dateRaw = masterData['VESSELPLANINGDate'] ?? masterData['Pdate'] ?? masterData['SaleDate'];
        if (dateRaw != null && dateRaw.toString().isNotEmpty) {
          _planningDate = DateTime.parse(dateRaw.toString().split('T')[0]);
        }

        final etaDateRaw = masterData['ETADate'] ?? masterData['FDate'];
        if (etaDateRaw != null && etaDateRaw.toString().isNotEmpty) {
          _etaDate = DateTime.parse(etaDateRaw.toString().split('T')[0]);
        }

        final toDateRaw = masterData['ToDate'] ?? masterData['TDate'];
        if (toDateRaw != null && toDateRaw.toString().isNotEmpty) {
          _toDate = DateTime.parse(toDateRaw.toString().split('T')[0]);
        }
      } catch (_) {}

      // Reset master filter toggles since backend doesn't store them for saved plannings
      _etaType = 3; 
      _deliveryDone = false;
    });
  }

  List<VesselPlanningWebModel> get _filtered {
    if (_searchQuery.isEmpty) return _currentData;
    final q = _searchQuery.toLowerCase();
    return _currentData.where((d) {
      return d.jobNo.toLowerCase().contains(q) ||
          d.jobName.toLowerCase().contains(q) ||
          d.customerName.toLowerCase().contains(q) ||
          d.sPort.toLowerCase().contains(q) ||
          d.vessel.toLowerCase().contains(q) ||
          d.jobStatus.toLowerCase().contains(q);
    }).toList();
  }

  void _doSearch() {
    context.read<VesselPlanningWebBloc>().add(
          FetchVesselPlanningSearch(
            fromDate: DateFormat('yyyy-MM-dd').format(_etaDate),
            toDate: DateFormat('yyyy-MM-dd').format(_toDate),
            etaType: _etaType,
            searchPorts: _portStringController.text,
            deliveryDone: _deliveryDone,
            employeeId: _selectedEmployee?.Id ?? 0,
          ),
        );
  }

  void _savePlanning(BuildContext context) {
    if (!widget.pageAdd) {
      msgshow('Permission Denied', ' You do not have permission to add plannings.', Colors.white, Colors.redAccent, null, 14, null, null, context, 2);
      return;
    }

    final checkedItems = _currentData.where((e) => e.isChecked).toList();
    if (checkedItems.isEmpty) {
      msgshow('Selection Required', ' Please select at least one job to plan.', Colors.white, Colors.redAccent, null, 14, null, null, context, 2);
      return;
    }

    const String defaultDate = "1900-01-01T00:00:00";
    final planningList = [
      {
        "Id": _currentMasterId,
        "SDId": 0,
        "CompanyRefId": AppGlobals.Comid,
        "UserRefId": int.tryParse(AppPreferences.getUserId()) ?? (AppGlobals.Comid == 0 ? null : AppGlobals.Comid),
        "EmployeeRefId": _selectedEmployee?.Id ?? (AppGlobals.EmpRefId == 0 ? null : AppGlobals.EmpRefId),
        "FDate": _etaDate.toIso8601String(),
        "TDate": _toDate.toIso8601String(),
        "SFDate": "",
        "STDate": "",
        "SaleDate": _planningDate.toIso8601String(),
        "SSaleDate": "",
        "CNumberDisplay": _planningNoCtrl.text.isEmpty ? "NEW" : _planningNoCtrl.text,
        "CNumber": 0,
        "Remarks": _remarksCtrl.text,
        "Active": 0,
        "Created_Date": defaultDate,
        "Created_By": "",
        "Modified_Date": defaultDate,
        "Modified_By": "",
        "SaleDetails": checkedItems
            .map((e) => {
                  "Id": 0,
                  "SDId": 0,
                  "VESSELPLANINGMasterRefId": _currentMasterId,
                  "SaleOrderMasterRefId": e.saleOrderMasterRefId,
                  "Origin": e.origin,
                  "Destination": e.destination,
                  "JobNo": e.jobNo,
                  "JobDate": e.jobDate,
                  "JobStatus": e.jobStatus,
                  "SortBy": e.sortBy,
                  "SCN": e.scn,
                  "LScn": e.lscn,
                  "VesselType": "",
                  "DETA": defaultDate,
                  "ETA": defaultDate,
                  "SETA": "",
                  "ETB": defaultDate,
                  "SETB": "",
                  "ETD": defaultDate,
                  "SETD": "",
                  "OETA": defaultDate,
                  "SOETA": "",
                  "OETB": defaultDate,
                  "SOETB": "",
                  "OETD": defaultDate,
                  "SOETD": "",
                  "PickupDate": "",
                  "SPickupDate": "",
                  "DeliveryDate": "",
                  "SDeliveryDate": "",
                  "WareHouseEnterDate": "",
                  "SWareHouseEnterDate": "",
                  "SWareHouseExitDate": "",
                  "WareHouseExitDate": "",
                  "WareHouseAddress": "",
                  "pkg": e.pkg,
                  "Loadingvesselname": e.loadingvesselname,
                  "BLCopy": e.blCopy,
                  "TruckSize": e.truckSize,
                  "OSCN": "",
                  "Offvesselname": e.offvesselname,
                  "Commodity": e.commodity,
                  "Vessel": e.vessel,
                  "OVessel": e.oVessel,
                  "SPort": e.sPort,
                  "OPort": e.oPort,
                  "Port": "",
                  "JobName": e.jobName,
                  "AWBNo": e.awbNo,
                  "Remarks1": e.remarks1,
                  "PTW": e.ptw,
                  "ZB": e.zb,
                  "ZB2": e.zb2,
                  "ZBRef": e.zbRef,
                  "ZBRef2": e.zbRef2,
                  "PortCharges": 0.0,
                  "PortChargesRef": e.portChargesRef,
                  "AgentCompany": "",
                  "OAgentCompany": "",
                  "AgentName": e.agentName,
                  "AgentPhone": e.agentPhone,
                  "OAgentName": e.oAgentName,
                  "OAgentPhone": e.oAgentPhone,
                  "BoardingOfficerRefid": 0,
                  "BoardingOfficerName": "",
                  "BoardingOfficer1Refid": 0,
                  "BoardingOfficerName1": "",
                  "BoardingAmount": 0.0,
                  "BoardingAmount1": 0.0,
                  "CustomerName": e.customerName,
                  "EmployeeName": e.employeeName,
                  "Remarks": "Added via Vessel Planning Mobile",
                  "Cargo": e.cargo
                })
            .toList()
      }
    ];

    context
        .read<VesselPlanningWebBloc>()
        .add(SaveVesselPlanningEvent(planningList: planningList));
  }

  void _deletePlanning() async {
    final bool ok = await ConfirmationMsgYesNo(context, 'Do You Want To Delete VESSEL PLANING ?');
    if (ok == true) {
      if (!mounted) return;
      context
          .read<VesselPlanningWebBloc>()
          .add(DeleteVesselPlanningEvent(id: _currentMasterId));
      setState(() {
        _currentMasterId = 0;
        _planningNoCtrl.clear();
        _remarksCtrl.clear();
        _portStringController.clear();
        _searchCtrl.clear();
        for (var element in _currentData) {
          element.isChecked = false;
        }
      });
    }
  }

  void _showSavedPlanningsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<VesselPlanningWebBloc>(),
        child: const VesselPlanningSavedSheet(),
      ),
    );
  }

  void _showUpdateSheet(BuildContext context, VesselPlanningWebModel jobData) {
    if (!widget.pageEdit) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VesselPlanningUpdateSheet(
        jobData: jobData,
        onUpdate: (updateData) {
          context.read<VesselPlanningWebBloc>().add(
                UpdateSpecificJobEvent(
                  updateData: updateData,
                  onSuccess: () {
                    msgshow('Success', ' Job ${jobData.jobNo} updated successfully!', Colors.white, AppTokens.statusSuccess, null, 14, null, null, context, 2);
                  },
                ),
              );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _planningNoCtrl.dispose();
    _remarksCtrl.dispose();
    _portStringController.dispose();
    _dropdownSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colour.kPageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 62,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Vessel Planning",
          style: AppTypography.heading1(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_currentMasterId > 0 && widget.pageDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Delete Vessel Planning',
              onPressed: _deletePlanning,
            ),
          IconButton(
            icon: const Icon(Icons.folder_copy_outlined, color: Colors.white),
            tooltip: 'View Saved Plannings',
            onPressed: () => _showSavedPlanningsSheet(context),
          ),
        ],
      ),
      body: BlocConsumer<VesselPlanningWebBloc, VesselPlanningWebState>(
        listener: (context, state) {
          if (state is VesselPlanningWebError) {
            msgshow('Error', ' ${state.message}', Colors.white, Colors.redAccent, null, 14, null, null, context, 2);
          } else if (state is VesselPlanningWebActionSuccess) {
            msgshow('Success', ' ${state.message}', Colors.white, AppTokens.statusSuccess, null, 14, null, null, context, 2);
            if (_currentMasterId == 0) {
              _fetchMaxPlanningNo();
            }
          }

          if (state is VesselPlanningWebLoaded) {
            if (state.dataList.isEmpty) {
              msgshow('No Results', ' No data found for the selected criteria.', Colors.white, colour.kHeaderGradEnd, null, 14, null, null, context, 2);
            }
            if (state.masterData != null) {
              _populateMasterData(state.masterData!);
            }
          }
        },
        builder: (context, state) {
          bool isLoading = state is VesselPlanningWebLoading ||
              state is VesselPlanningWebActionLoading;

          if (state is VesselPlanningWebLoaded) {
            _currentData = List.from(state.dataList)..sort((a, b) => a.sortBy.compareTo(b.sortBy));
          }

          return ListView(
            children: [
              _buildMasterPanel(context),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: SpinKitFoldingCube(
                      color: colour.kHeaderGradEnd, size: 35.0),
                )
              else
                _buildCardList(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMasterPanel(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text("Master Filters & Planning Info",
          style: AppTypography.heading3(color: colour.kTextDark, fontWeight: FontWeight.w700)),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      children: [
        // Top Row: Planning No, Planning Date
        Row(
          children: [
            Expanded(
              child: _TextFieldItem(
                  label: "Planing No",
                  controller: _planningNoCtrl,
                  readOnly: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DateTile(
                  label: "Planing Date",
                  date: DateFormat('dd/MM/yyyy').format(_planningDate),
                  onTap: () => _selectDate(context, 1)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second Row: From Date, To Date
        Row(
          children: [
            Expanded(
              child: _DateTile(
                  label: "From Date",
                  date: DateFormat('dd/MM/yyyy').format(_etaDate),
                  onTap: () => _selectDate(context, 2)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DateTile(
                  label: "To Date",
                  date: DateFormat('dd/MM/yyyy').format(_toDate),
                  onTap: () => _selectDate(context, 3)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ETA Types, Delivery Done
        Row(
          children: [
            _EtaChip(
                label: 'O ETA',
                selected: _etaType == 1,
                onTap: () => setState(() => _etaType = 1)),
            const SizedBox(width: 8),
            _EtaChip(
                label: 'L ETA',
                selected: _etaType == 2,
                onTap: () => setState(() => _etaType = 2)),
            const SizedBox(width: 8),
            _EtaChip(
                label: 'A ETA',
                selected: _etaType == 3,
                onTap: () => setState(() => _etaType = 3)),
            const Spacer(),
            Checkbox(
              value: _deliveryDone,
              onChanged: (val) => setState(() => _deliveryDone = val ?? true),
              activeColor: AppTokens.invoiceHeaderStart,
            ),
            Text("Delivery Done",
                style: AppTypography.bodyMedium()),
          ],
        ),
        const SizedBox(height: 12),
        // Ports and Employee
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Search Port",
                      style: AppTypography.heading1()),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colour.kCardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTokens.maintCardBorder),
                    ),
                    child: TextField(
                      controller: _portStringController,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Add Port",
                      style: AppTypography.heading1()),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const Port(Searchby: 1, SearchId: 0)))
                          .then((res) {
                        if (res != null && res is String) {
                          final currentText = _portStringController.text.trim();
                          if (currentText.isEmpty) {
                            _portStringController.text = res;
                          } else {
                            final portsList = currentText
                                .split(',')
                                .map((e) => e.trim())
                                .toList();
                            if (!portsList.contains(res)) {
                              _portStringController.text = '$currentText,$res';
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colour.kCardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTokens.maintCardBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: const Text('Select Port',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Employee",
                      style: AppTypography.heading1()),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      await OnlineApi.SelectEmployee(context, 'Sales', '');
                      if (!mounted) return;
                      if (!context.mounted) return;
                      final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const Employee(Searchby: 1, SearchId: 0)));
                      if (res != null && res is EmployeeModel) {
                        setState(() => _selectedEmployee = res);
                      }
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colour.kCardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTokens.maintCardBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selectedEmployee?.AccountName ?? 'Select Emp',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Remarks
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Remarks",
                      style: AppTypography.heading1()),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colour.kCardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTokens.maintCardBorder),
                    ),
                    child: TextField(
                      controller: _remarksCtrl,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _doSearch,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colour.kHeaderGradEnd,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('VIEW',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _savePlanning(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('SAVE',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardList(BuildContext context) {
    final filtered = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTokens.maintCardBorder),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: AppTypography.bodyLarge(color: colour.kTextDark, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search within grid...',
                hintStyle: AppTypography.bodyLarge(color: AppTokens.planTextMuted),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: colour.kHeaderGradEnd, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            size: 18, color: AppTokens.planTextMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Text('${filtered.length} jobs',
                  style: AppTypography.bodyMedium(color: AppTokens.planTextMuted, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (filtered.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    if (_searchQuery.isNotEmpty) {
                      msgshow('Cannot Sort', 'Please clear the search filter before sorting.', Colors.white, Colors.orangeAccent, null, 14, null, null, context, 2);
                      return;
                    }
                    setState(() {
                      _isSortMode = !_isSortMode;
                    });
                  },
                  icon: Icon(_isSortMode ? Icons.check : Icons.sort, size: 16, color: _isSortMode ? Colors.green : AppTokens.planTextMuted),
                  label: Text(_isSortMode ? 'DONE' : 'SORT', style: TextStyle(fontSize: 12, color: _isSortMode ? Colors.green : AppTokens.planTextMuted, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded, size: 50, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('No Data Found',
                      style: AppTypography.heading1(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )
        else if (_isSortMode)
          ReorderableListView.builder(
            buildDefaultDragHandles: false,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
            itemCount: filtered.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _currentData.removeAt(oldIndex);
                _currentData.insert(newIndex, item);
                for (int i = 0; i < _currentData.length; i++) {
                  _currentData[i].sortBy = i + 1;
                }
              });
            },
            itemBuilder: (ctx, i) => _JobCard(
              key: ValueKey(filtered[i].saleOrderMasterRefId),
              index: i,
              isSortMode: true,
              data: filtered[i],
              onLongPress: () => _showUpdateSheet(context, filtered[i]),
              onCheckChanged: (val) =>
                  setState(() => filtered[i].isChecked = val ?? false),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) => _JobCard(
              key: ValueKey(filtered[i].saleOrderMasterRefId),
              data: filtered[i],
              onLongPress: () => _showUpdateSheet(context, filtered[i]),
              onCheckChanged: (val) =>
                  setState(() => filtered[i].isChecked = val ?? false),
            ),
          ),
      ],
    );
  }
}

class _TextFieldItem extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  const _TextFieldItem(
      {required this.label, required this.controller, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.heading1()),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey.shade200 : colour.kCardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTokens.maintCardBorder),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;
  const _DateTile(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.heading1()),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: colour.kCardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTokens.maintCardBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: AppTokens.invoiceHeaderStart),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(date,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EtaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _EtaChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTokens.invoiceHeaderStart : Colors.transparent,
          border: Border.all(
              color: selected
                  ? AppTokens.invoiceHeaderStart
                  : AppTokens.maintCardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall(color: selected ? Colors.white : AppTokens.planTextMuted, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Job Card ─────────────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final VesselPlanningWebModel data;
  final VoidCallback onLongPress;
  final ValueChanged<bool?> onCheckChanged;
  final bool isSortMode;
  final int index;

  const _JobCard({
    super.key,
    required this.data,
    required this.onLongPress,
    required this.onCheckChanged,
    this.isSortMode = false,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: data.isChecked
                ? AppTokens.invoiceHeaderStart
                : AppTokens.maintCardBorder,
            width: data.isChecked ? 1.5 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: data.isChecked
                  ? AppTokens.invoiceHeaderStart.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: data.isChecked ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header bar ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTokens.invoiceHeaderStart.withValues(alpha: 0.08),
                    colour.kHeaderGradEnd.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  // Checkbox or Drag Handle
                  if (isSortMode)
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 24),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => onCheckChanged(!data.isChecked),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: data.isChecked ? kGradient : null,
                          border: data.isChecked
                              ? null
                              : Border.all(
                                  color: AppTokens.maintCardBorder, width: 1.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: data.isChecked
                            ? const Icon(Icons.check_rounded,
                                size: 13, color: Colors.white)
                            : null,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      data.jobNo.isNotEmpty
                          ? data.jobNo
                          : '#${data.saleOrderMasterRefId}',
                      style: AppTypography.heading3(color: AppTokens.invoiceHeaderStart, fontWeight: FontWeight.w800),
                    ),
                  ),
                  // Status badge
                  if (data.jobStatus.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTokens.statusSuccess.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTokens.statusSuccess.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        data.jobStatus,
                        style: AppTypography.badgeText(color: AppTokens.statusSuccess, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Long press hint
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: kGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 13, color: Colors.white),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  if (data.jobName.isNotEmpty)
                    _CardRow(
                        Icons.work_outline_rounded, 'Job Type', data.jobName),
                  if (data.customerName.isNotEmpty)
                    _CardRow(Icons.person_outline_rounded, 'Customer',
                        data.customerName),
                  // Port row
                  _CardRow(
                    Icons.location_on_outlined,
                    'Port',
                    data.sPort.isNotEmpty ? data.sPort : data.oPort,
                  ),
                  if (data.vessel.isNotEmpty)
                    _CardRow(Icons.directions_boat_outlined, 'Loading Vessel',
                        data.vessel),
                  if (data.offvesselname.isNotEmpty)
                    _CardRow(Icons.directions_boat_outlined, 'Off Vessel',
                        data.offvesselname),
                  if (data.eta.isNotEmpty)
                    _CardRow(Icons.access_time_rounded, 'ETA',
                        _fmtDate(data.seta.isNotEmpty ? data.seta : data.eta)),
                  if (data.etb.isNotEmpty)
                    _CardRow(Icons.anchor_rounded, 'ETB',
                        _fmtDate(data.setb.isNotEmpty ? data.setb : data.etb)),
                  if (data.etd.isNotEmpty)
                    _CardRow(Icons.directions_run_rounded, 'ETD',
                        _fmtDate(data.setd.isNotEmpty ? data.setd : data.etd)),
                  if (data.pkg.isNotEmpty && data.pkg != '/')
                    _CardRow(Icons.inventory_2_outlined, 'Package', data.pkg),
                  if (data.remarks.isNotEmpty)
                    _CardRow(Icons.comment_outlined, 'Remarks', data.remarks),
                ],
              ),
            ),

            // ── Footer ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: colour.kCardBg,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppTokens.planTextMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Job Date: ${data.jobDate}',
                    style: AppTypography.bodySmall(color: AppTokens.planTextMuted, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.touch_app_rounded,
                      size: 12, color: AppTokens.planTextMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Long press to edit',
                    style: AppTypography.bodySmall(color: AppTokens.planTextMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.replaceFirst(' ', 'T'));
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

class _CardRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _CardRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: colour.kHeaderGradEnd),
          const SizedBox(width: 6),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTypography.bodySmall(color: AppTokens.planTextMuted, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium(color: colour.kTextDark, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
