import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../core/models/model.dart';
import 'package:http/http.dart' as http;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

import 'SparePartsViewPage.dart';


class SparePartsEntry extends StatefulWidget {
  const SparePartsEntry({super.key});

  @override
  State<SparePartsEntry> createState() => _SparePartsEntryState();
}

class _SparePartsEntryState extends State<SparePartsEntry> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController driverController = TextEditingController();
  final TextEditingController sparePartsController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  File? _pickedImage;
  File? _pickedPDF;
  final ImagePicker _picker = ImagePicker();

  String? selectedTruck; // Truck Id
  DateTime? selectedDate; // Selected Date
  bool _isLoading = false;
  DateTime? fromDate;
  DateTime? toDate;
  bool progress = false;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();



  @override
  void initState() {
    super.initState();
    loadTruckList();
  }

  Future<void> loadTruckList() async {
    await OnlineApi.SelectTruckList(context, null);
    print("Truck Count: ${objfun.GetTruckList.length}");
    setState(() {}); // Refresh UI after list load
  }

  // ---------------- Submit Data ----------------
  Future<void> submitData(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var Comid = objfun.storagenew.getInt('Comid') ?? 0;

      // Prepare JSON part
      List<Map<String, dynamic>> sparePartsList = [
        {
          "Comid": Comid,
          "Id": 0,
          "TruckName": selectedTruck, // Send truck Id as string
          "DriverName": driverController.text.trim(),
          "SpareParts": sparePartsController.text.trim(),
          "EntryDate": selectedDate == null
              ? DateFormat('yyyy-MM-dd').format(DateTime.now())
              : DateFormat('yyyy-MM-dd').format(selectedDate!),

          "Amount": amountController.text.trim(),
          "DocumentPath": ""
        }
      ];

      // API URL
      var uri = Uri.parse("${objfun.apiInsertSpareParts}?Comid=$Comid");

      // Create Multipart Request
      var request = http.MultipartRequest("POST", uri);

      // JSON → string
      request.fields["details"] = jsonEncode(sparePartsList);
      request.fields["Comid"] = Comid.toString();

      // Attach Image / PDF
      if (_pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath("Files", _pickedImage!.path),
        );
      }
      if (_pickedPDF != null) {
        request.files.add(
          await http.MultipartFile.fromPath("Files", _pickedPDF!.path),
        );
      }

      // Send request
      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        print("SUCCESS: $respStr");

        // Clear form
        setState(() {
          selectedTruck = null;
          selectedDate = null;
          driverController.clear();
          sparePartsController.clear();
          amountController.clear();
          dateController.clear();
          _pickedImage = null;
          _pickedPDF = null;
          _isLoading = false;
        });
      } else {
        print("FAILED: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      objfun.msgshow(
        e.toString(),
        stackTrace.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Spare Parts Entry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter Spare Entry Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      // Truck Dropdown
                      SizedBox(
                        height: 60,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Truck Name",
                            border: OutlineInputBorder(),
                          ),
                          value: selectedTruck,
                          items: objfun.GetTruckList.map((truck) {
                            return DropdownMenuItem<String>(
                              value: truck.Id.toString(),
                              child: Text(truck.AccountName ?? ""),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTruck = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a truck";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      // Date Picker
                      SizedBox(
                        height: 60,
                        child: TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Select Date",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                                dateController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a date";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      buildInputField("Spare Parts", sparePartsController,
                          "Please enter spare parts"),
                      SizedBox(height: 16),
                      buildInputField("Amount", amountController,
                          "Please enter amount",
                          isNumber: true),
                      SizedBox(height: 20),

                      // Upload Document
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),


                        onPressed: () async {
                          final XFile? pickedFile =
                          await _picker.pickImage(
                              source: ImageSource.gallery);

                          if (pickedFile != null) {
                            String path = pickedFile.path.toLowerCase();
                            setState(() {
                              if (path.endsWith(".pdf")) {
                                _pickedPDF = File(pickedFile.path);
                                _pickedImage = null;
                              } else {
                                _pickedImage = File(pickedFile.path);
                                _pickedPDF = null;
                              }
                            });
                          }
                        },
                        icon: Icon(Icons.cloud_upload),
                        label: Text(
                          (_pickedImage == null && _pickedPDF == null)
                              ? "Upload Document"
                              : "Change Document",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Preview Section
                      if (_pickedImage != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Preview:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _pickedImage!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        )
                      else if (_pickedPDF != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PDF Selected:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.picture_as_pdf,
                                      color: Colors.red, size: 40),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _pickedPDF!.path.split('/').last,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),

                      Row(
                        children: [
                          // SUBMIT BUTTON
                          Expanded(
                            child: _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 55),
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => submitData(context),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // VIEW BUTTON
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 55),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SparePartsViewPage(
                                      fromDate: fromDate,
                                      toDate: toDate,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "View",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )


                    ]
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget buildInputField(String label, TextEditingController controller,
      String errorMessage,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) => value!.isEmpty ? errorMessage : null,
    );
  }
}
