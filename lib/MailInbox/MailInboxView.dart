import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart'; // contains EmployeeModel + EmailModel

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;
  List<EmailModel> emails = [];
  bool progress = false;
  int EmailId = 0;
  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  Future<void> _loadEmployee() async {
    try {
      final comId = objfun.storagenew.getInt('Comid') ?? 0;
      final resultData = await objfun.apiAllinoneSelect(
        "${objfun.apiSelectEmployee}$comId&type=&type1=",
        null,
        null,
        context,
      );

      if (resultData != null && resultData.isNotEmpty) {
        final list = resultData
            .map<EmployeeModel>((e) => EmployeeModel.fromJson(e))
            .toList();

        setState(() => _employees = list);

        if (_employees.isNotEmpty) {
          _selectedEmployee = _employees.first;
          loadEmails(_selectedEmployee!.Id);
        }
      }
    } catch (e, stack) {
      objfun.msgshow(
        e.toString(),
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
  Future<void> loadEmails(int empId) async {
    try {
      final header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': (objfun.storagenew.getInt('Comid') ?? 0).toString(),
      };

      final master = [
        {"Id": empId}
      ];

      final rawResult = await objfun.apiAllinoneMapSelect(
        objfun.apiSelectEmailData,
        master,
        header,
        context,
      );

      List<dynamic> emailsJson = [];
      final result = jsonDecode(rawResult);
      if (result is Map<String, dynamic>) {
        debugPrint("Raw API response: $result");

        if (result["unread_unreplied_emails"] is List) {
          emailsJson = result["unread_unreplied_emails"] as List;
        } else {
          debugPrint("⚠️ unread_unreplied_emails is not a list");
        }

        debugPrint("Emails JSON from API: $emailsJson");
      }

      setState(() {
        emails = emailsJson
            .map((e) => EmailModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });

    } catch (e, stack) {
      setState(() => emails = []);
      objfun.msgshow(
        e.toString(),
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
  Future<void> saveEmails() async {
    final confirm = await objfun.ConfirmationMsgYesNo(
      context,
      "Do You Want to Update?",
    );
    if (!confirm) return;

    // Only save emails where Active checkbox is true
    final toSave = emails.where((e) => e.isActive).toList();
    if (toSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active emails selected to save")),
      );
      return;
    }

    setState(() => progress = true);

    try {
      final header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': (objfun.storagenew.getInt('Comid') ?? 0).toString(),
      };

      final payload = toSave.map((e) => {
        'Id': 0, // new email
        'EmployeeRefId': _selectedEmployee?.Id,
        'EmailID': e.emailId,
        'Subject': e.subject,
        'Sender': e.sender,
        'MessageId': e.messageId,
        'ReceivedDate': e.receivedDate.toIso8601String(),
        'Comid': objfun.storagenew.getInt('Comid') ?? 0,
        'IsUnread': e.isUnread ? 1 : 0,
        'IsReplied': e.isReplied ? 1 : 0,
        'Active': 1, // mark as active
      }).toList();

      final result = await objfun.apiAllinoneMapSelect(
        objfun.apiInsertMailMaster,
        payload,
        header,
        context,
      );

      if (result is String && result.isNotEmpty) {
        // Show result as success message
        await objfun.ConfirmationOK('Updated Successfully:\n$result', context);
      //  Navigator.pop(context);
      } else {
        // If result is empty or null
        objfun.msgshow(
          "Failed to save emails",
          '',
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
    } catch (e, stack) {
      objfun.msgshow(
        e.toString(),
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
      setState(() => progress = false);
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Email InBox"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔻 Employee Dropdown
            DropdownButtonFormField<EmployeeModel>(
              isExpanded: true,
              value: _selectedEmployee,
              decoration: InputDecoration(
                labelText: "Select Employee",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _employees.map((emp) {
                return DropdownMenuItem(
                  value: emp,
                  child: Text(emp.AccountName, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedEmployee = value);
                if (value != null) loadEmails(value.Id);
              },
            ),
            const SizedBox(height: 16),

            // 🔻 Emails List
            Expanded(
              child: ListView.builder(
                itemCount: emails.length,
                itemBuilder: (context, index) {
                  final email = emails[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Name + Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                email.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                email.receivedDate.toLocal().toString().split('.').first,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          Text(
                            email.subject,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            "From: ${email.sender}",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Checkbox row
                          Wrap(
                            spacing: 12, // horizontal spacing
                            runSpacing: 4, // vertical spacing
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: email.isActive,
                                    onChanged: (v) {
                                      setState(() {
                                        emails[index] = email.copyWith(isActive: v ?? false);
                                      });
                                    },
                                  ),
                                  const Text("Active"),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: email.isUnread,
                                    onChanged: (v) {
                                      setState(() {
                                        emails[index] = email.copyWith(isUnread: v ?? false);
                                      });
                                    },
                                  ),
                                  const Text("read"),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: email.isReplied,
                                    onChanged: (v) {
                                      setState(() {
                                        emails[index] = email.copyWith(isReplied: v ?? false);
                                      });
                                    },
                                  ),
                                  const Text("Replied"),
                                ],
                              ),
                            ],
                          )


                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Emails"),
                onPressed: saveEmails,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

}
