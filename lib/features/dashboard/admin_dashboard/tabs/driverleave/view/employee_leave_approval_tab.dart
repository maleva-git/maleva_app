import 'package:flutter/material.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverleave/data/leave_request_api.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverleave/data/leave_request_model.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:google_fonts/google_fonts.dart';

class EmployeeLeaveApprovalTab extends StatefulWidget {
  const EmployeeLeaveApprovalTab({Key? key}) : super(key: key);

  @override
  State<EmployeeLeaveApprovalTab> createState() => _EmployeeLeaveApprovalTabState();
}

class _EmployeeLeaveApprovalTabState extends State<EmployeeLeaveApprovalTab> {
  bool _isLoading = false;
  List<LeaveRequestModel> _requests = [];
  List<LeaveTypeModel> _leaveStatusList = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _loadEmployees();
    _fetchLeaveStatus();
  }
  
  Future<void> _fetchLeaveStatus() async {
    final data = await LeaveRequestApi.getLeaveStatus(context);
    if (mounted) {
      setState(() {
        _leaveStatusList = data;
      });
    }
  }
  
  Future<void> _loadEmployees() async {
    await OnlineApi.SelectEmployee(context, "0", "0");
    setState(() {});
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    final data = await LeaveRequestApi.getLeaveRequests(context, applicantType: 1); // 2 for Drivers
    setState(() {
      _requests = data;
      _isLoading = false;
    });
  }
  
  Future<void> _updateStatus(LeaveRequestModel req, int initialStatus) async {
    int? selectedStatusId = initialStatus;
    final remarkCtrl = TextEditingController();

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Review Leave Request'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Action Status:'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedStatusId,
                          hint: const Text('Select Status'),
                          items: _leaveStatusList.map((e) => DropdownMenuItem<int>(
                            value: e.id,
                            child: Text(e.name),
                          )).toList(),
                          onChanged: (val) {
                            setStateDialog(() => selectedStatusId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: remarkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Remark (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: colour.brand),
                  onPressed: () {
                    if (selectedStatusId == null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please select a status action')));
                      return;
                    }
                    Navigator.pop(ctx, true);
                  }, 
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );

    if (confirm != true || selectedStatusId == null) return;
    
    setState(() => _isLoading = true);
    bool success = await LeaveRequestApi.updateLeaveStatus(
      context,
      id: req.id,
      statusRefId: selectedStatusId!,
      reviewRemark: remarkCtrl.text,
      reviewedBy: objfun.EmpRefId,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave Status Updated')));
      _fetchRequests();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Expanded(child: Text('Employee Leave Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              IconButton(icon: const Icon(Icons.refresh, color: colour.brand), onPressed: _fetchRequests),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: _isLoading && _requests.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
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
                                    req.applicantName.isNotEmpty ? req.applicantName : 'Employee ${req.applicantRefId}', 
                                    style: GoogleFonts.lato(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
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
                                    style: GoogleFonts.lato(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  '${DateFormat('dd MMM yyyy').format(req.fromDate)}  ➔  ${DateFormat('dd MMM yyyy').format(req.toDate)}',
                                  style: GoogleFonts.lato(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
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
                                    style: GoogleFonts.lato(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold),
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
                                  Text('Reason', style: GoogleFonts.lato(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(req.reason, style: GoogleFonts.lato(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
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
                                    onPressed: () => _updateStatus(req, 2),
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
  }
}
