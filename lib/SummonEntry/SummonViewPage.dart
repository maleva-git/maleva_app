import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
class SummonViewPage extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;

  const SummonViewPage({super.key, this.fromDate, this.toDate});

  @override
  State<SummonViewPage> createState() => _SummonViewPageState();
}

class _SummonViewPageState extends State<SummonViewPage> {
  DateTime? fromDate;
  DateTime? toDate;

  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();

  bool progress = false;
  List<dynamic> spareList = [];

  @override
  void initState() {
    super.initState();

    fromDate = widget.fromDate;
    toDate = widget.toDate;

    if (fromDate != null) {
      fromCtrl.text = DateFormat("yyyy-MM-dd").format(fromDate!);
    }
    if (toDate != null) {
      toCtrl.text = DateFormat("yyyy-MM-dd").format(toDate!);
    }

    // Auto-load results if dates exist
    if (fromDate != null && toDate != null) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    setState(() => progress = true);

    String from = fromDate != null
        ? DateFormat("yyyy-MM-dd").format(fromDate!)
        : DateFormat("yyyy-MM-dd").format(DateTime.now());

    String to = toDate != null
        ? DateFormat("yyyy-MM-dd").format(toDate!)
        : DateFormat("yyyy-MM-dd").format(DateTime.now());

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    await objfun.apiAllinoneSelectArray(
      "${objfun.apiGetSummonParts}${objfun.Comid}&Fromdate=$from&Todate=$to",
      null,
      header,
      context,
    ).then((data) {
      setState(() {
        progress = false;
        print(data);
        spareList = List<Map<String, dynamic>>.from(
          data,
        );
      });
    }).onError((error, stack) {
      setState(() => progress = false);
      objfun.msgshow(error.toString(), stack.toString(), Colors.white,
          Colors.red, null, 16, objfun.tll, objfun.tgc, context, 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Summon Entries"),
        centerTitle: true,
        elevation: 3,
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- Date Filter ---------------- //
            // ---------------- Date Filter ---------------- //
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fromCtrl,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "From Date",
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(),
                          ),
                          onTap: pickFromDate,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: toCtrl,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "To Date",
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(),
                          ),
                          onTap: pickToDate,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Search Button Full Width
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: fetchData,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        "Search",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            SizedBox(height: 20),

            // ---------------- Loading Indicator ---------------- //
            if (progress) Center(child: CircularProgressIndicator()),

            // ---------------- Result List ---------------- //
            if (!progress)
              Expanded(
                child: spareList.isEmpty
                    ? Center(
                  child: Text(
                    "No Records Found",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: spareList.length,
                  itemBuilder: (context, index) {
                    var item = spareList[index];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_shipping, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Truck: ${item['TruckName']}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),

                            Text(
                              "Country: ${item['Country']}",
                              style: TextStyle(fontSize: 16),
                            ),

                            SizedBox(height: 6),

                            Text(
                              "Summon: ${item['Summon']}",
                              style: TextStyle(fontSize: 16),
                            ),

                            SizedBox(height: 6),

                            Text(
                              "Amount: ₹ ${item['Amount']}",
                              style: TextStyle(fontSize: 16),
                            ),

                            SizedBox(height: 6),

                            Text(
                              "Date: ${item['EntryDate']}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),

                            SizedBox(height: 12),

                            if (item['DocumentPath'] != "" && item['DocumentPath'] != null)

                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ImagePreviewDialog(
                                    imageUrl: objfun.port + item['DocumentPath'],
                                  ),
                                );
                              },
                              child: Image.network(
                                objfun.port + item['DocumentPath'],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )

                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }


  Future<void> pickFromDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: fromDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        fromDate = picked;
        fromCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  Future<void> pickToDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: toDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        toDate = picked;
        toCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }
}
class ImagePreviewDialog extends StatelessWidget {
  final String imageUrl;

  ImagePreviewDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: EdgeInsets.all(10),
      child: Stack(
        children: [
          // 🔍 Zoomable Image
          InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),

          // ❌ Close Button
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.close, size: 30, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 🔗 Share Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(Icons.share, color: Colors.black),
              onPressed: () {
                shareImage(imageUrl, context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
Future<void> shareImage(String url, BuildContext context) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/shared_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Download image bytes
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    // Share file
    await Share.shareXFiles([XFile(filePath)], text: "Shared Image");

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sharing failed: $e")),
    );
  }
}