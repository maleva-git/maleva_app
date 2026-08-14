import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/dialog_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';
import '../bloc/leave_state.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_request_model.dart';
import 'package:maleva/core/widgets/maleva_inputs.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/theme/tokens.dart';

class DriverLeaveRequestTab extends StatelessWidget {
  const DriverLeaveRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<LeaveBloc>(),
      child: const _DriverLeaveRequestTabBody(),
    );
  }
}

class _DriverLeaveRequestTabBody extends StatefulWidget {
  const _DriverLeaveRequestTabBody();

  @override
  State<_DriverLeaveRequestTabBody> createState() => _DriverLeaveRequestTabState();
}

class _DriverLeaveRequestTabState extends State<_DriverLeaveRequestTabBody> {
  DateTime _searchFromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _searchToDate = DateTime.now();
  int? _selectedId;
  List<LeaveRequestModel> _cachedRequests = [];
  List<LeaveTypeModel> _cachedLeaveTypes = [];
  
  @override
  void initState() {
    super.initState();
    _selectedId = AppGlobals.EmpRefId;
    context.read<LeaveBloc>().add(FetchLeaveData(
      applicantType: 2,
      applicantRefId: _selectedId ?? 0,
      fromDate: DateFormat('yyyy-MM-dd').format(_searchFromDate),
      toDate: DateFormat('yyyy-MM-dd').format(_searchToDate),
    ));
  }

  void _fetchRequests(BuildContext ctx) {
    if (_selectedId != null) {
      ctx.read<LeaveBloc>().add(FetchLeaveData(
        applicantType: 2,
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
        if (isFrom) {
          _searchFromDate = picked;
        } else {
          _searchToDate = picked;
        }
      });
    }
  }

  String _formatTotalDays(LeaveRequestModel req) {
    int tDays = req.totalDays;
    bool sameDay = req.fromDate.year == req.toDate.year && 
                   req.fromDate.month == req.toDate.month && 
                   req.fromDate.day == req.toDate.day;
    
    bool hasTime = (req.fromDate.hour != 0 || req.fromDate.minute != 0 || req.fromDate.second != 0) ||
                   (req.toDate.hour != 0 || req.toDate.minute != 0 || req.toDate.second != 0);
                   
    if (hasTime && sameDay) {
      int diffHours = req.toDate.difference(req.fromDate).inHours;
      if (diffHours < 1) {
        return '${req.toDate.difference(req.fromDate).inMinutes} Mins';
      } else {
        return '$diffHours Hours';
      }
    }
    
    if (sameDay) {
      if (tDays > 1) {
        if (tDays >= 15) return '$tDays Mins';
        return '$tDays Hours';
      }
      return '1 Day';
    }
    return '$tDays ${tDays == 1 ? "Day" : "Days"}';
  }

