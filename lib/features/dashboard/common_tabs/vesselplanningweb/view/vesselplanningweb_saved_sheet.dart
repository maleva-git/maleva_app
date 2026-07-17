import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../../core/colors/colors.dart' as colour;
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/utils/app_globals.dart';
import '../../../../../core/utils/dialog_helper.dart';
import '../data/vesselplanningweb_repository.dart';
import '../bloc/vesselplanningweb_bloc.dart';
import '../bloc/vesselplanningweb_event.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../../core/models/model.dart';
import '../../../../../core/network/OnlineApi.dart' as OnlineApi;
import '../../../../mastersearch/Employee.dart';
import '../bloc/vesselplanningweb_state.dart';
import 'package:maleva/core/models/shared/employee_model.dart';

class VesselPlanningSavedSheet extends StatefulWidget {
  const VesselPlanningSavedSheet({super.key});

  @override
  State<VesselPlanningSavedSheet> createState() => _VesselPlanningSavedSheetState();
}

class _VesselPlanningSavedSheetState extends State<VesselPlanningSavedSheet> {
  late TextEditingController _fromDateController;
  late TextEditingController _toDateController;
  final TextEditingController _searchController = TextEditingController();

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();
  
  EmployeeModel? _selectedEmployee;
  bool _isLEmp = true;
  
  bool _isLoading = false;
  List<dynamic> _savedPlannings = [];
  final VesselPlanningWebRepository _repository = VesselPlanningWebRepository();

