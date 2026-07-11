import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/colors/colors.dart' as colour;
import '../../../../../core/theme/tokens.dart';

const kGradient = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, colour.kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class VesselPlanningFilterSheet extends StatefulWidget {
  final Function(
    String fromDate,
    String toDate,
    int etaType,
    String searchPorts,
    bool deliveryDone,
  ) onSearch;

  const VesselPlanningFilterSheet({super.key, required this.onSearch});

  @override
  _VesselPlanningFilterSheetState createState() => _VesselPlanningFilterSheetState();
}

class _VesselPlanningFilterSheetState extends State<VesselPlanningFilterSheet> {
  late TextEditingController _fromDateController;
  late TextEditingController _toDateController;
  late TextEditingController _searchPortController;
  
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  int _etaType = 3; // 1: OETA, 2: ETA, 3: Both
  bool _deliveryDone = true;

  @override
  void initState() {
    super.initState();
    _fromDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_fromDate));
    _toDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_toDate));
    _searchPortController = TextEditingController();
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _searchPortController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
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
        if (isFrom) {
          _fromDate = picked;
          _fromDateController.text = DateFormat('yyyy-MM-dd').format(_fromDate);
        } else {
          _toDate = picked;
          _toDateController.text = DateFormat('yyyy-MM-dd').format(_toDate);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 0,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 18),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTokens.maintCardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Text(
              'Filter Vessel Planning',
              style: GoogleFonts.lato(
                color: AppTokens.invoiceHeaderStart,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _SheetDateTile(
                    label: 'From',
                    date: _fromDateController.text,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetDateTile(
                    label: 'To',
                    date: _toDateController.text,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'ETA Type',
              style: GoogleFonts.lato(
                color: colour.kTextDark,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildEtaTypeChip(1, 'OETA'),
                const SizedBox(width: 8),
                _buildEtaTypeChip(2, 'ETA'),
                const SizedBox(width: 8),
                _buildEtaTypeChip(3, 'Both'),
              ],
            ),
            const SizedBox(height: 16),

            _SheetTextField(
              controller: _searchPortController,
              hint: 'Search Ports (e.g. PKG, PEN)',
              icon: Icons.search_rounded,
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: () => setState(() => _deliveryDone = !_deliveryDone),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: _deliveryDone ? kGradient : null,
                        border: _deliveryDone
                            ? null
                            : Border.all(color: AppTokens.maintCardBorder, width: 1.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: _deliveryDone
                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Exclude Delivery Done / Completed',
                      style: GoogleFonts.lato(
                        color: colour.kTextDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GradientButton(
                  label: 'Search',
                  onPressed: () {
                    widget.onSearch(
                      _fromDateController.text,
                      _toDateController.text,
                      _etaType,
                      _searchPortController.text,
                      _deliveryDone,
                    );
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 12),
                _OutlineButton(
                  label: 'Clear',
                  onPressed: () {
                    setState(() {
                      _etaType = 3;
                      _searchPortController.clear();
                      _deliveryDone = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildEtaTypeChip(int value, String label) {
    bool isSelected = _etaType == value;
    return InkWell(
      onTap: () => setState(() => _etaType = value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? kGradient : null,
          color: isSelected ? null : colour.kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : AppTokens.maintCardBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: isSelected ? Colors.white : colour.kTextDark,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SheetDateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _SheetDateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colour.kCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokens.maintCardBorder, width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: colour.kHeaderGradEnd, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
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
                    date,
                    style: GoogleFonts.lato(
                      color: colour.kTextDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colour.kCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTokens.maintCardBorder, width: 0.8),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.lato(
          color: colour.kTextDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(
            color: AppTokens.planTextMuted,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: Icon(icon, color: colour.kHeaderGradEnd, size: 20),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 42,
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTokens.invoiceHeaderStart.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 42,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: colour.kTextDark,
          side: const BorderSide(color: AppTokens.invoiceHeaderStart, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
