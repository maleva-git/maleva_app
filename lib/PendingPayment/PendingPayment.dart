import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart'; // your existing model file
import 'package:maleva/core/utils/clsfunction.dart' as objfun; // your API helper

class PendingPayment extends StatefulWidget {
  const PendingPayment({super.key});

  @override
  State<PendingPayment> createState() => _PendingpaymentState();
}

class _PendingpaymentState extends State<PendingPayment> {
  // master list (parent) and details list (child)
  List<PaymentPendingModel> masterList = [];
  List<PaymentPendingModel> detailsList = []; // using same model for details as jqx had similar structure
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;

  // UI state
  String searchText = "";
  bool loading = false;
  String selectedFilter = "All";
  bool progress = false;
  // radio/filter options
  final List<String> filters = [
    "All",
    "Hire Purchase",
    "Vendor",
    "Utility",
    "Tenancy",
    "Monthly Purpose"
  ];

  @override
  void initState() {
    super.initState();
    loadData(); // initial load (you can call on filter change or date change as needed)
  }




  Future loadData({bool isDateSearch = false}) async {
    setState(() {
      progress = false;
    });


    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    // final from = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 30)));
    // final to = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String FromDate;
    String ToDate;

    if (isDateSearch && fromDate != null && toDate != null) {
      FromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
      ToDate = DateFormat('yyyy-MM-dd').format(toDate!);
    } else {
      // default one week logic (as you already have)
      DateTime now = DateTime.now();
      DateTime newDate = now.add(Duration(days: 6));
      FromDate = DateFormat('yyyy-MM-dd').format(newDate);
      ToDate = DateFormat('yyyy-MM-dd').format(newDate);
    }

 /*   if (type == 0) {
      FromDate = "2025-02-01";
      //FromDate = "2024-10-01";
    }*/
    Map<String, dynamic> master = {};
    var type = 400;
    master = {

      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': FromDate,
      'Todate': ToDate,

    };
    await objfun
        .apiAllinoneSelectArray(
        "${objfun.apiSelectPaymentPending}?Startindex=0&PageCount=$type"
        , master, header, context)

        .then((result) async {
      // The jqx code had Data[0].ExpenseReportModel and ExpenseReportDetailsModel
      // Handle common shapes:
      List<dynamic>? masterJson;
      List<dynamic>? detailsJson;

      if (result != null && result.isNotEmpty) {
        final first = result[0];

        // If API returns the nested object structure:
        if (first is Map && (first.containsKey('ExpenseReportModel') || first.containsKey('ExpenseReportDetailsModel'))) {
          masterJson = (first['ExpenseReportModel'] ?? []) as List<dynamic>?;
          detailsJson = (first['ExpenseReportDetailsModel'] ?? []) as List<dynamic>?;
        } else {
          // If API returns direct list of master rows, assume result is master list
          // Also attempt to find details array if present in result as second element
          if (result.length >= 2 && result[1] is List) {
            masterJson = result[0] as List<dynamic>?;
            detailsJson = result[1] as List<dynamic>?;
          } else {
            // fallback: assume entire result is master rows
            masterJson = result as List<dynamic>?;
            detailsJson = [];
          }
        }
      }

      // Map JSON to models (assuming PaymentPendingModel.fromJson exists)
      if (masterJson != null) {
        masterList = masterJson
            .map<PaymentPendingModel>((e) => PaymentPendingModel.fromJson(e))
            .toList();
      } else {
        masterList = [];
      }

      if (detailsJson != null) {
        detailsList = detailsJson
            .map<PaymentPendingModel>((e) => PaymentPendingModel.fromJson(e))
            .toList();
      } else {
        detailsList = [];
      }

    }).onError((error, stackTrace) {
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
          2);
    });

