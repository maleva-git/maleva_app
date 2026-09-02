import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/features/transaction/planning/data/planning_repository.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/theme/app_typography.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/transaction/salesorder/add/view/salesorderadd_tab.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'dart:convert';
import '../../../../core/utils/app_globals.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/features/mastersearch/Employee.dart';

class AddPlanningPage extends StatefulWidget {
  const AddPlanningPage({super.key});

  @override
  State<AddPlanningPage> createState() => _AddPlanningPageState();
}

class _AddPlanningPageState extends State<AddPlanningPage> {
  final TextEditingController _planNoCtrl = TextEditingController(text: '0');
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  
  String _planDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String _pickupDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String _toDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  final List<Map<String, dynamic>> _planningItems = [];
  int? _editMasterId;


  @override
  void initState() {
    super.initState();
    _fetchMaxPlaningNo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<LegacyApiRepository>().SelectTruckList(context, '');
      sl<LegacyApiRepository>().SelectDriverList(context, '');
    });
  }

  Future<void> _pickDate(BuildContext context, String current, Function(String) onPicked) async {
    DateTime? initial;
    try {
      initial = DateFormat('dd/MM/yyyy').parse(current);
    } catch (_) {
      initial = DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onPicked(DateFormat('dd/MM/yyyy').format(picked));
    }
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall(color: colour.kTextDim)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          readOnly: readOnly,
          style: AppTypography.bodyMedium(color: colour.kText),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? colour.kSurface2 : colour.kBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: colour.kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: colour.kBorder)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, String value, Function(String) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall(color: colour.kTextDim)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _pickDate(context, value, onPicked),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: colour.kBg,
              border: Border.all(color: colour.kBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: AppTypography.bodyMedium(color: colour.kText)),
                const Icon(Icons.calendar_month, size: 16, color: colour.kTextDim),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onTap, {bool isPrimary = false}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? colour.kCobalt : colour.kSurface2,
        foregroundColor: isPrimary ? colour.kBg : colour.kText,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  void _showBulkApplySheet() {
    String? bTruck;
    String? bDriver;
    String? bPDate;
    String? bDDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bulk Apply to All Lines', style: AppTypography.heading3()),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(),
                    const Text('Select the fields you want to update for ALL lines. Leave empty to skip.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSheetDropdown(
                            'Truck (Leave empty to skip)', 
                            bTruck ?? '', 
                            [''] + AppGlobals.GetTruckList.map((e) => e.AccountName ?? '').toList(), 
                            setModalState, 
                            (v) => setModalState(() => bTruck = v.isEmpty ? null : v)
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSheetDropdown(
                            'Driver (Leave empty to skip)', 
                            bDriver ?? '', 
                            [''] + AppGlobals.GetDriverList.map((e) => e.AccountName ?? '').toList(), 
                            setModalState, 
                            (v) => setModalState(() => bDriver = v.isEmpty ? null : v)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSheetDatePicker(
                            'Pickup Date (Skip if empty)', 
                            bPDate ?? '', 
                            setModalState, 
                            (d) => setModalState(() => bPDate = d)
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSheetDatePicker(
                            'Delivery Date (Skip if empty)', 
                            bDDate ?? '', 
                            setModalState, 
                            (d) => setModalState(() => bDDate = d)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          for (int i = 0; i < _planningItems.length; i++) {
                            if (bTruck != null) _planningItems[i]['truck'] = bTruck;
                            if (bDriver != null) _planningItems[i]['driver'] = bDriver;
                            if (bPDate != null) _planningItems[i]['pDate'] = bPDate;
                            if (bDDate != null) _planningItems[i]['dDate'] = bDDate;
                          }
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk applied successfully!')));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: colour.kCobalt, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('APPLY TO ALL', style: TextStyle(color: colour.kBg, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddEditItemSheet({Map<String, dynamic>? itemToEdit, int? index}) {
    final bool isEdit = itemToEdit != null;
    
    // Temp state for sheet
    String sRemarks = itemToEdit?['remarks'] ?? '';
    String sTruck = itemToEdit?['truck'] ?? '';
    String sDriver = itemToEdit?['driver'] ?? '';
    String sPDate = itemToEdit?['pDate'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now());
    String sDDate = itemToEdit?['dDate'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now());
    String sOrigin = itemToEdit?['origin'] ?? '';
    String sDest = itemToEdit?['destination'] ?? '';
    String sCust = itemToEdit?['customer'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: colour.kBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24, 
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEdit ? "Edit Planning Line" : "Add Planning Line", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSheetDropdown(
                          'Truck', 
                          sTruck, 
                          AppGlobals.GetTruckList.map((e) => e.AccountName).toSet().toList(),
                          setSheetState,
                          (v) => sTruck = v
                        ),
                        const SizedBox(height: 12),
                        _buildSheetDropdown(
                          'Driver', 
                          sDriver, 
                          AppGlobals.GetDriverList.map((e) => e.AccountName).toSet().toList(),
                          setSheetState,
                          (v) => sDriver = v
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildSheetDatePicker('Pickup Date', sPDate, setSheetState, (v) => sPDate = v)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildSheetDatePicker('Drop Date', sDDate, setSheetState, (v) => sDDate = v)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSheetTextField('Origin', sOrigin, (v) => sOrigin = v),
                        const SizedBox(height: 12),
                        _buildSheetTextField('Destination', sDest, (v) => sDest = v),
                        const SizedBox(height: 12),
                        _buildSheetTextField('Customer Name', sCust, (v) => sCust = v),
                        const SizedBox(height: 12),
                        _buildSheetTextField('Remarks', sRemarks, (v) => sRemarks = v),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final newData = {
                        'remarks': sRemarks,
                        'truck': sTruck,
                        'driver': sDriver,
                        'pDate': sPDate,
                        'dDate': sDDate,
                        'origin': sOrigin,
                        'destination': sDest,
                        'customer': sCust,
                      };
                      setState(() {
                        if (isEdit && index != null) {
                          _planningItems[index] = newData;
                        } else {
                          _planningItems.add(newData);
                        }
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour.kCobalt,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isEdit ? "Update Line" : "Add Line", style: const TextStyle(color: colour.kBg, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        });
      }
    );
  }

  Widget _buildSheetDropdown(String label, String value, List<String> items, StateSetter setSheetState, Function(String) onChanged) {
    String? displayValue = items.contains(value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall(color: colour.kTextDim)),
        const SizedBox(height: 4),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colour.kSurface,
            border: Border.all(color: colour.kBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: displayValue,
              hint: const Text("Select", style: TextStyle(fontSize: 14)),
              items: items.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (v) {
                if (v != null) {
                  onChanged(v);
                  setSheetState(() {});
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetTextField(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall(color: colour.kTextDim)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: colour.kSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: colour.kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: colour.kBorder)),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetDatePicker(String label, String value, StateSetter setSheetState, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall(color: colour.kTextDim)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _pickDate(context, value, (v) {
            onChanged(v);
            setSheetState(() {});
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: colour.kSurface,
              border: Border.all(color: colour.kBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: AppTypography.bodyMedium(color: colour.kText)),
                const Icon(Icons.calendar_month, size: 16, color: colour.kTextDim),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isLoading = false;

  Future<void> _fetchMaxPlaningNo() async {
    try {
      final payload = {"Comid": AppGlobals.Comid, "BillType": ""};
      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': AppGlobals.Comid.toString()
      };
      var resultData = await sl<LegacyApiRepository>().apiAllinone(
          "${ApiConstants.port}/PLANING/MaxPLANINGNo", jsonEncode(payload), header, null);
          
      if (resultData != null) {
        if (resultData is String) {
          resultData = jsonDecode(resultData);
        }
        if (resultData['ok'] == true) {
           setState(() {
              _planNoCtrl.text = resultData['No']?.toString() ?? '';
           });
        }
      }
    } catch (e) {
      debugPrint("Error fetching max planning no: $e");
    }
  }

  Future<void> _deletePlanning() async {
    if (_editMasterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please load a saved planning record to delete')));
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this planning record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final url = "${ApiConstants.port}/PLANING/DeletePLANING?Id=${_editMasterId}&Comid=${AppGlobals.Comid}";
      Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8', 'Comid': AppGlobals.Comid.toString()};
      
      final resultData = await sl<LegacyApiRepository>().apiAllinone(url, {}, header, null);

      if (resultData != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Planning Deleted Successfully')));
        setState(() {
           _editMasterId = null;
                          _planningItems.clear();
                          _remarksCtrl.clear();
                          _planNoCtrl.text = '';
                          _fetchMaxPlaningNo();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete planning')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePlanningData() async {
    if (_planningItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one planning line')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final saleDetails = _planningItems.map((d) {
        // find truck id
        int truckId = 0;
        final truckList = AppGlobals.GetTruckList;
        for (var t in truckList) {
          if (t.AccountName == d['truck']) {
            truckId = t.Id;
            break;
          }
        }
        
        // find driver id
        int driverId = 0;
        final driverList = AppGlobals.GetDriverList;
        for (var dr in driverList) {
          if (dr.AccountName == d['driver']) {
            driverId = dr.Id;
            break;
          }
        }

        return {
          'Id': d['detailId'] ?? 0,
            'SortByD': d['SortByD'] ?? 0,
            'SaleOrderMasterRefId': d['saleOrderId'] ?? 0,
            'SortByD': d['SortByD'] ?? 0,
          'JobNo': d['jobNo'] ?? '',
          'JobDate': null,
          'TruckName': d['truck'] ?? '',
          'TruckRefid': truckId,
          'DriverName': d['driver'] ?? '',
          'DriverRefid': driverId,
          'SPickupDate': d['pDate'] != null ? DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(d['pDate'])) : null,
          'SDeliveryDate': d['dDate'] != null ? DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(d['dDate'])) : null,
          'Origin': d['origin'] ?? '',
          'Destination': d['destination'] ?? '',
          'PickupAddress': '',
          'DeliveryAddress': '',
          'Package': '',
          'Weight': '',
          'Remarks': _remarksCtrl.text,
        };
      }).toList();

      final payload = [{
          'Id': _editMasterId ?? 0,
          'CompanyRefId': AppGlobals.Comid,
          'UserRefId': null,
          'EmployeeRefId': null,
          'SaleDate': DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_planDate)),
          'FDate': DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_planDate)),
          'TDate': DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_planDate)),
          'CNumberDisplay': 0,
          'CNumber': 0,
          'Remarks': _remarksCtrl.text,
          'SaleDetails': saleDetails
        }];

      Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8', 'Comid': AppGlobals.Comid.toString()};
      final resultData = await sl<LegacyApiRepository>().apiAllinone(
          "${ApiConstants.port}/PLANING/InsertPLANING", jsonEncode(payload), header, null);

      if (resultData != null && resultData.toString().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_editMasterId != null ? 'Planning Updated Successfully' : 'Planning Saved Successfully')));
        setState(() {
           _editMasterId = null;
           _planningItems.clear();
           _remarksCtrl.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save planning')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  List<String> _selectedPortsList = [];

  Future<void> _showPortSelectionDialog() async {
    final List<String> tempSelected = List.from(_selectedPortsList);
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text("Select Ports"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AppGlobals.Portlist.length,
                  itemBuilder: (ctx, i) {
                    final port = AppGlobals.Portlist[i].name;
                    final isChecked = tempSelected.contains(port);
                    return CheckboxListTile(
                      title: Text(port),
                      value: isChecked,
                      onChanged: (val) {
                        setStateSB(() {
                          if (val == true) {
                            tempSelected.add(port);
                          } else {
                            tempSelected.remove(port);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPortsList = tempSelected;
                      _searchCtrl.text = _selectedPortsList.join(',');
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("DONE"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _launchSOUpdate(int saleOrderId) async {
    if (saleOrderId == 0) return;
    setState(() => _isLoading = true);
    try {
      final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final url = "${ApiConstants.apiEditSalesOrder}$saleOrderId&SaleorderNo=0&Comid=$comid";
      
      dynamic responseData = await sl<LegacyApiRepository>().apiAllinoneSelect(Uri.encodeFull(url));
      
      if (responseData is String) {
        if (responseData.trim().isEmpty) {
          setState(() => _isLoading = false);
          return;
        }
        responseData = jsonDecode(responseData);
      }
      
      if (responseData is List && responseData.isNotEmpty) {
        AppGlobals.SaleEditMasterList = responseData;
        AppGlobals.SaleEditDetailList = (responseData[0]["SaleDetails"] as List)
            .map<SaleEditDetailModel>((e) => SaleEditDetailModel.fromJson(e))
            .toList();
            
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SalesOrdersAdd(
            SaleDetails: AppGlobals.SaleEditDetailList,
            SaleMaster: AppGlobals.SaleEditMasterList,
          ),
        ));
      } else {
        setState(() => _isLoading = false);
      }
    } catch(e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load Sales Order for edit: $e')));
    }
  }
  void _searchPlanning() async {
    if (_searchCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one port')));
      return;
    }
    setState(() => _isLoading = true);
    
    try {
      final repo = sl<PlanningRepository>();
      final result = await repo.searchUnplannedOrders(
        DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_planDate)),
        DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_toDate)),
        _searchCtrl.text,
        0,
      );
      
      setState(() {
        _planningItems.clear();
        for (var item in result) {
          _planningItems.add({
            'truck': '',
            'driver': '',
            'pDate': _pickupDate,
            'dDate': _toDate,
            'origin': item['Origin']?.toString() ?? '',
            'destination': item['Destination']?.toString() ?? '',
            'customer': item['CustomerName']?.toString() ?? '',
            'jobNo': item['JobNo']?.toString() ?? '',
            'saleOrderId': item['Id'] ?? 0,
          });
        }
      });
    } catch (e) {
      if (e.toString().contains('500')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No unplanned records found for the selected criteria.")));
        setState(() => _planningItems.clear());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }



  void _loadForEdit(Map<String, dynamic> master, List<dynamic> details) {
    setState(() {
      _editMasterId = master['Id'];
      _planNoCtrl.text = master['PLANINGNoDisplay'] ?? '';
      _remarksCtrl.text = master['Remarks'] ?? '';
      _planDate = master['PLANINGDate'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now());
      
      _planningItems.clear();
      for (var d in details) {
        _planningItems.add({
          'detailId': d['Id'] ?? 0,
          'truck': d['TruckName'] ?? '',
          'driver': d['DriverName'] ?? '',
          'pDate': d['pickupdate'] ?? _pickupDate,
          'dDate': d['deliverydate'] ?? _toDate,
          'origin': d['Origin'] ?? '',
          'destination': d['Destination'] ?? '',
          'customer': d['CustomerName'] ?? '',
            'jobNo': d['JobNo'] ?? '',
            'saleOrderId': d['SaleOrderMasterRefId'] ?? 0,
          });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Planning loaded for edit")));
  }

  Future<void> _showSavedPlanningsView() async {
    String sheetFDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String sheetTDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    TextEditingController sheetSearchCtrl = TextEditingController();
    bool isLEmp = true;
    int selectedEmpId = 0;
    
    List<dynamic> masterList = [];
    List<dynamic> detailsList = [];
    bool sheetIsLoading = true;

    Future<void> fetchPlannings(StateSetter setSheetState) async {
      setSheetState(() => sheetIsLoading = true);
      try {
        final f = DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(sheetFDate));
        final t = DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(sheetTDate));
        
        int reqEmpId = isLEmp ? (AppGlobals.EmpRefId ?? 0) : selectedEmpId;
        
        final resultData = await sl<PlanningRepository>().getPlanning(f, t, sheetSearchCtrl.text, reqEmpId);
        setSheetState(() {
          if (resultData.isNotEmpty) {
            masterList = resultData[0]["salemaster"] ?? [];
            detailsList = resultData[0]["saledetails"] ?? [];
          } else {
            masterList = [];
            detailsList = [];
          }
          sheetIsLoading = false;
        });
      } catch (e) {
        setSheetState(() => sheetIsLoading = false);
      }
    }

        Widget _buildInlineDatePicker(String label, String value, StateSetter setSheetState, Function(String) onChanged) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _pickDate(context, value, (v) {
              onChanged(v);
              setSheetState(() {});
            }),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: colour.kBg,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  Icon(Icons.calendar_month, size: 18, color: colour.kCobalt),
                ],
              ),
            ),
          ),
        ],
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          if (sheetIsLoading && masterList.isEmpty) {
            fetchPlannings(setSheetState);
          }
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(color: colour.kBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("PLANING DETAILS VIEW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  ],
                ),
                const SizedBox(height: 8),
                                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildInlineDatePicker('From Date', sheetFDate, setSheetState, (v) => sheetFDate = v)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInlineDatePicker('To Date', sheetTDate, setSheetState, (v) => sheetTDate = v)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Planning No", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 40,
                                  child: TextField(
                                    controller: sheetSearchCtrl,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: colour.kBg,
                                      hintText: 'Search No...',
                                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: colour.kCobalt)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Employee", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: isLEmp,
                                            activeColor: colour.kCobalt,
                                            onChanged: (val) => setSheetState(() => isLEmp = val ?? true),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text('L.Emp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                IgnorePointer(
                                  ignoring: isLEmp,
                                  child: Opacity(
                                    opacity: isLEmp ? 0.5 : 1.0,
                                    child: InkWell(
                                      onTap: () async {
                                        await sl<PlanningRepository>().selectEmployee(context, 'sales', 'admin');
                                        if (!context.mounted) return;
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const Employee(Searchby: 1, SearchId: 0))).then((navRes) {
                                          if (navRes != null) {
                                            setSheetState(() => selectedEmpId = navRes.Id);
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: colour.kBg,
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text(selectedEmpId == 0 ? 'Select Emp...' : selectedEmpId.toString(), style: TextStyle(fontSize: 14, color: selectedEmpId == 0 ? Colors.grey.shade500 : Colors.black87), overflow: TextOverflow.ellipsis)),
                                            const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => fetchPlannings(setSheetState),
                          icon: const Icon(Icons.search, color: colour.kBg),
                          label: const Text('SEARCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colour.kCobalt,
                            foregroundColor: colour.kBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Header Row (Mocking the Table Header)
                Container(
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Row(
                    children: [
                      Expanded(flex: 3, child: Text('Plan No', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 3, child: Text('Remarks', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      SizedBox(width: 80, child: Text('ACTIONS', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                // List View
                Expanded(
                  child: sheetIsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : masterList.isEmpty
                          ? const Center(child: Text("No records found."))
                          : ListView.builder(
                              itemCount: masterList.length,
                              itemBuilder: (context, index) {
                                final m = masterList[index];
                                final mId = m['Id'];
                                final relatedDetails = detailsList.where((d) => d['PLANINGMasterRefId'] == mId).toList();

                                return Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                                    backgroundColor: colour.kGold.withOpacity(0.1),
                                    collapsedBackgroundColor: colour.kGold.withOpacity(0.4),
                                    iconColor: Colors.black,
                                    collapsedIconColor: Colors.black,
                                    title: Row(
                                      children: [
                                        Expanded(flex: 3, child: Text(m['PLANINGNoDisplay'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        Expanded(flex: 2, child: Text(m['PLANINGDate'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        Expanded(flex: 3, child: Text(m['Remarks'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                    trailing: SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.edit, color: colour.kCobalt, size: 20),
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              _loadForEdit(m, relatedDetails);
                                            },
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                                            onPressed: () {
                                            },
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.table_chart, color: Colors.green, size: 20),
                                            onPressed: () {
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      Container(
                                        color: colour.kBg,
                                        width: double.infinity,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            headingRowHeight: 30,
                                            dataRowMaxHeight: 35,
                                            dataRowMinHeight: 35,
                                            columnSpacing: 16,
                                            horizontalMargin: 8,
                                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                                            columns: const [
                                              DataColumn(label: Text('JobNo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                              DataColumn(label: Text('JobDate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                              DataColumn(label: Text('TruckName', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                              DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                            ],
                                            rows: relatedDetails.map((d) {
                                              return DataRow(cells: [
                                                DataCell(Text(d['JobNo'] ?? '', style: const TextStyle(fontSize: 12))),
                                                DataCell(Text(d['JobDate'] ?? '', style: const TextStyle(fontSize: 12))),
                                                DataCell(Text(d['TruckName'] ?? '', style: const TextStyle(fontSize: 12))),
                                                DataCell(Text(d['Remarks'] ?? '', style: const TextStyle(fontSize: 12))),
                                              ]);
                                            }).toList(),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _sortPlanningItems() {
    setState(() {
      _planningItems.sort((a, b) => (a['origin'] ?? '').compareTo(b['origin'] ?? ''));
    });
  }

  @override  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colour.kBg,
      appBar: AppBar(
        backgroundColor: colour.kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: colour.kTextDim, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ADD PLANNING',
          style: AppTypography.heading2(color: colour.kDanger),
        ),
      ),
      body: ListView(
        children: [
          // Header Form (Scrollable if needed, but bounded)
          Container(
            padding: const EdgeInsets.all(16),
            color: colour.kSurface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField('Planing No', _planNoCtrl, readOnly: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDatePicker('Planing Date', _planDate, (v) => setState(() => _planDate = v))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDatePicker('Pickup Date', _pickupDate, (v) => setState(() => _pickupDate = v))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDatePicker('To Date', _toDate, (v) => setState(() => _toDate = v))),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _showPortSelectionDialog,
                  child: IgnorePointer(
                    child: _buildTextField('Search Port', _searchCtrl),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField('Remarks', _remarksCtrl),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: colour.kBg,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildButton('SEARCH', _searchPlanning, isPrimary: true),
                  const SizedBox(width: 8),
                  _buildButton('SORT', _sortPlanningItems),
                  const SizedBox(width: 8),
                  _buildButton('NEW', () {
                      setState(() {
                        _editMasterId = null;
                          _planningItems.clear();
                          _remarksCtrl.clear();
                          _planNoCtrl.text = '';
                          _fetchMaxPlaningNo();
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildButton('SAVE', _savePlanningData, isPrimary: _editMasterId == null),
                    const SizedBox(width: 8),
                    _buildButton('UPDATE', _savePlanningData, isPrimary: _editMasterId != null),
                  const SizedBox(width: 8),
                  _buildButton('VIEW', _showSavedPlanningsView),
                  const SizedBox(width: 8),
                  _buildButton('DELETE', _deletePlanning),
                  const SizedBox(width: 8),
                  _buildButton('PUSH TO RTI', () {}),
                ],
              ),
            ),
          ),

          // Planning Items Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text("Planning Lines (${_planningItems.length})", style: AppTypography.heading3(), overflow: TextOverflow.ellipsis),
                ),
                if (_planningItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: _showBulkApplySheet,
                    icon: const Icon(Icons.done_all, color: colour.kGold, size: 20),
                    label: const Text('Bulk', style: TextStyle(color: colour.kGold, fontWeight: FontWeight.bold, fontSize: 13)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                  ),
                TextButton.icon(
                  onPressed: _showAddEditItemSheet,
                  icon: const Icon(Icons.add, color: colour.kCobalt, size: 20),
                  label: const Text('Add', style: TextStyle(color: colour.kCobalt, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                ),
              ],
            ),
          ),

          // Planning Items List
          _planningItems.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text("No planning lines added.\nTap 'Add Line' to create one.", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.grey.shade500)
                  )
                ),
              )
            : ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _planningItems.removeAt(oldIndex);
                      _planningItems.insert(newIndex, item);
                    });
                  },
                  itemCount: _planningItems.length,
                  itemBuilder: (context, index) {
                    final item = _planningItems[index];
                    return Card(
                        key: ValueKey('${item['jobNo']}_${index}'),
                        color: colour.kBg,
                        margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colour.kBorder)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text("Truck: ${item['truck'].isEmpty ? '-' : item['truck']}", style: AppTypography.heading3(color: colour.kDanger))),
                                  Container(
                                    width: 60,
                                    height: 30,
                                    margin: const EdgeInsets.only(right: 8),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                        hintText: 'Sort',
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                      onChanged: (val) {
                                        _planningItems[index]['SortByD'] = int.tryParse(val) ?? 0;
                                      },
                                      controller: TextEditingController(text: (item['SortByD'] ?? 0).toString())..selection = TextSelection.collapsed(offset: (item['SortByD'] ?? 0).toString().length),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    if ((item['saleOrderId'] ?? 0) != 0) ...[
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.assignment, size: 20, color: colour.kGold),
                                          tooltip: 'SO Update',
                                          onPressed: () => _launchSOUpdate(item['saleOrderId']),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      if ((item['saleOrderId'] ?? 0) != 0) ...[
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.assignment, size: 20, color: colour.kGold),
                                          tooltip: 'SO Update',
                                          onPressed: () => _launchSOUpdate(item['saleOrderId']),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.edit, size: 20, color: colour.kCobalt),
                                      onPressed: () => _showAddEditItemSheet(itemToEdit: item, index: index),
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () => setState(() => _planningItems.removeAt(index)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("Driver: ${item['driver'].isEmpty ? '-' : item['driver']}", style: AppTypography.bodyMedium()),
                            const SizedBox(height: 4),
                            Text("Route: ${item['origin']} \u2192 ${item['destination']}", style: AppTypography.bodySmall(color: Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Text("Dates: ${item['pDate']} to ${item['dDate']}", style: AppTypography.bodySmall(color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}






























