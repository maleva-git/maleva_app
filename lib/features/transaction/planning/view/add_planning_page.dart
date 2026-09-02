import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/features/transaction/planning/data/planning_repository.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
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
        Text(label, style: const TextStyle(color: colour.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          readOnly: readOnly,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colour.textMain),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: colour.textSub.withOpacity(0.45), fontSize: 13),
            filled: true,
            fillColor: readOnly ? colour.surface : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: colour.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: colour.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: colour.kPrimary)),
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
        backgroundColor: isPrimary ? colour.brand : Colors.white,
        foregroundColor: isPrimary ? Colors.white : colour.textMain,
        elevation: isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isPrimary ? BorderSide.none : const BorderSide(color: colour.border),
        ),
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

  
  Future<void> _pickDateTime(BuildContext context, String currentVal, Function(String) onPicked) async {
    DateTime initialDate = DateTime.now();
    if (currentVal.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy HH:mm').parse(currentVal);
      } catch (e) {
        try {
          initialDate = DateFormat('dd/MM/yyyy').parse(currentVal);
        } catch (_) {}
      }
    }
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (pickedTime != null) {
        final finalDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        onPicked(DateFormat('dd/MM/yyyy HH:mm').format(finalDateTime));
      } else {
        onPicked(DateFormat('dd/MM/yyyy HH:mm').format(DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 0, 0)));
      }
    }
  }

  Widget _buildSheetDateTimePicker(String label, String value, StateSetter setSheetState, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: colour.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _pickDateTime(context, value, (v) {
            setSheetState(() => onChanged(v));
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colour.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colour.textMain)),
                const Icon(Icons.calendar_month, size: 16, color: colour.textSub),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSaleOrderUpdateSheet(Map<String, dynamic> item, int index) {
    String sPDate = item['pDate'] ?? '';
    String sDDate = item['dDate'] ?? '';
    String sWEnter = item['wEnterDate'] ?? '';
    String sWExit = item['wExitDate'] ?? '';
    TextEditingController wAddrCtrl = TextEditingController(text: item['wAddress'] ?? '');
    
    // Add time if missing (since it's now datetime)
    if (sPDate.isNotEmpty && !sPDate.contains(':')) sPDate += " 00:00";
    if (sDDate.isNotEmpty && !sDDate.contains(':')) sDDate += " 00:00";
    if (sWEnter.isNotEmpty && !sWEnter.contains(':')) sWEnter += " 00:00";
    if (sWExit.isNotEmpty && !sWExit.contains(':')) sWExit += " 00:00";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setSheetState) {
            bool isSaving = false;

            Future<void> saveUpdate() async {
              setSheetState(() => isSaving = true);
              try {
                // Prepare payload
                // Expected payload structure according to API
                final payload = {
                  "Jobid": item['saleOrderId'] ?? 0,
                  "PickupDate": sPDate.isNotEmpty ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateFormat('dd/MM/yyyy HH:mm').parse(sPDate)) : null,
                  "DeliveryDate": sDDate.isNotEmpty ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateFormat('dd/MM/yyyy HH:mm').parse(sDDate)) : null,
                  "WareHouseEnterDate": sWEnter.isNotEmpty && sWEnter != " 00:00" ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateFormat('dd/MM/yyyy HH:mm').parse(sWEnter)) : null,
                  "WareHouseExitDate": sWExit.isNotEmpty && sWExit != " 00:00" ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateFormat('dd/MM/yyyy HH:mm').parse(sWExit)) : null,
                  "WareHouseAddress": wAddrCtrl.text,
                  "pickuptimelist": "",
                  "DeliveryDateTimeList": "",
                  "Type": 0 // 0 means SAVE ALL
                };
                
                Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8', 'Comid': AppGlobals.Comid.toString()};
                var result = await sl<LegacyApiRepository>().apiAllinone("${ApiConstants.port}/SaleOrder/UpdateSaleorder", jsonEncode(payload), header, null);
                if (result != null && result is String) {
                  result = jsonDecode(result);
                }
                
                if (result != null && result['ok'] == true) {
                  // Update local list
                  setState(() {
                    _planningItems[index]['pDate'] = sPDate;
                    _planningItems[index]['dDate'] = sDDate;
                    _planningItems[index]['wEnterDate'] = sWEnter;
                    _planningItems[index]['wExitDate'] = sWExit;
                    _planningItems[index]['wAddress'] = wAddrCtrl.text;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale Order Updated Successfully')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update Sale Order')));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                if (mounted) setSheetState(() => isSaving = false);
              }
            }

            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              decoration: const BoxDecoration(
                color: colour.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Sale Order Update", style: AppTypography.heading2(color: colour.textMain)),
                    const SizedBox(height: 16),
                    _buildSheetTextField("Job No", item['jobNo'] ?? '', (v){}),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildSheetDateTimePicker("Pickup Date", sPDate, setSheetState, (v) => sPDate = v)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildSheetDateTimePicker("Delivery Date", sDDate, setSheetState, (v) => sDDate = v)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildSheetDateTimePicker("Warehouse Entry Date", sWEnter, setSheetState, (v) => sWEnter = v)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildSheetDateTimePicker("Warehouse Exit Date", sWExit, setSheetState, (v) => sWExit = v)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSheetTextField("Warehouse Address", wAddrCtrl.text, (v) => wAddrCtrl.text = v),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : saveUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colour.brand,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("SAVE ALL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
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
            color: Colors.transparent,
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
            fillColor: Colors.transparent,
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
              color: Colors.transparent,
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
              'wEnterDate': item['SWareHouseEnterDate']?.toString() ?? '',
              'wExitDate': item['SWareHouseExitDate']?.toString() ?? '',
              'wAddress': item['WareHouseAddress']?.toString() ?? '',
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
            'wEnterDate': d['SWareHouseEnterDate']?.toString() ?? '',
            'wExitDate': d['SWareHouseExitDate']?.toString() ?? '',
            'wAddress': d['WareHouseAddress']?.toString() ?? '',
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
      _planningItems.sort((a, b) {
        int sortA = (a['SortByD'] is int) ? a['SortByD'] : int.tryParse(a['SortByD'].toString()) ?? 0;
        int sortB = (b['SortByD'] is int) ? b['SortByD'] : int.tryParse(b['SortByD'].toString()) ?? 0;
        return sortA.compareTo(sortB);
      });
    });
  }

  @override  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colour.surface,
      appBar: const CustomGradientAppBar(title: 'ADD PLANNING', showBackButton: true),
      body: ListView(
        children: [
          // Header Form (Scrollable if needed, but bounded)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.transparent,
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
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                  dataRowMinHeight: 35,
                  dataRowMaxHeight: 45,
                  columnSpacing: 16,
                  horizontalMargin: 16,
                  columns: const [
                    DataColumn(label: Text('Select', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Sort', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('REMARKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('TRUCK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('DRIVER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('P.Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('D.Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('ORIGIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('DESTINATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('CUSTOMER NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('PACKAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: _planningItems.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var item = entry.value;
                    bool isSelected = item['selected'] ?? false;
                    
                    return DataRow(
                      cells: [
                        DataCell(
                          Checkbox(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                item['selected'] = val;
                              });
                            }
                          )
                        ),
                        DataCell(Text('${idx + 1}', style: const TextStyle(fontSize: 12))),
                        DataCell(
                          SizedBox(
                            width: 50,
                            height: 30,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              onChanged: (val) {
                                item['SortByD'] = int.tryParse(val) ?? 0;
                              },
                              controller: TextEditingController(text: (item['SortByD'] ?? 0).toString())..selection = TextSelection.collapsed(offset: (item['SortByD'] ?? 0).toString().length),
                            )
                          )
                        ),
                        DataCell(Text(item['remarks']?.toString() ?? '', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(item['truck']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: colour.kGold), overflow: TextOverflow.ellipsis)),
                        DataCell(Text(item['driver']?.toString() ?? '', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                        DataCell(Text(item['pDate']?.toString() ?? '', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(item['dDate']?.toString() ?? '', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(item['origin']?.toString() ?? '', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(item['destination']?.toString() ?? '', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(item['customer']?.toString() ?? '', style: const TextStyle(fontSize: 12))),
                        DataCell(Text('-', style: const TextStyle(fontSize: 12))), // PACKAGE is not collected in UI currently
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if ((item['saleOrderId'] ?? 0) != 0)
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  icon: const Icon(Icons.assignment, size: 16, color: colour.kGold),
                                  tooltip: 'SO Update',
                                  onPressed: () => _launchSOUpdate(item['saleOrderId']),
                                ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                icon: const Icon(Icons.edit, size: 16, color: colour.kCobalt),
                                onPressed: () => _showAddEditItemSheet(itemToEdit: item, index: idx),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                icon: const Icon(Icons.update, size: 16, color: Colors.green),
                                onPressed: () => _showSaleOrderUpdateSheet(item, idx),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                onPressed: () => setState(() => _planningItems.removeAt(idx)),
                              ),
                            ]
                          )
                        ),
                      ]
                    );
                  }).toList(),
                ),
              ),
        ],
      ),
    );
  }
}



































