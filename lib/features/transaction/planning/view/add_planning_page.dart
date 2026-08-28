import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/theme/app_typography.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/widgets/maleva_widget/maleva_grid.dart';

class AddPlanningPage extends StatefulWidget {
  const AddPlanningPage({super.key});

  @override
  State<AddPlanningPage> createState() => _AddPlanningPageState();
}
class _AddPlanningPageState extends State<AddPlanningPage> {
  final TextEditingController _planNoCtrl = TextEditingController(text: 'PL000000771');
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  
  String _planDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String _pickupDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String _toDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  final List<Map<String, String>> _gridRows = [
    {
      'sno': '1',
      'remarks': '',
      'truck': '',
      'driver': '',
      'pDate': '',
      'dDate': '',
      'origin': '',
      'destination': '',
      'customer': '',
    }
  ];

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
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'PLANING (MAGES-ADMIN)',
          style: AppTypography.heading2(color: colour.kDanger),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- FORM SECTION ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colour.kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colour.kBorder),
                ),
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
                    _buildTextField('Search', _searchCtrl),
                    const SizedBox(height: 12),
                    _buildTextField('Remarks', _remarksCtrl),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- BUTTONS SECTION ---
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildButton('VIEW', () {}),
                  _buildButton('SAVE', () {}, isPrimary: true),
                  _buildButton('DELETE', () {}),
                  _buildButton('SORT', () {}),
                  _buildButton('CLONE', () {}),
                  _buildButton('UPDATE', () {}),
                  _buildButton('PUSH TO RTI', () {}),
                ],
              ),
              const SizedBox(height: 16),

              // --- GRID SECTION ---
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colour.kBorder),
                ),
                child: MalevaGrid(
                  isTablet: true, // Forces scrollable horizontal
                  columns: const [
                    'Select', 'S.No', 'Sort', 'REMARKS', 'TRUCK', 'DRIVER', 
                    'P.Date', 'D.Date', 'ORIGIN', 'DESTINATION', 'CUSTOMER NAME'
                  ],
                  rows: _gridRows.map((r) => [
                    Checkbox(value: false, onChanged: (v) {}),
                    MalevaGridCell(r['sno'] ?? '', isTablet: true),
                    MalevaGridCell('', isTablet: true), // Sort
                    MalevaGridCell(r['remarks']!,  isTablet: true),
                    MalevaGridCell(r['truck']!,  isTablet: true, color: colour.kDanger),
                    MalevaGridCell(r['driver']!,  isTablet: true),
                    MalevaGridCell(r['pDate']!,  isTablet: true),
                    MalevaGridCell(r['dDate']!,  isTablet: true),
                    MalevaGridCell(r['origin']!,  isTablet: true),
                    MalevaGridCell(r['destination']!,  isTablet: true),
                    MalevaGridCell(r['customer']!,  isTablet: true),
                  ]).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