  @override
  void initState() {
    super.initState();
    _fromDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_fromDate));
    _toDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_toDate));
    _fetchSavedPlannings();
  }

  Future<void> _fetchSavedPlannings() async {
    setState(() => _isLoading = true);
    try {
      final loginEmpId = AppGlobals.storagenew.getInt('EmpRefId') ?? 0;
      final employeeId = _isLEmp ? loginEmpId : (_selectedEmployee?.Id ?? 0);
      final results = await _repository.getSavedPlannings(
        fromDate: _fromDateController.text,
        toDate: _toDateController.text,
        search: _searchController.text.trim(),
        employeeId: employeeId,
      );
      setState(() {
        _savedPlannings = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        msgshow(e.toString(), "", Colors.white, Colors.red, null, 14, AppGlobals.tls, AppGlobals.tgc, context, 2);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final initialDate = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: colour.kHeaderGradEnd,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          _fromDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _toDate = picked;
          _toDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _searchController.dispose();
    super.dispose();


  }

  // ── Download PDF to temp file then open with device viewer ──────────────────
  Future<void> _openPdf(BuildContext context, String url) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: [
              const SpinKitFadingCircle(color: colour.kHeaderGradEnd, size: 30),
              const SizedBox(width: 20),
              Text("Loading PDF...",
                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

      final response = await http.get(Uri.parse(url));

      if (!context.mounted) return;
      Navigator.pop(context); // Close dialog

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/vp_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(response.bodyBytes);

        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done && context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Error"),
              content: Text("Could not open PDF: ${result.message}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to download PDF (${response.statusCode})")),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VesselPlanningWebBloc, VesselPlanningWebState>(
      listenWhen: (prev, curr) => curr is VesselPlanningPdfLaunchSuccess || curr is VesselPlanningPdfLaunchError,
      listener: (context, state) async {
        if (state is VesselPlanningPdfLaunchSuccess) {
          await _openPdf(context, state.url);
        } else if (state is VesselPlanningPdfLaunchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: colour.kPageBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle and Title
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTokens.maintCardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'View Saved Plannings',
                style: GoogleFonts.lato(
                  color: colour.kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colour.kCardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTokens.maintCardBorder),
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 20, color: colour.kTextDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filters
          Row(
            children: [
              Expanded(
                child: _buildDateField('From Date', _fromDateController, () => _selectDate(context, true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField('To Date', _toDateController, () => _selectDate(context, false)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Employee & L.Emp Checkbox
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: colour.kCardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTokens.maintCardBorder, width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: InkWell(
                    onTap: _isLEmp
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            await OnlineApi.SelectEmployee(context, 'Sales', '');
                            setState(() => _isLoading = false);
                            if (!mounted) return;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const Employee(Searchby: 1, SearchId: 0))).then((result) {
                              if (result != null && result is EmployeeModel) {
                                setState(() {
                                  _selectedEmployee = result;
                                });
                              }
                            });
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedEmployee?.AccountName ?? 'Select Employee',
                            style: GoogleFonts.lato(
                              color: _selectedEmployee != null ? colour.kTextDark : AppTokens.planTextMuted,
                              fontSize: 13,
                              fontWeight: _selectedEmployee != null ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: _isLEmp ? Colors.transparent : AppTokens.planTextMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _isLEmp = !_isLEmp;
                  });
                },
                borderRadius: BorderRadius.circular(5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: _isLEmp
                              ? const LinearGradient(colors: [colour.kHeaderGradStart, colour.kHeaderGradEnd])
                              : null,
                          border: _isLEmp
                              ? null
                              : Border.all(color: AppTokens.maintCardBorder, width: 1.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: _isLEmp ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'L.Emp',
                        style: GoogleFonts.lato(color: colour.kTextDark, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colour.kCardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTokens.maintCardBorder, width: 0.8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.lato(color: colour.kTextDark, fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Planning No',
                      hintStyle: GoogleFonts.lato(color: AppTokens.planTextMuted, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _fetchSavedPlannings,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colour.kHeaderGradStart, colour.kHeaderGradEnd],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Search',
                    style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // List
          Expanded(
            child: _isLoading
                ? Center(child: SpinKitFoldingCube(color: colour.kHeaderGradEnd, size: 40))
                : _savedPlannings.isEmpty
                    ? Center(
                        child: Text(
                          'No saved plannings found.',
                          style: GoogleFonts.lato(color: AppTokens.planTextMuted, fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _savedPlannings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _savedPlannings[index];
                          return _buildPlanningCard(item);
                        },
                      ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            color: colour.kTextDark,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: colour.kCardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTokens.maintCardBorder, width: 0.8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 18, color: colour.kHeaderGradEnd),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.text,
                    style: GoogleFonts.lato(
                      color: colour.kTextDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanningCard(dynamic item) {
    final planningNo = item['VESSELPLANINGNoDisplay'] ?? item['VESSELPLANINGNo'] ?? item['VesselPlanningNo'] ?? item['PlanningNo'] ?? '';
    final date = item['VESSELPLANINGDate'] ?? item['PortName'] ?? '';
    final remarks = item['Remarks'] ?? '';
    final id = item['Id'] ?? 0;
    
    final List<dynamic> details = item['saledetails'] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.maintCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            title: InkWell(
              onLongPress: () {
                context.read<VesselPlanningWebBloc>().add(LoadPlanningForEditEvent(planningMaster: item));
                Navigator.pop(context);
                msgshow('Loading Planning $planningNo...', "", Colors.white, colour.kHeaderGradEnd, null, 14, AppGlobals.tls, AppGlobals.tgc, context, 2);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description_outlined, size: 20, color: colour.kHeaderGradEnd),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          planningNo,
                          style: GoogleFonts.lato(color: colour.kTextDark, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.read<VesselPlanningWebBloc>().add(FetchVesselPlanningPdfEvent(planningNo: planningNo, id: id));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.picture_as_pdf_outlined, size: 14, color: Colors.red),
                              const SizedBox(width: 4),
                              Text("PDF", style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 14, color: AppTokens.planTextMuted),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: GoogleFonts.lato(color: colour.kTextDark, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '(Long press to edit)',
                        style: GoogleFonts.lato(color: AppTokens.planTextMuted, fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  if (remarks.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      remarks,
                      style: GoogleFonts.lato(color: AppTokens.planTextMuted, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            children: [
              if (details.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No details found', style: GoogleFonts.lato(color: AppTokens.planTextMuted, fontSize: 13)),
                )
              else
                Container(
                  width: double.infinity,
                  color: colour.kPageBg.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: details.map((detail) {
                      final jobNo = detail['JobNo'] ?? '';
                      final customer = detail['CustomerName'] ?? '';
                      final jobDate = detail['JobDate'] ?? '';
                      final status = detail['JobStatus'] ?? '';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(jobNo, style: GoogleFonts.lato(color: colour.kTextDark, fontSize: 13, fontWeight: FontWeight.w700)),
                                if (status.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colour.kHeaderGradEnd.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      status.trim(),
                                      style: GoogleFonts.lato(color: colour.kHeaderGradEnd, fontSize: 10, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 14, color: AppTokens.planTextMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    customer,
                                    style: GoogleFonts.lato(color: colour.kTextDark, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.calendar_today_outlined, size: 12, color: AppTokens.planTextMuted),
                                const SizedBox(width: 4),
                                Text(
                                  jobDate,
                                  style: GoogleFonts.lato(color: colour.kTextDark, fontSize: 11),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