  void _openLeaveForm(BuildContext context, List<LeaveTypeModel> leaveTypes) {
    final bloc = context.read<LeaveBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: _LeaveRequestFormSheet(
              applicantRefId: _selectedId ?? 0,
              leaveTypes: leaveTypes,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state is LeaveActionSuccess) {
          ConfirmationOK(state.message, context);
          _fetchRequests(context);
        } else if (state is LeaveActionError) {
          ConfirmationOK(state.message, context);
        }
      },
      builder: (context, state) {
        bool isLoading = state is LeaveLoading || state is LeaveInitial;
        if (state is LeaveLoaded) {
          if (state.requests.isNotEmpty) _cachedRequests = state.requests;
          if (state.leaveTypes.isNotEmpty) _cachedLeaveTypes = state.leaveTypes;
        }
        
        List<LeaveRequestModel> requests = (state is LeaveLoaded) ? state.requests : _cachedRequests;
        List<LeaveTypeModel> leaveTypes = (state is LeaveLoaded) ? state.leaveTypes : _cachedLeaveTypes;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openLeaveForm(context, leaveTypes),
            backgroundColor: AppTokens.brandPrimary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text("Request Leave", style: AppTypography.heading3(color: Colors.white)),
          ),
          body: RefreshIndicator(
            onRefresh: () async { _fetchRequests(context); },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Search Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          onPressed: () => _fetchRequests(context),
                          child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // List
                  if (isLoading && requests.isEmpty)
                    const Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${DateFormat('dd MMM hh:mm a').format(req.fromDate)}  ➔  ${DateFormat('dd MMM hh:mm a').format(req.toDate)}',
                                              style: AppTypography.heading3(color: colour.commonColor, fontWeight: FontWeight.w700),
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        req.statusName, 
                                        style: AppTypography.bodySmall(color: statusColor, fontWeight: FontWeight.bold),
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
                                            Text('Reason', style: AppTypography.bodySmall(color: Colors.grey, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 2),
                                            Text(req.reason, style: AppTypography.bodyLarge(color: colour.commonColor, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colour.commonColorhighlight.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _formatTotalDays(req),
                                          style: AppTypography.bodyMedium(color: colour.commonColorhighlight, fontWeight: FontWeight.bold),
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
                                        Icon(Icons.info_outline_rounded, size: 14, color: colour.commonColorred),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Remark: ${req.reviewRemark}',
                                            style: AppTypography.bodyMedium(color: colour.commonColorred, fontWeight: FontWeight.w500),
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
                                        Icon(Icons.verified_user_rounded, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Reviewed By: ${req.reviewedByName}',
                                          style: AppTypography.bodyMedium(color: Colors.grey, fontWeight: FontWeight.w600),
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
                  const SizedBox(height: 80), // padding for fab
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LeaveRequestFormSheet extends StatefulWidget {
  final int applicantRefId;
  final List<LeaveTypeModel> leaveTypes;

  const _LeaveRequestFormSheet({
    required this.applicantRefId,
    required this.leaveTypes,
  });

  @override
  State<_LeaveRequestFormSheet> createState() => _LeaveRequestFormSheetState();
}

class _LeaveRequestFormSheetState extends State<_LeaveRequestFormSheet> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  int? _selectedLeaveTypeId;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitLeave(BuildContext ctx) {
    if (_selectedLeaveTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Leave Reason')));
      return;
    }
    
    int totalDaysNum = 0;
    int diffHours = _toDate.difference(_fromDate).inHours;
    if (diffHours >= 0 && diffHours < 24 && _fromDate.day == _toDate.day && _fromDate.month == _toDate.month && _fromDate.year == _toDate.year) {
      if (diffHours < 1) {
        totalDaysNum = _toDate.difference(_fromDate).inMinutes;
      } else {
        totalDaysNum = diffHours;
      }
    } else {
      totalDaysNum = DateTime(_toDate.year, _toDate.month, _toDate.day)
          .difference(DateTime(_fromDate.year, _fromDate.month, _fromDate.day))
          .inDays + 1;
      if (totalDaysNum <= 0) totalDaysNum = 1;
    }
    
    ctx.read<LeaveBloc>().add(SubmitLeaveRequest(
      leaveTypeRefId: _selectedLeaveTypeId!,
      fromDate: _fromDate,
      toDate: _toDate,
      totalDays: totalDaysNum,
      applicantRefId: widget.applicantRefId,
      applicantType: 2,
      reason: _reasonController.text.trim().isNotEmpty 
          ? _reasonController.text.trim() 
          : widget.leaveTypes.firstWhere((e) => e.id == _selectedLeaveTypeId).name,
    ));
  }

  Future<void> _pickDate(bool isFrom) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      if (!context.mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isFrom ? _fromDate : _toDate),
      );
      if (pickedTime != null) {
        final combined = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        setState(() {
          if (isFrom) {
            _fromDate = combined;
            if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
          } else {
            _toDate = combined;
            if (_fromDate.isAfter(_toDate)) _fromDate = _toDate;
          }
        });
      }
    }
  }

  String get _calculatedDuration {
    int diffHours = _toDate.difference(_fromDate).inHours;
    if (diffHours >= 0 && diffHours < 24 && _fromDate.day == _toDate.day && _fromDate.month == _toDate.month && _fromDate.year == _toDate.year) {
      if (diffHours < 1) {
        int mins = _toDate.difference(_fromDate).inMinutes;
        return '$mins Mins';
      } else {
        return '$diffHours Hours';
      }
    } else {
      int days = DateTime(_toDate.year, _toDate.month, _toDate.day).difference(DateTime(_fromDate.year, _fromDate.month, _fromDate.day)).inDays + 1;
      if (days <= 0) days = 1;
      return '$days ${days == 1 ? "Day" : "Days"}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state is LeaveActionSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        bool isSubmitting = (state is LeaveLoaded) ? state.isSubmitting : false;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Leave',
                      style: AppTypography.heading1(color: AppTokens.brandDark, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: MalevaDateField(
                            date: DateFormat('dd-MM-yyyy hh:mm a').format(_fromDate),
                            onTap: () => _pickDate(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MalevaDateField(
                            date: DateFormat('dd-MM-yyyy hh:mm a').format(_toDate),
                            onTap: () => _pickDate(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTokens.brandLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Duration:', style: AppTypography.bodyMedium(color: AppTokens.textMuted)),
                          Text(_calculatedDuration, style: AppTypography.heading2(color: AppTokens.brandDark)),
                        ],
                      ),
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
                          hint: Text('Select Leave Reason', style: AppTypography.bodyLarge(color: AppTokens.textMuted)),
                          items: widget.leaveTypes.map((e) => DropdownMenuItem<int>(
                            value: e.id,
                            child: Text(e.name, style: AppTypography.bodyLarge(color: AppTokens.textPrimary)),
                          )).toList(),
                          onChanged: (val) {
                            setState(() => _selectedLeaveTypeId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTokens.surfacePage,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter specific reason/remark (optional)',
                          hintStyle: AppTypography.bodyLarge(color: AppTokens.textMuted),
                        ),
                        style: AppTypography.bodyLarge(color: AppTokens.textPrimary),
                        maxLines: 2,
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
                      onPressed: isSubmitting ? null : () => _submitLeave(context),
                      child: isSubmitting 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text('Submit Request', style: AppTypography.heading2(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
