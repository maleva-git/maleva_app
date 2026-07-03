import 'package:flutter/material.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverleave/data/leave_request_api.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverleave/data/leave_request_model.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

class AdminLeaveApprovalTab extends StatefulWidget {
  const AdminLeaveApprovalTab({Key? key}) : super(key: key);

  @override
  State<AdminLeaveApprovalTab> createState() => _AdminLeaveApprovalTabState();
}

class _AdminLeaveApprovalTabState extends State<AdminLeaveApprovalTab> {
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
    final data = await LeaveRequestApi.getLeaveRequests(context, applicantType: 2); // 2 for Drivers
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
              const Expanded(child: Text('Driver Leave Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
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
                    Color statusColor = Colors.orange;
                    if (req.statusRefId == 2) statusColor = Colors.green;
                    if (req.statusRefId == 3) statusColor = Colors.red;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(req.applicantName.isNotEmpty ? req.applicantName : 'Driver ${req.applicantRefId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Chip(
                                  label: Text(req.statusName, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  backgroundColor: statusColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${DateFormat('dd MMM yyyy').format(req.fromDate)} to ${DateFormat('dd MMM yyyy').format(req.toDate)} (${req.totalDays} Days)'),
                            const SizedBox(height: 4),
                            Text('Reason: ${req.reason}', style: const TextStyle(color: Colors.grey)),
                            if (req.reviewRemark.isNotEmpty)
                              Text('Remark: ${req.reviewRemark}', style: const TextStyle(color: Colors.redAccent)),
                            
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: colour.brand),
                                      icon: const Icon(Icons.rate_review, color: Colors.white, size: 18),
                                      onPressed: () => _updateStatus(req, 2), // Default to approve in dialog
                                      label: const Text('Action', style: TextStyle(color: Colors.white)),
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
  }
}
