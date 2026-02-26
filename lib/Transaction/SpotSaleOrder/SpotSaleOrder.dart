import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../DashBoard/Boarding/SpotSaleEntryView.dart';

import 'package:http/http.dart' as http;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;



class Spotsaleorder extends StatefulWidget {
  const Spotsaleorder({super.key});

  @override
  State<Spotsaleorder> createState() => _SpotsaleorderState();
}

class _SpotsaleorderState extends State<Spotsaleorder> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController driverController = TextEditingController();
  final TextEditingController sparePartsController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  File? _pickedImage;
  File? _pickedPDF;
  final ImagePicker _picker = ImagePicker();
  int editId = 0;
  String? selectedTruck; // Truck Id
  DateTime? selectedDate; // Selected Date
  bool _isLoading = false;
  DateTime? fromDate;
  DateTime? toDate;
  bool progress = false;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  String? selectedJobType; // Truck Id
  String? selectedJobStatus; // Truck Id
  String? selectedPort; // Truck Id
  String? selectedCustomer; // Truck Id
  String? _NetworkImageUrl; // Truck Id

  final TextEditingController VehicleNameController = TextEditingController();
  final TextEditingController AWBNoController = TextEditingController();
  final TextEditingController QuantityController = TextEditingController();
  final TextEditingController TotalWeightController = TextEditingController();

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
  Future<void> submitSpotSaleOrder(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var Comid = objfun.storagenew.getInt('Comid') ?? 0;
      var EmployeeId = int.tryParse(
          objfun.storagenew.getString('OldUsername') ?? '0'
      ) ?? 0;



      List<Map<String, dynamic>> SpotSalesOrderList = [
        {
          "CompanyRefId": Comid,
          "Id": editId,
          "EmployeeRefId": EmployeeId,
          "JobMasterRefId": selectedJobType,
          "CustomerRefId": 0,
          "VechicelName": VehicleNameController.text.trim(),
          "AWBNo": AWBNoController.text.trim(),
          "Quantity": QuantityController.text.trim(),
          "TotalWeight": TotalWeightController.text.trim(),
          "JStatus": selectedJobStatus,
          "Port": selectedPort,
          // "EntryDate": selectedDate == null
          //     ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          //     : DateFormat('yyyy-MM-dd').format(selectedDate!),
          "DocumentPath": ""
        }
      ];

      // API URL
      var uri = Uri.parse("${objfun.apiInsertSpotSaleEntry}?Comid=$Comid");

      // Create Multipart Request
      var request = http.MultipartRequest("POST", uri);

      // JSON → string
      request.fields["details"] = jsonEncode(SpotSalesOrderList);
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
          selectedJobType = null;
          selectedCustomer = null;
          selectedJobStatus = null;
          selectedPort = null;
          EmployeeId = 0;
          selectedDate = null;
          driverController.clear();
          VehicleNameController.clear();
          AWBNoController.clear();
          QuantityController.clear();
          TotalWeightController.clear();
          _pickedImage = null;
          _NetworkImageUrl = null;
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
      body:

      SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔹 Title
              Text(
                " Spot Sale Entry ",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // 🔹 Main Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [

                      // 🔹 Truck Dropdown
                      SizedBox(
                        height: 60,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Job Type",
                            border: OutlineInputBorder(),
                          ),
                          value: selectedJobType,
                          isExpanded: true,
                          items: objfun.JobTypeList.map((JobType) {
                            return DropdownMenuItem<String>(
                              value: JobType.Id.toString(),
                              child: Text(JobType.Name ?? ""),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedJobType = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a Job Type";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      SizedBox(
                        height: 60,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Status",
                            border: OutlineInputBorder(),
                          ),
                          value: selectedJobStatus,
                          isExpanded: true,
                          items: objfun.JobStatusList.map((JobStatus) {
                            return DropdownMenuItem<String>(
                              value: JobStatus.Id.toString(),
                              child: Text(JobStatus.Name ?? ""),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedJobStatus = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a Status";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      SizedBox(
                        height: 60,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Port",
                            border: OutlineInputBorder(),
                          ),
                          value: selectedPort,
                          isExpanded: true,
                          items: objfun.Portlist.map((truck) {
                            return DropdownMenuItem<String>(
                              value: truck.name.toString(),
                              child: Text(truck.name ?? ""),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPort = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a Port";
                            }
                            return null;
                          },
                        ),
                      ),
                      /*     SizedBox(height: 16),
                                  // 🔹 Date Picker
                                  SizedBox(
                                    height: 60,
                                    child: TextFormField(
                                      controller: state.dateController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        labelText: "Select Date",
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      onTap: () async {
                                        DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: state.selectedDate ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null) {
                                          state.setState(() {
                                            state.selectedDate = picked;
                                            state.dateController.text =
                                                DateFormat('yyyy-MM-dd').format(picked);
                                          });
                                        }
                                      },
                                      validator: (value) =>
                                      value!.isEmpty ? "Please select a date" : null,
                                    ),
                                  ),*/
                    SizedBox(height: 15),

                    buildInputField("Cargo Qty", QuantityController, "Please enter Cargo Qty", height: 60.0),

                    SizedBox(height: 15),

                    buildInputField("Vechicle Name", VehicleNameController, "Please enter Vechicle Name", height: 60.0),

                    SizedBox(height: 15),

                    buildInputField("AirWaybillNumber", AWBNoController, "Please enter AirWaybillNumber", height: 60.0),

                    SizedBox(height: 15),

                    buildInputField("Cargo Weight", TotalWeightController,
                        "Please enter Cargo Weight",
                        isNumber: true),
                    SizedBox(height: 20),

                    // 🔹 Upload File Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final XFile? picked =
                          await _picker.pickImage(source: ImageSource.gallery);

                          if (picked != null) {
                            String path = picked.path.toLowerCase();
                            setState(() {
                              if (path.endsWith(".pdf")) {
                                _pickedPDF = File(picked.path);
                                _pickedImage = null;
                              } else {
                                _pickedImage = File(picked.path);
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
                        ),
                      ),
                      SizedBox(height: 20),

                      // 🔹 Preview Section
                      if (_pickedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _pickedImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (_pickedPDF != null)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _pickedPDF!.path.split('/').last,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_NetworkImageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _NetworkImageUrl!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text("Unable to load image");
                              },
                            ),
                          )
                        else
                          Text("No document uploaded"),


                      SizedBox(height: 20),

                      // 🔹 Submit + View Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                              onPressed: () => submitSpotSaleOrder(context),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 55),
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SpotSaleEntryView(
                                      fromDate: fromDate,
                                      toDate: toDate,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 55),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "View",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget buildInputField(
      String label,
      TextEditingController controller,
      String errorMessage,
      {bool isNumber = false, double? height}) {

    // If height is provided, wrap the TextFormField in a SizedBox with that height.
    return SizedBox(
      height: height ?? 60.0,  // Default height is 60.0 if no height is passed
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          // height adjustment
          contentPadding: height != null
              ? EdgeInsets.symmetric(vertical: height)   // apply custom height
              : EdgeInsets.symmetric(vertical: 14),
        ),
        validator: (value) => value!.isEmpty ? errorMessage : null,
      ),
    );
  }
}
