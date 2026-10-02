import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../models/vesselplanningweb_model.dart';

import '../../../../../core/theme/tokens.dart';
import '../../../../mastersearch/Employee.dart';
import '../../../../../core/models/model.dart';

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

/// The job update of the Vessel Planning web window (as the web's Update window): PTW, cargo,
/// the six vessel dates (an unticked date is cleared) and the three loading and three
/// off-vessel boarding officers. Saved with `POST /api/vessel-plannings/sale-order-update`.
class _VesselPlanningUpdateSheetState extends State<VesselPlanningUpdateSheet> {
  late TextEditingController _ptwController;
  late TextEditingController _cargoController;

  // ETA, ETB, ETD (loading vessel) and OETA, OETB, OETD (off vessel), in this order
  static const _dateLabels = ['L ETA', 'L ETB', 'L ETD', 'O ETA', 'O ETB', 'O ETD'];
  static const _dateKeys = ['eta', 'etb', 'etd', 'oeta', 'oetb', 'oetd'];
  late final List<TextEditingController> _dates;
  late final List<bool> _dateTicked;

  late final List<EmployeeModel?> _loading;
  late final List<EmployeeModel?> _off;

  @override
  void initState() {
    super.initState();
    final d = widget.jobData;
    _ptwController = TextEditingController(text: d.ptw);
    _cargoController = TextEditingController(text: d.cargo);
    String first(String a, String b) => a.isNotEmpty ? a : b;
    _dates = [
      TextEditingController(text: first(d.seta, d.eta)),
      TextEditingController(text: first(d.setb, d.etb)),
      TextEditingController(text: first(d.setd, d.etd)),
      TextEditingController(text: first(d.soeta, d.oeta)),
      TextEditingController(text: first(d.soetb, d.oetb)),
      TextEditingController(text: first(d.soetd, d.oetd)),
    ];
    _dateTicked = [for (final c in _dates) c.text.isNotEmpty];
    EmployeeModel? officer(int id, String name) => id > 0 ? EmployeeModel(id, name.isNotEmpty ? name : 'Employee $id', '') : null;
    _loading = [for (var i = 0; i < 3; i++) officer(d.loadingOfficerIds[i], d.loadingOfficerNames[i])];
    _off = [for (var i = 0; i < 3; i++) officer(d.offOfficerIds[i], d.offOfficerNames[i])];
  }

  @override
  void dispose() {
    _ptwController.dispose();
    _cargoController.dispose();
    for (final c in _dates) {
      c.dispose();
    }
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
        } catch (e, stack) { debugPrint("Error caught globally: $e\n$stack"); }
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
    final updateData = <String, dynamic>{
      'saleOrderId': widget.jobData.saleOrderMasterRefId,
      'ptw': _ptwController.text.trim(),
      'cargo': _cargoController.text.trim(),
      for (var i = 0; i < _dates.length; i++)
        _dateKeys[i]: _dateTicked[i] && _dates[i].text.isNotEmpty ? _formatForApi(_dates[i].text) : '',
      'loadingOfficers': [for (final e in _loading) e?.Id ?? 0],
      'offOfficers': [for (final e in _off) e?.Id ?? 0],
    };

    widget.onUpdate(updateData);
    Navigator.pop(context);
  }

  /// "yyyy-MM-dd HH:mm:ss" for the server, from the shown or the server's form.
  String _formatForApi(String value) {
    for (final pattern in ['dd/MM/yyyy HH:mm', 'yyyy/MM/dd HH:mm:ss']) {
      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateFormat(pattern).parseStrict(value));
      } catch (_) {}
    }
    final parsed = DateTime.tryParse(value);
    return parsed == null ? '' : DateFormat('yyyy-MM-dd HH:mm:ss').format(parsed);
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
                    style: AppTypography.heading1(color: colour.kTextDark, fontWeight: FontWeight.w700),
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
                      style: AppTypography.bodyLarge(color: colour.kTextDark),
                    ),
                  ), null, null),
                  const SizedBox(height: 8),
                  
                  for (var i = 0; i < _dates.length; i++) ...[
                    _buildDateTimeRow(_dateLabels[i], _dates[i], _dateTicked[i], (v) => setState(() => _dateTicked[i] = v)),
                    const SizedBox(height: 8),
                  ],
                  for (var i = 0; i < 3; i++) ...[
                    _buildEmployeeRow('LOADING\nOFFICER ${i + 1}', _loading[i], (emp) => setState(() => _loading[i] = emp), false),
                    const SizedBox(height: 8),
                  ],
                  for (var i = 0; i < 3; i++) ...[
                    _buildEmployeeRow('OFF VESSEL\nOFFICER ${i + 1}', _off[i], (emp) => setState(() => _off[i] = emp), false),
                    const SizedBox(height: 8),
                  ],
                  _buildRow('CARGO', SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _cargoController,
                      style: AppTypography.bodyLarge(),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: AppTokens.maintCardBorder),
                        ),
                      ),
                    ),
                  ), null, false),
                  const SizedBox(height: 8),

                  _buildRow('PTW', SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _ptwController,
                      style: AppTypography.bodyLarge(),
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
                            style: AppTypography.heading3(color: Colors.white, fontWeight: FontWeight.w800),
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
                    style: AppTypography.bodyLarge(color: colour.kTextDark),
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
          await sl<LegacyApiRepository>().SelectEmployee(context, 'Sales', '');
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
                    style: AppTypography.bodyLarge(color: emp == null ? AppTokens.planTextMuted : colour.kTextDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
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
            style: AppTypography.bodyMedium(color: colour.kTextDark, fontWeight: FontWeight.w600),
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
                    style: AppTypography.bodyMedium(color: Colors.white, fontWeight: FontWeight.w700),
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
