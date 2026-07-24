import 'package:maleva/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';
import '../bloc/leave_state.dart';
import 'package:get_it/get_it.dart';


import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_request_model.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/theme/tokens.dart';

class AdminLeaveApprovalTab extends StatefulWidget {
  const AdminLeaveApprovalTab({super.key});

  @override
  State<AdminLeaveApprovalTab> createState() => _AdminLeaveApprovalTabState();
}

class _AdminLeaveApprovalTabState extends State<AdminLeaveApprovalTab> {
    @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() {
    context.read<LeaveBloc>().add(const FetchLeaveData(
      applicantType: 2,
      applicantRefId: 0,
      fromDate: "",
      toDate: "",
    ));
  }

  Future<void> _showApprovalDialog(LeaveRequestModel req) async {
    final remarkCtrl = TextEditingController();
    int? selectedStatusId;
    
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Review Leave Request', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    hint: const Text('Select Status'),
                    initialValue: selectedStatusId,
                    items: const [
                      DropdownMenuItem(value: 2, child: Text('Approve', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      DropdownMenuItem(value: 3, child: Text('Reject', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                    ],
                    onChanged: (val) => setDialogState(() => selectedStatusId = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter Remarks',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedStatusId == null ? null : () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          }
        );
      }
    );

    if (confirm != true || selectedStatusId == null) return;
    
    if (!mounted) return;
    context.read<LeaveBloc>().add(UpdateLeaveStatusEvent(
      id: req.id,
      statusRefId: selectedStatusId!,
      reviewRemark: remarkCtrl.text,
      reviewedBy: AppGlobals.EmpRefId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaveBloc>(
      create: (context) => GetIt.instance<LeaveBloc>()..add(const FetchLeaveData(
        applicantType: 2,
        applicantRefId: 0,
        fromDate: "",
        toDate: "",
      )),
      child: Builder(builder: (context) {
        return BlocConsumer<LeaveBloc, LeaveState>(
          listener: (context, state) {
            if (state is LeaveActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              context.read<LeaveBloc>().add(const FetchLeaveData(
                applicantType: 2,
                applicantRefId: 0,
                fromDate: "",
                toDate: "",
              ));
            } else if (state is LeaveActionError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
      builder: (context, state) {
        bool isLoading = state is LeaveLoading || state is LeaveInitial;
        List<LeaveRequestModel> requests = state is LeaveLoaded ? state.requests : [];

        return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Expanded(child: Text('Driver Leave Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              IconButton(icon: const Icon(Icons.refresh, color: colour.brand), onPressed: _fetchRequests),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
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
                                Expanded(
                                  child: Text(
                                    req.applicantName.isNotEmpty ? req.applicantName : 'Driver ${req.applicantRefId}', 
                                    style: AppTypography.heading1(color: AppTokens.textPrimary, fontWeight: FontWeight.w800),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                                    style: AppTypography.bodySmall(color: statusColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: AppTokens.textMuted),
                                const SizedBox(width: 6),
                                Text(
                                  '${DateFormat('dd MMM yyyy').format(req.fromDate)}  ➔  ${DateFormat('dd MMM yyyy').format(req.toDate)}',
                                  style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${req.totalDays} Days',
                                    style: AppTypography.bodyMedium(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reason', style: AppTypography.bodySmall(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(req.reason, style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w500)),
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
                                        style: AppTypography.bodyMedium(color: Colors.redAccent, fontWeight: FontWeight.w500),
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
                                      style: AppTypography.bodyMedium(color: Colors.blueGrey, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            if (req.statusRefId == 1) // Only show action if pending
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colour.brand,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.rate_review_rounded, color: Colors.white, size: 16),
                                    onPressed: () => _showApprovalDialog(req),
                                    label: Text('Review', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
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
