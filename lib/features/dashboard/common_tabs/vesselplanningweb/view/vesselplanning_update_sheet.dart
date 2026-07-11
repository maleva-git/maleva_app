import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/vesselplanningweb_model.dart';
import '../../../../../core/utils/app_globals.dart';
import '../../../../../core/colors/colors.dart' as colour;
import '../../../../../core/theme/tokens.dart';

const _kGrad = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, colour.kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class VesselPlanningUpdateSheet extends StatefulWidget {
  final VesselPlanningWebModel jobData;
  final Function(List<Map<String, dynamic>>) onUpdate;

  const VesselPlanningUpdateSheet(
      {super.key, required this.jobData, required this.onUpdate});

  @override
  _VesselPlanningUpdateSheetState createState() =>
      _VesselPlanningUpdateSheetState();
}

class _VesselPlanningUpdateSheetState
    extends State<VesselPlanningUpdateSheet> {
  late TextEditingController _ptwController;
  late TextEditingController _etbController;
  late TextEditingController _etdController;
  late TextEditingController _detaController;
  late TextEditingController _etaController;
  late TextEditingController _oetaController;
  late TextEditingController _oetbController;
  late TextEditingController _oetdController;
  late TextEditingController _boardingAmtController;
  late TextEditingController _boardingAmt1Controller;
  late TextEditingController _boardingOfficerController;
  late TextEditingController _boardingOfficer1Controller;
  late TextEditingController _remarksController;

  // Specific updates
  late TextEditingController _pickupDateCtrl;
  late TextEditingController _deliveryDateCtrl;
  late TextEditingController _whEnterCtrl;
  late TextEditingController _whExitCtrl;
  late TextEditingController _whAddressCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.jobData;
    _ptwController = TextEditingController(text: d.ptw);
    _etbController = TextEditingController(text: d.setb.isNotEmpty ? d.setb : d.etb);
    _etdController = TextEditingController(text: d.setd.isNotEmpty ? d.setd : d.etd);
    _detaController = TextEditingController(text: d.deta);
    _etaController = TextEditingController(text: d.seta.isNotEmpty ? d.seta : d.eta);
    _oetaController = TextEditingController(text: d.soeta);
    _oetbController = TextEditingController(text: d.soetb);
    _oetdController = TextEditingController(text: d.soetd);
    _boardingAmtController = TextEditingController(text: d.boardingAmount > 0 ? d.boardingAmount.toString() : '');
    _boardingAmt1Controller = TextEditingController(text: d.boardingAmount1 > 0 ? d.boardingAmount1.toString() : '');
    _boardingOfficerController = TextEditingController(text: d.boardingOfficerName);
    _boardingOfficer1Controller = TextEditingController(text: d.boardingOfficerName1);
    _remarksController = TextEditingController(text: d.remarks);

    _pickupDateCtrl = TextEditingController();
    _deliveryDateCtrl = TextEditingController();
    _whEnterCtrl = TextEditingController();
    _whExitCtrl = TextEditingController();
    _whAddressCtrl = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [
      _ptwController, _etbController, _etdController, _detaController,
      _etaController, _oetaController, _oetbController, _oetdController,
      _boardingAmtController, _boardingAmt1Controller,
      _boardingOfficerController, _boardingOfficer1Controller, _remarksController,
      _pickupDateCtrl, _deliveryDateCtrl, _whEnterCtrl, _whExitCtrl, _whAddressCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime(
      BuildContext context, TextEditingController ctrl) async {
    DateTime initial = DateTime.now();
    try {
      // Try parsing existing value
      initial = DateFormat('yyyy-MM-dd HH:mm:ss').parse(ctrl.text);
    } catch (_) {
      try {
        initial = DateTime.parse(ctrl.text);
      } catch (_) {}
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

    // ignore: use_build_context_synchronously
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

    final combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    ctrl.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
  }

  void _submitUpdate(int type) {
    final updateList = [
      {
        "Id": widget.jobData.saleOrderMasterRefId,
        "PTW": _ptwController.text,
        "BoardingOfficeName": _boardingOfficerController.text,
        "BoardingOfficeName1": _boardingOfficer1Controller.text,
        "BoardingAmount": double.tryParse(_boardingAmtController.text) ?? 0,
        "BoardingAmount1": double.tryParse(_boardingAmt1Controller.text) ?? 0,
        "ETA": _etaController.text.isNotEmpty ? _etaController.text : null,
        "ETB": _etbController.text.isNotEmpty ? _etbController.text : null,
        "ETD": _etdController.text.isNotEmpty ? _etdController.text : null,
        "DETA": _detaController.text.isNotEmpty ? _detaController.text : null,
        "OETA": _oetaController.text.isNotEmpty ? _oetaController.text : null,
        "OETB": _oetbController.text.isNotEmpty ? _oetbController.text : null,
        "OETD": _oetdController.text.isNotEmpty ? _oetdController.text : null,
        "Remarks": _remarksController.text,
        "BoardingOfficerRefid": widget.jobData.boardingOfficerRefid > 0
            ? widget.jobData.boardingOfficerRefid
            : null,
        "BoardingOfficer1Refid": widget.jobData.boardingOfficer1Refid > 0
            ? widget.jobData.boardingOfficer1Refid
            : null,
        "Comid": AppGlobals.Comid,
        "Type": type,
      }
    ];

    widget.onUpdate(updateList);
    Navigator.pop(context);
  }

  void _submitSpecificUpdate(int type, String value) {
    if (value.trim().isEmpty) {
      msgshow('Please enter a value', "", Colors.white, Colors.red, null, 14, AppGlobals.tls, AppGlobals.tgc, context, 2);
      return;
    }
    final updateList = [
      {
        "Id": widget.jobData.saleOrderMasterRefId,
        "Type": type,
        if (type == 1) "PickupDate": value,
        if (type == 2) "DeliveryDate": value,
        if (type == 3) "WHEnter": value,
        if (type == 4) "WHExit": value,
        if (type == 5) "WHAddress": value,
        "Comid": AppGlobals.Comid,
      }
    ];
    widget.onUpdate(updateList);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.jobData;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle & Header ──────────────────────────────────────────
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Job',
                        style: GoogleFonts.lato(
                          color: AppTokens.invoiceHeaderStart,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.jobNo.isNotEmpty ? d.jobNo : 'Job #${d.saleOrderMasterRefId}',
                        style: GoogleFonts.lato(
                          color: colour.kHeaderGradEnd,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: _kGrad,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _submitUpdate(100),
                    icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    tooltip: 'Save',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppTokens.planTextMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 0.5),
          // ── Scrollable Fields ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Info (read-only banner)
                  _InfoBanner(data: d),
                  const SizedBox(height: 20),

                  _SectionTitle('ETA / ETB / ETD'),
                  const SizedBox(height: 10),
                  _DateTimeField(label: 'ETA', controller: _etaController, onTap: () => _pickDateTime(context, _etaController)),
                  const SizedBox(height: 12),
                  _DateTimeField(label: 'DETA (Actual ETA)', controller: _detaController, onTap: () => _pickDateTime(context, _detaController)),
                  const SizedBox(height: 12),
                  _DateTimeField(label: 'ETB (Berthing)', controller: _etbController, onTap: () => _pickDateTime(context, _etbController)),
                  const SizedBox(height: 12),
                  _DateTimeField(label: 'ETD (Departure)', controller: _etdController, onTap: () => _pickDateTime(context, _etdController)),
                  const SizedBox(height: 20),

                  _SectionTitle('Original ETA / ETB / ETD'),
                  const SizedBox(height: 10),
                  _DateTimeField(label: 'OETA', controller: _oetaController, onTap: () => _pickDateTime(context, _oetaController)),
                  const SizedBox(height: 12),
                  _DateTimeField(label: 'OETB', controller: _oetbController, onTap: () => _pickDateTime(context, _oetbController)),
                  const SizedBox(height: 12),
                  _DateTimeField(label: 'OETD', controller: _oetdController, onTap: () => _pickDateTime(context, _oetdController)),
                  const SizedBox(height: 20),

                  _SectionTitle('PTW & Boarding'),
                  const SizedBox(height: 10),
                  _SheetTextField(label: 'PTW', controller: _ptwController),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _SheetTextField(label: 'Boarding Officer 1', controller: _boardingOfficerController)),
                      const SizedBox(width: 10),
                      Expanded(child: _SheetTextField(label: 'Amount 1', controller: _boardingAmtController, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _SheetTextField(label: 'Boarding Officer 2', controller: _boardingOfficer1Controller)),
                      const SizedBox(width: 10),
                      Expanded(child: _SheetTextField(label: 'Amount 2', controller: _boardingAmt1Controller, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _SectionTitle('Remarks'),
                  const SizedBox(height: 10),
                  _SheetTextField(
                    label: 'Remarks',
                    controller: _remarksController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  _SectionTitle('Specific Updates'),
                  const SizedBox(height: 10),
                  _SpecificUpdateRow(
                    label: 'Pickup Date',
                    controller: _pickupDateCtrl,
                    onTapField: () => _pickDateTime(context, _pickupDateCtrl),
                    onUpdate: () => _submitSpecificUpdate(1, _pickupDateCtrl.text),
                  ),
                  const SizedBox(height: 12),
                  _SpecificUpdateRow(
                    label: 'Delivery Date',
                    controller: _deliveryDateCtrl,
                    onTapField: () => _pickDateTime(context, _deliveryDateCtrl),
                    onUpdate: () => _submitSpecificUpdate(2, _deliveryDateCtrl.text),
                  ),
                  const SizedBox(height: 12),
                  _SpecificUpdateRow(
                    label: 'WH Enter',
                    controller: _whEnterCtrl,
                    onTapField: () => _pickDateTime(context, _whEnterCtrl),
                    onUpdate: () => _submitSpecificUpdate(3, _whEnterCtrl.text),
                  ),
                  const SizedBox(height: 12),
                  _SpecificUpdateRow(
                    label: 'WH Exit',
                    controller: _whExitCtrl,
                    onTapField: () => _pickDateTime(context, _whExitCtrl),
                    onUpdate: () => _submitSpecificUpdate(4, _whExitCtrl.text),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _SheetTextField(label: 'WH Address', controller: _whAddressCtrl),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _submitSpecificUpdate(5, _whAddressCtrl.text),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            gradient: _kGrad,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _kGrad,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTokens.invoiceHeaderStart.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _submitUpdate(100),
                        icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                        label: Text(
                          'Save Changes',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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
}

// ─── Info Banner ─────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final VesselPlanningWebModel data;
  const _InfoBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.invoiceHeaderStart.withValues(alpha: 0.08),
            colour.kHeaderGradEnd.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTokens.invoiceHeaderStart.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(icon: Icons.work_outline_rounded, label: 'Job Name', value: data.jobName),
          if (data.customerName.isNotEmpty)
            _InfoRow(icon: Icons.person_outline_rounded, label: 'Customer', value: data.customerName),
          if (data.jobStatus.isNotEmpty)
            _InfoRow(icon: Icons.info_outline_rounded, label: 'Status', value: data.jobStatus, valueColor: AppTokens.statusSuccess),
          if (data.sPort.isNotEmpty || data.oPort.isNotEmpty)
            _InfoRow(icon: Icons.location_on_outlined, label: 'Port', value: data.sPort.isNotEmpty ? data.sPort : data.oPort),
          if (data.vessel.isNotEmpty)
            _InfoRow(icon: Icons.directions_boat_outlined, label: 'Vessel', value: data.vessel),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: colour.kHeaderGradEnd),
          const SizedBox(width: 6),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: AppTokens.planTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: valueColor ?? colour.kTextDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            gradient: _kGrad,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.lato(
            color: AppTokens.invoiceHeaderStart,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ─── DateTime Field ───────────────────────────────────────────────────────────
class _DateTimeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  const _DateTimeField({required this.label, required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colour.kCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokens.maintCardBorder, width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                color: colour.kHeaderGradEnd, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, val, __) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.lato(
                          color: AppTokens.planTextMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        val.text.isNotEmpty ? val.text : 'Tap to select',
                        style: GoogleFonts.lato(
                          color: val.text.isNotEmpty
                              ? colour.kTextDark
                              : AppTokens.planTextMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Icon(Icons.edit_calendar_rounded,
                size: 16, color: AppTokens.planTextMuted),
          ],
        ),
      ),
    );
  }
}

// ─── Text Field ───────────────────────────────────────────────────────────────
class _SheetTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool isNumber;
  const _SheetTextField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters:
          isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null,
      style: GoogleFonts.lato(
        color: colour.kTextDark,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(
          color: AppTokens.planTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: colour.kCardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppTokens.maintCardBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: AppTokens.invoiceHeaderStart, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Specific Update Row ──────────────────────────────────────────────────────
class _SpecificUpdateRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTapField;
  final VoidCallback onUpdate;
  const _SpecificUpdateRow({
    required this.label,
    required this.controller,
    required this.onTapField,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _DateTimeField(
            label: label,
            controller: controller,
            onTap: onTapField,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onUpdate,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTokens.invoiceHeaderStart, colour.kHeaderGradEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
