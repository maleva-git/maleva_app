import 'package:flutter/material.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverleave/data/leave_request_api.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverleave/data/leave_request_model.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/widgets/maleva_inputs.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart';
import 'package:maleva/core/models/model.dart';

class DriverLeaveRequestTab extends StatefulWidget {
  const DriverLeaveRequestTab({Key? key}) : super(key: key);

  @override
  State<DriverLeaveRequestTab> createState() => _DriverLeaveRequestTabState();
}

class _DriverLeaveRequestTabState extends State<DriverLeaveRequestTab> {
  bool _isLoading = false;
  List<LeaveRequestModel> _requests = [];
  
  // Form state
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  DateTime _searchFromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _searchToDate = DateTime.now();
  List<LeaveTypeModel> _leaveTypes = [];
  int? _selectedLeaveTypeId;
  int? _selectedDriverId;
  bool get _isDriverLogin => objfun.DriverLogin == 1;
  
  @override
  void initState() {
    super.initState();
    if (_isDriverLogin) {
      _selectedDriverId = objfun.EmpRefId;
    }
    _fetchRequests();
    _fetchLeaveTypes();
    if (!_isDriverLogin) {
      _fetchDrivers();
    }
  }

  Future<void> _fetchDrivers() async {
    if (objfun.GetDriverList.isEmpty) {
      await SelectDriverList(context, "");
    }
    if (mounted) setState(() {});
  }

  Future<void> _fetchLeaveTypes() async {
    final data = await LeaveRequestApi.getLeaveTypes(context);
    setState(() {
      _leaveTypes = data;
    });
  }
  
  Future<void> _fetchRequests() async {
    if (_selectedDriverId == null) {
      if (mounted) {
        if (!_isDriverLogin) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Driver to search leaves')));
        }
        setState(() {
          _requests = [];
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    final data = await LeaveRequestApi.getLeaveRequests(context, 
      applicantType: 2,
      applicantRefId: _selectedDriverId,
      fromDate: DateFormat('yyyy-MM-dd').format(_searchFromDate),
      toDate: DateFormat('yyyy-MM-dd').format(_searchToDate),
    );
    if (mounted) {
      setState(() {
        _requests = data;
        _isLoading = false;
      });
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

  Future<void> _submitLeave() async {
    if (_selectedLeaveTypeId == null || _selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Driver and Leave Reason')));
      return;
    }
    
    int days = _toDate.difference(_fromDate).inDays + 1;
    if (days <= 0) days = 1;
    
    setState(() => _isLoading = true);
    bool success = await LeaveRequestApi.addLeaveRequest(
      context,
      leaveTypeRefId: _selectedLeaveTypeId!,
      fromDate: _fromDate,
      toDate: _toDate,
      totalDays: days,
      applicantRefId: _selectedDriverId!,
      reason: _leaveTypes.firstWhere((e) => e.id == _selectedLeaveTypeId).name,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave Request Submitted')));
      _selectedLeaveTypeId = null;
      _fetchRequests();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit')));
    }
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
    return Column(
      children: [
        // Form
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Request Leave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MalevaDateField(
                      date: DateFormat('dd-MM-yyyy').format(_fromDate),
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MalevaDateField(
                      date: DateFormat('dd-MM-yyyy').format(_toDate),
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              if (!_isDriverLogin) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedDriverId,
                      hint: const Text('Select Driver'),
                      items: objfun.GetDriverList.map((e) => DropdownMenuItem<int>(
                        value: e.Id,
                        child: Text(e.AccountName),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedDriverId = val),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedLeaveTypeId,
                    hint: const Text('Select Leave Reason'),
                    items: _leaveTypes.map((e) => DropdownMenuItem<int>(
                      value: e.id,
                      child: Text(e.name),
                    )).toList(),
                    onChanged: (val) {
                      setState(() => _selectedLeaveTypeId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: colour.brand),
                onPressed: _isLoading ? null : _submitLeave,
                child: const Text('Submit Request', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        // Search Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey.shade50,
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
                  backgroundColor: colour.brand,
                  padding: const EdgeInsets.all(14),
                  minimumSize: const Size(0, 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  _fetchRequests(); // Trigger API call
                },
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        // List
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
                      elevation: 1,
                      child: ListTile(
                        title: Text('${DateFormat('dd MMM').format(req.fromDate)} - ${DateFormat('dd MMM').format(req.toDate)} (${req.totalDays} Days)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(req.reason, style: const TextStyle(fontSize: 13)),
                        trailing: Chip(
                          label: Text(req.statusName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: statusColor,
                          padding: EdgeInsets.zero,
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
