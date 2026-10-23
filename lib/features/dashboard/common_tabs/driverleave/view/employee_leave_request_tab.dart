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
import 'leave_request_form_sheet.dart';
import 'package:maleva/core/widgets/maleva_inputs.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/theme/tokens.dart';

class EmployeeLeaveRequestTab extends StatefulWidget {
  final bool isAdminOrSubadmin;
  const EmployeeLeaveRequestTab({super.key, this.isAdminOrSubadmin = false});

  @override
  State<EmployeeLeaveRequestTab> createState() => _EmployeeLeaveRequestTabState();
}

class _EmployeeLeaveRequestTabState extends State<EmployeeLeaveRequestTab> {
  DateTime _searchFromDate = DateTime.now().subtract(const Duration(days: 30));
  // a year ahead, so leave applied for coming dates is listed (leave-approval-rules)
  DateTime _searchToDate = DateTime.now().add(const Duration(days: 365));
  int? _selectedId;
  List<LeaveRequestModel> _cachedRequests = [];
  List<LeaveTypeModel> _cachedLeaveTypes = [];
  
  @override
  void initState() {
    super.initState();
    _selectedId = AppGlobals.EmpRefId;
  }

  void _fetchRequests(BuildContext ctx) {
    if (_selectedId != null) {
      ctx.read<LeaveBloc>().add(FetchLeaveData(
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
        if (isFrom) {
          _searchFromDate = picked;
        } else {
          _searchToDate = picked;
        }
      });
    }
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
            child: LeaveRequestFormSheet(
              applicantType: 1,
              applicantRefId: _selectedId ?? -1,
              leaveTypes: leaveTypes,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaveBloc>(
      create: (context) => GetIt.instance<LeaveBloc>()..add(FetchLeaveData(
        applicantType: 1,
        applicantRefId: _selectedId ?? -1,
        fromDate: DateFormat('yyyy-MM-dd').format(_searchFromDate),
        toDate: DateFormat('yyyy-MM-dd').format(_searchToDate),
      )),
      child: Builder(builder: (context) {
        return BlocConsumer<LeaveBloc, LeaveState>(
          listener: (context, state) {
            if (state is LeaveActionSuccess) {
              Future.delayed(const Duration(milliseconds: 400), () {
                if (context.mounted) {
                  ConfirmationOK(state.message, context);
                  _fetchRequests(context);
                }
              });
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
                            if (req.status == LeaveDecision.approved) {
                              statusColor = const Color(0xFF047857); // Green
                              statusBg = const Color(0xFF059669).withValues(alpha: 0.12);
                            } else if (req.status == LeaveDecision.rejected) {
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
                                              req.lengthLabel,
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
      }),
    );
  }
}
