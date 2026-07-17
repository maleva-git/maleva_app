import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';
import '../bloc/leave_state.dart';
import 'package:get_it/get_it.dart';


import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_request_model.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/widgets/maleva_inputs.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/theme/tokens.dart';

class EmployeeLeaveRequestTab extends StatefulWidget {
  final bool isAdminOrSubadmin;
  const EmployeeLeaveRequestTab({Key? key, this.isAdminOrSubadmin = false}) : super(key: key);

  @override
  State<EmployeeLeaveRequestTab> createState() => _EmployeeLeaveRequestTabState();
}

class _EmployeeLeaveRequestTabState extends State<EmployeeLeaveRequestTab> {
  // Form state
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  DateTime _searchFromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _searchToDate = DateTime.now();
  int? _selectedLeaveTypeId;
  int? _selectedId;
  
  @override
  void initState() {
    super.initState();
    _selectedId = AppGlobals.EmpRefId;
    _fetchRequests();
  }

  void _fetchRequests() {
    if (_selectedId != null && _selectedId != 0) {
      context.read<LeaveBloc>().add(FetchLeaveData(
        applicantType: 1,
        applicantRefId: _selectedId!,
        fromDate: DateFormat('yyyy-MM-dd').format(_searchFromDate),
        toDate: DateFormat('yyyy-MM-dd').format(_searchToDate),
      ));
    }
  }

  Future<void> _pickSearchDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _searchFromDate : _searchToDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) _searchFromDate = picked;
        else _searchToDate = picked;
      });
    }
  }

  void _submitLeave(List<LeaveTypeModel> leaveTypes) {
    if (_selectedLeaveTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Leave Reason')));
      return;
    }
    
    int days = _toDate.difference(_fromDate).inDays + 1;
    if (days <= 0) days = 1;
    
    context.read<LeaveBloc>().add(SubmitLeaveRequest(
      leaveTypeRefId: _selectedLeaveTypeId!,
      fromDate: _fromDate,
      toDate: _toDate,
      totalDays: days,
      applicantRefId: _selectedId!,
      applicantType: 1,
      reason: leaveTypes.firstWhere((e) => e.id == _selectedLeaveTypeId).name,
    ));
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
        } else {
          _toDate = picked;
          if (_fromDate.isAfter(_toDate)) _fromDate = _toDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaveBloc>(
      create: (context) => GetIt.instance<LeaveBloc>()..add(FetchLeaveData(
        applicantType: 1,
        applicantRefId: _selectedId ?? 0,
        fromDate: DateFormat('yyyy-MM-dd').format(_searchFromDate),
        toDate: DateFormat('yyyy-MM-dd').format(_searchToDate),
      )),
      child: Builder(builder: (context) {
        return BlocConsumer<LeaveBloc, LeaveState>(
          listener: (context, state) {
            if (state is LeaveActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              setState(() => _selectedLeaveTypeId = null);
              context.read<LeaveBloc>().add(FetchLeaveData(
                applicantType: 1,
                applicantRefId: _selectedId!,
                fromDate: DateFormat('yyyy-MM-dd').format(_searchFromDate),
                toDate: DateFormat('yyyy-MM-dd').format(_searchToDate),
              ));
            } else if (state is LeaveActionError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
      builder: (context, state) {
        bool isLoading = state is LeaveLoading || state is LeaveInitial;
        bool isSubmitting = state is LeaveLoaded && state.isSubmitting;
        List<LeaveRequestModel> requests = state is LeaveLoaded ? state.requests : [];
        List<LeaveTypeModel> leaveTypes = state is LeaveLoaded ? state.leaveTypes : [];

        return Column(
      children: [
        // Form Area
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTokens.brandPrimary.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
            border: Border.all(color: AppTokens.brandPrimary.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTokens.brandLight.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit_calendar_rounded, color: AppTokens.brandPrimary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Request Leave',
                      style: GoogleFonts.lato(fontWeight: FontWeight.w800, fontSize: 16, color: AppTokens.brandDark),
                    ),
                  ],
                ),
              ),
              
              // Inputs
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MalevaDateField(
                            date: DateFormat('dd-MM-yyyy').format(_fromDate),
                            onTap: () => _pickDate(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MalevaDateField(
                            date: DateFormat('dd-MM-yyyy').format(_toDate),
                            onTap: () => _pickDate(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTokens.surfacePage,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedLeaveTypeId,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTokens.textMuted),
                          hint: Text('Select Leave Reason', style: GoogleFonts.lato(color: AppTokens.textMuted)),
                          items: leaveTypes.map((e) => DropdownMenuItem<int>(
                            value: e.id,
                            child: Text(e.name, style: GoogleFonts.lato(color: AppTokens.textPrimary, fontWeight: FontWeight.w500)),
                          )).toList(),
                          onChanged: (val) {
                            setState(() => _selectedLeaveTypeId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.brandPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isSubmitting ? null : () => _submitLeave(leaveTypes),
                      child: isSubmitting 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text('Submit Request', style: GoogleFonts.lato(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Search Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: MalevaDateField(
                  date: DateFormat('dd-MM-yyyy').format(_searchFromDate),
                  onTap: () => _pickSearchDate(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MalevaDateField(
                  date: DateFormat('dd-MM-yyyy').format(_searchToDate),
                  onTap: () => _pickSearchDate(false),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.brandDark,
                  elevation: 0,
                  padding: const EdgeInsets.all(16),
                  minimumSize: const Size(0, 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _fetchRequests,
                child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // List
        Expanded(
          child: isLoading && requests.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    Color statusColor = const Color(0xFFEAB308); // Yellow/Orange
                    Color statusBg = const Color(0xFFFEF08A).withValues(alpha: 0.3);
                    if (req.statusRefId == 2) {
                      statusColor = const Color(0xFF047857); // Green
                      statusBg = const Color(0xFF059669).withValues(alpha: 0.12);
                    } else if (req.statusRefId == 3) {
                      statusColor = const Color(0xFFB91C1C); // Red
                      statusBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
                    }
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        border: Border(left: BorderSide(color: statusColor, width: 4)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${DateFormat('dd MMM').format(req.fromDate)}  ➔  ${DateFormat('dd MMM').format(req.toDate)}',
                                      style: GoogleFonts.lato(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    req.statusName, 
                                    style: GoogleFonts.lato(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Reason', style: GoogleFonts.lato(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(req.reason, style: GoogleFonts.lato(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${req.totalDays} Days',
                                      style: GoogleFonts.lato(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (req.reviewRemark.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline_rounded, size: 14, color: Colors.redAccent),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Remark: ${req.reviewRemark}',
                                        style: GoogleFonts.lato(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (req.reviewedByName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified_user_rounded, size: 14, color: Colors.blueGrey),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Reviewed By: ${req.reviewedByName}',
                                      style: GoogleFonts.lato(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
          },
        );
      }),
    );
  }
}
