import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../../core/colors/colors.dart' as colour;
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/network/api_services/master_api.dart';
import '../../../../../core/models/model.dart';

const _kGrad = LinearGradient(
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
  _VesselPlanningFilterSheetState createState() =>
      _VesselPlanningFilterSheetState();
}

class _VesselPlanningFilterSheetState
    extends State<VesselPlanningFilterSheet> {
  late TextEditingController _fromDateController;
  late TextEditingController _toDateController;
  final TextEditingController _portStringController = TextEditingController();
  final TextEditingController _dropdownSearchController = TextEditingController();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  int _etaType = 3;
  bool _deliveryDone = true;

  // Port related
  List<WareHouseModel> _allPorts = [];
  List<WareHouseModel> _filteredPorts = [];
  WareHouseModel? _selectedDropdownPort;
  bool _loadingPorts = false;
  bool _showPortDropdown = false;

  @override
  void initState() {
    super.initState();
    _fromDateController =
        TextEditingController(text: DateFormat('yyyy-MM-dd').format(_fromDate));
    _toDateController =
        TextEditingController(text: DateFormat('yyyy-MM-dd').format(_toDate));
    _dropdownSearchController.addListener(_filterPorts);
    _loadPorts();
  }

  Future<void> _loadPorts() async {
    setState(() => _loadingPorts = true);
    try {
      final ports = await MasterApi.getWarehouses();
      setState(() {
        _allPorts = ports;
        _filteredPorts = ports;
        _loadingPorts = false;
      });
    } catch (_) {
      setState(() => _loadingPorts = false);
    }
  }

  void _filterPorts() {
    final query = _dropdownSearchController.text.toLowerCase();
    setState(() {
      _filteredPorts = _allPorts
          .where((p) => p.PortName.toLowerCase().contains(query))
          .toList();
    });
  }

  void _addPort() {
    if (_selectedDropdownPort != null) {
      final currentText = _portStringController.text.trim();
      if (currentText.isEmpty) {
        _portStringController.text = _selectedDropdownPort!.PortName;
      } else {
        // Only add if not already present
        final portsList = currentText.split(',').map((e) => e.trim()).toList();
        if (!portsList.contains(_selectedDropdownPort!.PortName)) {
          _portStringController.text = '$currentText,${_selectedDropdownPort!.PortName}';
        }
      }
      setState(() {
        _selectedDropdownPort = null;
        _dropdownSearchController.clear();
        _showPortDropdown = false;
      });
    }
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _portStringController.dispose();
    _dropdownSearchController.dispose();
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
    return GestureDetector(
      onTap: () => setState(() => _showPortDropdown = false),
      child: Container(
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
              // Handle
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
                ),
              ),
              const SizedBox(height: 16),

              // ── Date Row ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: 'From',
                      date: _fromDateController.text,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateTile(
                      label: 'To',
                      date: _toDateController.text,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── ETA Type Chips ─────────────────────────────────────────
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
                  _EtaChip(
                    label: 'OETA',
                    selected: _etaType == 1,
                    onTap: () => setState(() => _etaType = 1),
                  ),
                  const SizedBox(width: 8),
                  _EtaChip(
                    label: 'ETA',
                    selected: _etaType == 2,
                    onTap: () => setState(() => _etaType = 2),
                  ),
                  const SizedBox(width: 8),
                  _EtaChip(
                    label: 'Both',
                    selected: _etaType == 3,
                    onTap: () => setState(() => _etaType = 3),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Port Search + Add ──────────────────────────────────────
              Text(
                'Ports Search',
                style: GoogleFonts.lato(
                  color: colour.kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),

              // The text box holding comma separated ports
              Container(
                decoration: BoxDecoration(
                  color: colour.kCardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTokens.maintCardBorder, width: 0.8),
                ),
                child: TextField(
                  controller: _portStringController,
                  style: GoogleFonts.lato(
                    color: colour.kTextDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Comma separated ports...',
                    hintStyle: GoogleFonts.lato(
                      color: AppTokens.planTextMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: colour.kHeaderGradEnd, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          size: 18, color: AppTokens.planTextMuted),
                      onPressed: () => _portStringController.clear(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Dropdown to select port and Add button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colour.kCardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _showPortDropdown
                                  ? AppTokens.invoiceHeaderStart
                                  : AppTokens.maintCardBorder,
                              width: _showPortDropdown ? 1.5 : 0.8,
                            ),
                          ),
                          child: TextField(
                            controller: _dropdownSearchController,
                            onTap: () => setState(() => _showPortDropdown = true),
                            onChanged: (_) => setState(() => _showPortDropdown = true),
                            style: GoogleFonts.lato(
                              color: colour.kTextDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Select a port...',
                              hintStyle: GoogleFonts.lato(
                                color: AppTokens.planTextMuted,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              suffixIcon: _loadingPorts
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SpinKitFoldingCube(
                                          color: colour.kHeaderGradEnd, size: 16),
                                    )
                                  : const Icon(Icons.keyboard_arrow_down_rounded,
                                      color: AppTokens.planTextMuted),
                            ),
                          ),
                        ),
                        if (_showPortDropdown && !_loadingPorts)
                          Positioned(
                            top: 50,
                            left: 0,
                            right: 0,
                            child: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTokens.maintCardBorder),
                                ),
                                child: _filteredPorts.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          'No ports found',
                                          style: GoogleFonts.lato(
                                              color: AppTokens.planTextMuted, fontSize: 13),
                                        ),
                                      )
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        itemCount: _filteredPorts.length,
                                        separatorBuilder: (_, __) => const Divider(
                                            height: 0.5, indent: 14, endIndent: 14),
                                        itemBuilder: (context, index) {
                                          final port = _filteredPorts[index];
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                _selectedDropdownPort = port;
                                                _dropdownSearchController.text = port.PortName;
                                                _showPortDropdown = false;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 12),
                                              child: Text(
                                                port.PortName,
                                                style: GoogleFonts.lato(
                                                  color: colour.kTextDark,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add Button
                  InkWell(
                    onTap: _addPort,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: _kGrad,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Add',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Delivery Done Toggle ───────────────────────────────────
              InkWell(
                onTap: () => setState(() => _deliveryDone = !_deliveryDone),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: _deliveryDone ? _kGrad : null,
                          border: _deliveryDone
                              ? null
                              : Border.all(
                                  color: AppTokens.maintCardBorder,
                                  width: 1.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: _deliveryDone
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
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

              // ── Buttons ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GradButton(
                    label: 'Search',
                    onPressed: () {
                      widget.onSearch(
                        _fromDateController.text,
                        _toDateController.text,
                        _etaType,
                        _portStringController.text.trim(),
                        _deliveryDone,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  _OutlineBtn(
                    label: 'Clear',
                    onPressed: () {
                      setState(() {
                        _etaType = 3;
                        _portStringController.clear();
                        _dropdownSearchController.clear();
                        _selectedDropdownPort = null;
                        _deliveryDone = true;
                        _showPortDropdown = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _DateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;
  const _DateTile(
      {required this.label, required this.date, required this.onTap});

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
            const Icon(Icons.calendar_month_rounded,
                color: colour.kHeaderGradEnd, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.lato(
                          color: AppTokens.planTextMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(date,
                      style: GoogleFonts.lato(
                          color: colour.kTextDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
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
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? _kGrad : null,
          color: selected ? null : colour.kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? Colors.transparent : AppTokens.maintCardBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: selected ? Colors.white : colour.kTextDark,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _GradButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GradButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 42,
      decoration: BoxDecoration(
        gradient: _kGrad,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTokens.invoiceHeaderStart.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _OutlineBtn({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 42,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: colour.kTextDark,
          side: const BorderSide(color: AppTokens.invoiceHeaderStart, width: 1.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: GoogleFonts.lato(
                fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }
}
