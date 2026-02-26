import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/MasterSearch/Employee.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../core/models/model.dart';
import 'ReviewGridScreen.dart';

class ReviewEntryScreen extends StatefulWidget {
  final Review? existingReview;
  const ReviewEntryScreen({super.key, this.existingReview});

  @override
  State<ReviewEntryScreen> createState() => _ReviewEntryScreenState();

}

class _ReviewEntryScreenState extends State<ReviewEntryScreen>{
  final _formKey = GlobalKey<FormState>();
  final _shopCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();

  final _reviewMsgCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedEmpId;
  int _selectedReview = 1;
  List<EmployeeModel> _employees = [];
  bool progress = false;
  @override
  void initState(){
    super.initState();
    _loadEmployee();
    if(widget.existingReview !=null){
          final r = widget.existingReview!;
          _shopCtrl.text = r.shopName;
          _mobileCtrl.text = r.mobileNo ?? '';

          _selectedReview = int.tryParse(r.googleReview ?? '1') ?? 1;

          _reviewMsgCtrl.text = r.googleMsg ?? '';
          _selectedDate = r.supportDate;
          _selectedEmpId = r.empReffid;
    }
  }


  Future<void> _loadEmployee() async {
    try {
      var comId = objfun.storagenew.getInt('Comid') ?? 0;

      var resultData = await objfun.apiAllinoneSelect(
        "${objfun.apiSelectEmployee}$comId&type=&type1=",
        null,
        null,
        context,
      );

      if (resultData.isNotEmpty) {
        final list = resultData
            .map<EmployeeModel>((e) => EmployeeModel.fromJson(e))
            .toList();

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
  Future _saveReview() async {
    List<Map<String, dynamic>> master = [
      {
        "Id": widget.existingReview?.id ?? 0,
        "ShopName": _shopCtrl.text.trim().toUpperCase(),
        "MobileNo": _mobileCtrl.text.trim(),
        "GoogleReview": _selectedReview.toString(),
        "GoogleMsg": _reviewMsgCtrl.text.trim(),
        "RefDate": _selectedDate.toIso8601String().split('T')[0],
        "EmpReffid": _selectedEmpId!,
      }
    ];

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    await objfun
        .apiAllinoneSelectArray(
      objfun.apiGoogleReviewInsert,
      master,
      header,
      context,
    )
        .then((resultData) async {
      if (resultData != null && resultData.toString().isNotEmpty) {
        // Case 1: resultData is a JSON object
        if (resultData is Map) {
          bool isSuccess = resultData['ok'] ?? false;
          String message = resultData['message'] ?? 'Something went wrong';

          await objfun.ConfirmationOK(message, context);
        }
        // Case 2: resultData is just a number (ID)
        else {
          int id = int.tryParse(resultData.toString()) ?? 0;

          if (id > 0) {
            await objfun.ConfirmationOK('Updated Successfully', context);
          } else {
            await objfun.ConfirmationOK('Unexpected response', context);
          }
        }
        _shopCtrl.clear();
        _mobileCtrl.clear();

        _reviewMsgCtrl.clear();
        _selectedDate = DateTime.now(); // reset to today or any default
        _selectedEmpId = null; // reset dropdown/selected employee
        _selectedReview = 1;
        setState(() {
          progress = true;
        });
      }

  }).onError((error, stackTrace) {
      setState(() {
        progress = true;
      });
      objfun.msgshow(
        error.toString(),
        stackTrace.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
    });
  }

  bool _showMobileField = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Google Review Entry')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Shop Name
                    TextFormField(
                      controller: _shopCtrl,
                      decoration: const InputDecoration(labelText: 'Company Name'),
                      validator: (v) => v!.isEmpty ? 'Enter Company Name' : null,
                    ),
                    const SizedBox(height: 10),

                    // Mobile No
                 // control this dynamically

                Visibility(
                visible: _showMobileField, // true → show, false → hide
                child: Column(
                  children: [
                    TextFormField(
                      controller: _mobileCtrl,
                      decoration: const InputDecoration(labelText: 'Mobile No'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

                    // Google Review Dropdown (1-5)
                    DropdownButtonFormField<int>(
                      value: (_selectedReview >= 1 && _selectedReview <= 5) ? _selectedReview : 1,
                      isExpanded: true,
                      items: List.generate(5, (index) => index + 1)
                          .map((val) => DropdownMenuItem<int>(
                        value: val,
                        child: Text(val.toString()),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedReview = val!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Google Review'),
                      validator: (v) => v == null ? 'Select Review' : null,
                    ),
                    const SizedBox(height: 10),

                    // Google Review Message
                    TextFormField(
                      controller: _reviewMsgCtrl,
                      decoration: const InputDecoration(labelText: 'Google Review Message'),
                    ),
                    const SizedBox(height: 16),

                    // Employee Dropdown
                    DropdownButtonFormField<int>(
                      value: _employees.any((e) => e.Id == _selectedEmpId) ? _selectedEmpId : null,
                      isExpanded: true,
                      items: _employees.map((e) => DropdownMenuItem<int>(
                        value: e.Id,
                        child: Text(e.AccountName),
                      )).toList(),
                      onChanged: (int? v) => setState(() => _selectedEmpId = v),
                      decoration: const InputDecoration(labelText: 'Employee'),
                      validator: (v) => v == null ? 'Select Employee' : null,
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Buttons: Save + View
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveReview,
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Navigate to ReviewGridScreen
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ReviewGridScreen()),
                              );
                              // If reviews were modified, optionally refresh current form
                              if (result == true) _loadEmployee(); // reload employees if needed
                            },
                            child: const Text('View'),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}