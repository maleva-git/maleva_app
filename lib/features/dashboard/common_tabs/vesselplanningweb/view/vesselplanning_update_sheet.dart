import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/vesselplanningweb_model.dart';
import '../../../../../core/utils/app_globals.dart';
import '../../../../../core/colors/colors.dart' as colour;
import '../../../../../core/theme/tokens.dart';
import '../../../../mastersearch/Employee.dart';
import '../../../../../core/models/model.dart';
import '../../../../../core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/shared/employee_model.dart';

const _kGrad = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, colour.kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class VesselPlanningUpdateSheet extends StatefulWidget {
  final VesselPlanningWebModel jobData;
  final Function(Map<String, dynamic>) onUpdate;

  const VesselPlanningUpdateSheet({
    super.key,
    required this.jobData,
    required this.onUpdate,
  });

  @override
  _VesselPlanningUpdateSheetState createState() => _VesselPlanningUpdateSheetState();
}

class _VesselPlanningUpdateSheetState extends State<VesselPlanningUpdateSheet> {
  late TextEditingController _ptwController;
  late TextEditingController _etbController;
  late TextEditingController _etdController;
  late TextEditingController _oetbController;
  late TextEditingController _oetdController;

  bool _etbChecked = false;
  bool _etdChecked = false;
  bool _oetbChecked = false;
  bool _oetdChecked = false;

  EmployeeModel? _bo1;
  EmployeeModel? _bo2;

