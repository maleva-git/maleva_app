import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/DashBoard/Admin2/Admin2Dashboard.dart';
import 'ReviewEntryScreen.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class ReviewGridScreen extends StatefulWidget {
  const ReviewGridScreen({super.key});

  @override
  State<ReviewGridScreen> createState() => _ReviewGridScreenState();
}

class _ReviewGridScreenState extends State<ReviewGridScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedEmpId;
  List<EmployeeModel> _employees = [];
  List<Review> _reviews = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  // Load employee list
  Future<void> _loadEmployees() async {
    try {
      final comId = objfun.storagenew.getInt('Comid') ?? 0;
      final resultData = await objfun.apiAllinoneSelect(
        "${objfun.apiSelectEmployee}$comId&type=&type1=",
        null,
        null,
        context,
      );
      if (resultData.isNotEmpty) {
        final list = resultData.map<EmployeeModel>((e) => EmployeeModel.fromJson(e)).toList();
        setState(() => _employees = list);
      }
    } catch (error, stack) {
      objfun.msgshow(
        error.toString(),
        stack.toString(),
        Colors.white,
        Colors.red,
        null,
        18.0 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
    }
  }

  // Load reviews for selected employee and date range
  Future<void> _loadReviews() async {
    if (_selectedEmpId == null || _fromDate == null || _toDate == null) {
      setState(() => _reviews = []);
      return;
    }

    setState(() => _loading = true);
    final header = {'Content-Type': 'application/json; charset=UTF-8'};

    try {
      final from = DateFormat('yyyy-MM-dd').format(_fromDate!);
      final to = DateFormat('yyyy-MM-dd').format(_toDate!);

      final url = Uri.parse(objfun.apiSelectGoogleReview).replace(
        queryParameters: {
          'Comid': objfun.Comid.toString(),
          'fromdate': from,
          'todate': to,
          'Empid': _selectedEmpId.toString(),
        },
      ).toString();

      final resultData = await objfun.apiAllinoneSelectArray(url, null, header, context);

      if (resultData != null && resultData.isNotEmpty) {
        final list = resultData.map<Review>((e) => Review.fromJson(e)).toList();
        setState(() => _reviews = list);
      } else {
        setState(() => _reviews = []);
      }
    } catch (error, stack) {
      objfun.msgshow(
        error.toString(),
        stack.toString(),
        Colors.white,
        Colors.red,
        null,
        18.0 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // Delete review and reload current employee/date data
  Future<void> _deleteReview(int id) async {
    setState(() => _loading = true);
    try {
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final url = Uri.parse(objfun.apiDeleteGoogleReview).replace(
        queryParameters: {'Id': id.toString()},
      ).toString();

      await objfun.apiAllinoneSelectArray(url, null, header, context);

      // Reload reviews
      _loadReviews();
    } catch (error, stack) {
      objfun.msgshow(
        error.toString(),
        stack.toString(),
        Colors.white,
        Colors.red,
        null,
        18.0 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // Edit review
  Future<void> _editReview(Review review) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Admin2Dashboard(existingReview: review,initialTabIndex: 7)),
    );
    if (result == true) _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Reviews')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Date range picker
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _fromDate = picked.start;
                        _toDate = picked.end;
                      });
                      if (_selectedEmpId != null) _loadReviews();
                    }
                  },
                ),
                const SizedBox(width: 10),
                // Employee dropdown
                Expanded(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedEmpId,
                    hint: const Text('Select Employee'),
                    items: _employees
                        .map((e) => DropdownMenuItem(
                      value: e.Id,
                      child: Text(e.AccountName),
                    ))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedEmpId = v);
                      if (v != null && _fromDate != null && _toDate != null) {
                        _loadReviews();
                      } else {
                        setState(() => _reviews = []);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_selectedEmpId == null || _fromDate == null || _toDate == null)
                ? const Center(child: Text('Please select employee and date range'))
                : _reviews.isEmpty
                ? const Center(child: Text('No reviews found'))
                : ListView.separated(
              itemCount: _reviews.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final r = _reviews[i];
                return ListTile(
                  title: Text('${r.shopName} (${r.employeeName ?? ''})'),
                  subtitle: Text(
                    'Review: ${r.googleReview ?? ''}\nDate: ${DateFormat('yyyy-MM-dd').format(r.supportDate)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editReview(r),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteReview(r.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReviewEntryScreen()),
        ).then((value) {
          if (value == true) _loadReviews();
        }),
        child: const Icon(Icons.add),
      ),
    );
  }
}