    setState(() {
      progress = true;
    });
  }


  Future<void> loadData1() async {
    setState(() => loading = true);

    try {
      // Example: using last 30 days range and Empid 1 (modify as required)
      final from = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 30)));
      final to = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final url = Uri.parse(objfun.apiSelectPaymentPending).replace(queryParameters: {
        'Comid': objfun.Comid.toString(),
        'fromdate': from,
        'todate': to,
        // 'Empid': objfun.Empid != null ? objfun.Empid.toString() : "1",
      }).toString();

      final headers = {'Content-Type': 'application/json; charset=UTF-8'};

      final result = await objfun.apiAllinoneSelectArray(url, null, headers, context);

      // The jqx code had Data[0].ExpenseReportModel and ExpenseReportDetailsModel
      // Handle common shapes:
      List<dynamic>? masterJson;
      List<dynamic>? detailsJson;

      if (result != null && result.isNotEmpty) {
        final first = result[0];

        // If API returns the nested object structure:
        if (first is Map && (first.containsKey('ExpenseReportModel') || first.containsKey('ExpenseReportDetailsModel'))) {
          masterJson = (first['ExpenseReportModel'] ?? []) as List<dynamic>?;
          detailsJson = (first['ExpenseReportDetailsModel'] ?? []) as List<dynamic>?;
        } else {
          // If API returns direct list of master rows, assume result is master list
          // Also attempt to find details array if present in result as second element
          if (result.length >= 2 && result[1] is List) {
            masterJson = result[0] as List<dynamic>?;
            detailsJson = result[1] as List<dynamic>?;
          } else {
            // fallback: assume entire result is master rows
            masterJson = result as List<dynamic>?;
            detailsJson = [];
          }
        }
      }

      // Map JSON to models (assuming PaymentPendingModel.fromJson exists)
      if (masterJson != null) {
        masterList = masterJson.map<PaymentPendingModel>((e) => PaymentPendingModel.fromJson(e)).toList();
      } else {
        masterList = [];
      }

      if (detailsJson != null) {
        detailsList = detailsJson.map<PaymentPendingModel>((e) => PaymentPendingModel.fromJson(e)).toList();
      } else {
        detailsList = [];
      }
    } catch (e, st) {
      // print for debug
      print("LoadPaymentPendingView error: $e\n$st");
      masterList = [];
      detailsList = [];
    }

    setState(() => loading = false);
  }

  // helper: get nested details for a given master record (group by SubExpenseName)
  List<PaymentPendingModel> _getRelatedDetails(PaymentPendingModel master) {
/*    print("---- DEBUG START ----");
    print("MASTER VALUE: '${master.SubExpenseName}'");

    for (var d in detailsList) {
      print("DETAIL VALUE: '${d.SubExpenseName}'");
    }

    print("---- DEBUG END ----");*/

    return detailsList.where((detail) =>
    detail.SubExpenseName?.toLowerCase().contains(
        master.SubExpenseName!.split(" ")[0].toLowerCase()
    ) ?? false
    ).toList();

  }

  // apply search + radio filter
  List<PaymentPendingModel> filteredMaster(){
    final q = searchText.trim().toLowerCase();
    return masterList.where((m) {
      // filter by category - assumes there is a field to match categories (example uses BankName or another)
      // If you have a specific field in model for Supplier/Category replace this condition accordingly.
      bool matchesFilter = selectedFilter == "All" ||
          (m.BankName != null && m.BankName!.toLowerCase() == selectedFilter.toLowerCase()) ||
          (m.SubExpenseName != null && m.SubExpenseName!.toLowerCase() == selectedFilter.toLowerCase()) ||
          // fallback: check ExpenseName contains filter text (useful if you encode category in name)
          (m.ExpenseName != null && m.ExpenseName!.toLowerCase().contains(selectedFilter.toLowerCase()));

      bool matchesSearch = q.isEmpty ||
          (m.ExpenseName != null && m.ExpenseName!.toLowerCase().contains(q)) ||
          (m.BankName != null && m.BankName!.toLowerCase().contains(q)) ||
          (m.SubExpenseName != null && m.SubExpenseName!.toLowerCase().contains(q));

      return matchesFilter && matchesSearch;
    }).toList();
  }

  double get _totalFiltered {
    final list = filteredMaster(); // <- FIX
    double total = 0;

    for (var m in list) {
      total += (m.Amount ?? 0);
    }
    return total;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Pending Payment", style: TextStyle(fontSize: 19)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 26),
            onPressed: () => loadData(),
            tooltip: "Reload",
          )
        ],
      ),

      body: Column(
        children: [

          // 🔹 Filter radio strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((f) {
                  final selected = selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(f, style: const TextStyle(fontSize: 13)),
                      selected: selected,
                      selectedColor: Colors.indigo,
                      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                      onSelected: (_) => setState(() => selectedFilter = f),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
// Date filter section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fromCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "From Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() {
                          fromDate = picked;
                          fromCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: toCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "To Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() {
                          toDate = picked;
                          toCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: () => loadData(isDateSearch: true),
                  child: Text("Search"),
                ),
              ],
            ),
          ),

          // 🔹 Search box — Glass style
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 12),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(12),
          //       color: Colors.white,
          //       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
          //     ),
          //     child: TextField(
          //       decoration: const InputDecoration(
          //         prefixIcon: Icon(Icons.search),
          //         hintText: "Search Expense / Bank / Invoice",
          //         border: InputBorder.none,
          //       ),
          //       onChanged: (v) => setState(() => searchText = v),
          //     ),
          //   ),
          // ),

          const SizedBox(height: 8),

          // 🔹 Total amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 6),
                Text("RM ${_totalFiltered.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 17, color: Colors.indigo)),
                const Spacer(),
                loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const SizedBox.shrink(),
              ],
            ),
          ),

          const Divider(height: 1),

          // 🔹 Master list
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredMaster().isEmpty
                ? const Center(
              child: Text("No Records Found", style: TextStyle(fontSize: 16)),
            )
                : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: filteredMaster().length,
                itemBuilder: (_, idx) {
                  final item = filteredMaster()[idx];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: GestureDetector(
                      onTap: () => _openDetailPopup(item),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3)
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.ExpenseName ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            const SizedBox(height: 6),
                            Text("Bank: ${item.BankName ?? ""}", style: const TextStyle(color: Colors.black54)),
                            Text("${item.SubExpenseName ?? ""}", style: const TextStyle(color: Colors.black87)),
                            Text("Due: ${item.ExpenceDueDate}", style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text("RM ${((item.Amount ?? 0)).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.indigo)),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }


  void _openDetailPopup(PaymentPendingModel master) {
    final related = _getRelatedDetails(master);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 6,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(master.ExpenseName ?? "",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Bank: ${master.BankName ?? ""}",
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 10),
                  const Divider(),

                  const SizedBox(height: 10),
                  const Text("Details",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  related.isEmpty
                      ? const Expanded(
                    child: Center(
                      child: Text("No detail records available"),
                    ),
                  )
                      : Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: related.length,
                      itemBuilder: (_, i) {
                        final d = related[i];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.indigo.shade50,
                          child: ListTile(
                            title: Text(d.SubExpenseName ?? ""),
                            subtitle: Text("Due: ${d.DueDate}"),
                            trailing: Text(
                              "RM ${((d.Amount ?? 0)).toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child:
                      const Text("Close", style: TextStyle(fontSize: 16)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

}