  @override
  void initState() {
    super.initState();
    final d = widget.jobData;
    _ptwController = TextEditingController(text: d.ptw);
    _etbController = TextEditingController(text: d.setb.isNotEmpty ? d.setb : d.etb);
    _etdController = TextEditingController(text: d.setd.isNotEmpty ? d.setd : d.etd);
    _oetbController = TextEditingController(text: d.soetb.isNotEmpty ? d.soetb : d.oetb);
    _oetdController = TextEditingController(text: d.soetd.isNotEmpty ? d.soetd : d.oetd);

    if (d.boardingOfficerRefid > 0) {
      _bo1 = EmployeeModel(d.boardingOfficerRefid, d.boardingOfficerName.isNotEmpty ? d.boardingOfficerName : 'Select Employee', '');
    }
    if (d.boardingOfficer1Refid > 0) {
      _bo2 = EmployeeModel(d.boardingOfficer1Refid, d.boardingOfficerName1.isNotEmpty ? d.boardingOfficerName1 : 'Select Employee', '');
    }

    _etbChecked = _etbController.text.isNotEmpty;
    _etdChecked = _etdController.text.isNotEmpty;
    _oetbChecked = _oetbController.text.isNotEmpty;
    _oetdChecked = _oetdController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _ptwController.dispose();
    _etbController.dispose();
    _etdController.dispose();
    _oetbController.dispose();
    _oetdController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context, TextEditingController ctrl, Function(bool) onDateSet) async {
    DateTime initial = DateTime.now();
    try {
      initial = DateFormat('dd/MM/yyyy HH:mm').parse(ctrl.text);
    } catch (_) {
      try {
        initial = DateFormat('yyyy/MM/dd HH:mm:ss').parse(ctrl.text);
      } catch (_) {
        try {
          initial = DateTime.parse(ctrl.text);
        } catch (_) {}
      }
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
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
    if (date == null || !mounted) return;

    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTokens.invoiceHeaderStart,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      ctrl.text = DateFormat('dd/MM/yyyy HH:mm').format(combined);
      onDateSet(true);
    });
  }

  void _submitUpdate() {
    final Map<String, dynamic> updateData = {
      "Jobid": widget.jobData.saleOrderMasterRefId,
      "PTW": _ptwController.text,
      "ETB": _etbChecked && _etbController.text.isNotEmpty ? _formatForApi(_etbController.text) : null,
      "ETD": _etdChecked && _etdController.text.isNotEmpty ? _formatForApi(_etdController.text) : null,
      "OETB": _oetbChecked && _oetbController.text.isNotEmpty ? _formatForApi(_oetbController.text) : null,
      "OETD": _oetdChecked && _oetdController.text.isNotEmpty ? _formatForApi(_oetdController.text) : null,
      "BoardingOfficerRefid": _bo1?.Id,
      "BoardingOfficer1Refid": _bo2?.Id,
      "Comid": AppGlobals.Comid,
      "Type": 100, // SAVE ALL
    };

    widget.onUpdate(updateData);
    Navigator.pop(context);
  }
  
  String _formatForApi(String displayDate) {
    try {
        final parsed = DateFormat('dd/MM/yyyy HH:mm').parse(displayDate);
        return DateFormat('yyyy/MM/dd HH:mm:ss').format(parsed);
    } catch (_) {
        return displayDate;
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.95),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTokens.maintCardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sale Order Update',
                    style: GoogleFonts.lato(
                      color: colour.kTextDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTokens.planTextMuted, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 0.5),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow('Job No', Container(
                    height: 36,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTokens.maintCardBorder),
                      borderRadius: BorderRadius.circular(4),
                      color: colour.kCardBg,
                    ),
                    child: Text(
                      widget.jobData.jobNo.isNotEmpty ? widget.jobData.jobNo : widget.jobData.saleOrderMasterRefId.toString(),
                      style: GoogleFonts.lato(fontSize: 13, color: colour.kTextDark),
                    ),
                  ), null, null),
                  const SizedBox(height: 8),
                  
                  _buildDateTimeRow('ETB', _etbController, _etbChecked, (v) => setState(() => _etbChecked = v)),
                  const SizedBox(height: 8),
                  
                  _buildDateTimeRow('ETD', _etdController, _etdChecked, (v) => setState(() => _etdChecked = v)),
                  const SizedBox(height: 8),

                  _buildDateTimeRow('L ETB', _oetbController, _oetbChecked, (v) => setState(() => _oetbChecked = v)),
                  const SizedBox(height: 8),

                  _buildDateTimeRow('L ETD', _oetdController, _oetdChecked, (v) => setState(() => _oetdChecked = v)),
                  const SizedBox(height: 8),

                  _buildEmployeeRow('BOARDING\nOFFICER 1', _bo1, (emp) => setState(() => _bo1 = emp), true),
                  const SizedBox(height: 8),

                  _buildEmployeeRow('BOARDING\nOFFICER 2', _bo2, (emp) => setState(() => _bo2 = emp), false),
                  const SizedBox(height: 8),

                  _buildRow('PTW', SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _ptwController,
                      style: GoogleFonts.lato(fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: AppTokens.maintCardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: AppTokens.maintCardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: AppTokens.invoiceHeaderStart),
                        ),
                      ),
                    ),
                  ), null, true),
                  
                  const SizedBox(height: 20),
                  
                  Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: _kGrad,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppTokens.invoiceHeaderStart.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: _submitUpdate,
                        child: Center(
                          child: Text(
                            'SAVE ALL',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDisplayDate(String txt) {
      if(txt.isEmpty) return txt;
      try {
          final parsed = DateFormat('yyyy/MM/dd HH:mm:ss').parse(txt);
          return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
      } catch(_) {
          try {
              final parsed = DateTime.parse(txt);
              return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
          } catch(_) {
              return txt;
          }
      }
  }

  Widget _buildDateTimeRow(String label, TextEditingController ctrl, bool isChecked, Function(bool) onChanged) {
    return _buildRow(
      label,
      GestureDetector(
        onTap: () => _pickDateTime(context, ctrl, (v) => onChanged(v)),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: AppTokens.maintCardBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    _formatDisplayDate(ctrl.text),
                    style: GoogleFonts.lato(fontSize: 13, color: colour.kTextDark),
                  ),
                ),
              ),
              Container(
                width: 50,
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppTokens.maintCardBorder)),
                  color: colour.kCardBg,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.calendar_month, size: 14, color: AppTokens.planTextMuted),
                    Icon(Icons.access_time, size: 14, color: AppTokens.planTextMuted),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      Checkbox(
        value: isChecked,
        onChanged: (v) => onChanged(v ?? false),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        activeColor: AppTokens.invoiceHeaderStart,
        side: const BorderSide(color: AppTokens.planTextMuted),
      ),
      true
    );
  }

  Widget _buildEmployeeRow(String label, EmployeeModel? emp, Function(EmployeeModel?) onSelected, bool hasSave) {
    return _buildRow(
      label,
      GestureDetector(
        onTap: () async {
          await OnlineApi.SelectEmployee(context, 'Sales', '');
          if (!mounted) return;
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const Employee(Searchby: 1, SearchId: 0)));
          if (res != null && res is EmployeeModel) {
            onSelected(res);
          }
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: AppTokens.maintCardBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    emp?.AccountName ?? 'Select Employee',
                    style: GoogleFonts.lato(fontSize: 13, color: emp == null ? AppTokens.planTextMuted : colour.kTextDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.arrow_drop_down, color: AppTokens.planTextMuted),
              )
            ],
          ),
        ),
      ),
      null,
      hasSave
    );
  }

  Widget _buildRow(String label, Widget child, Widget? checkbox, bool? hasSave) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label.replaceAll(r'\n', '\n'),
            style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: colour.kTextDark),
          ),
        ),
        Expanded(child: child),
        SizedBox(
          width: 32,
          child: checkbox != null ? Center(child: checkbox) : const SizedBox.shrink(),
        ),
        if (hasSave == true)
          Container(
            width: 70,
            height: 32,
            decoration: BoxDecoration(
              gradient: _kGrad,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppTokens.invoiceHeaderStart.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: _submitUpdate,
                child: Center(
                  child: Text(
                    'SAVE',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          const SizedBox(width: 70), // Empty space for alignment
      ],
    );
  }
}
