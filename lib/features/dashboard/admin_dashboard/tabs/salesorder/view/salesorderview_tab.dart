import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../bloc/salesorder_bloc.dart';
import '../bloc/salesorder_event.dart';
import '../bloc/salesorder_state.dart';



class SalesOrderTab extends StatefulWidget {
  const SalesOrderTab({super.key});

  @override
  State<SalesOrderTab> createState() => _SalesOrderTabState();
}

class _SalesOrderTabState extends State<SalesOrderTab> {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesOrderBloc>()
          .add(LoadInvoiceByType(0));
    });

  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),

      body:

      BlocConsumer<SalesOrderBloc, SalesOrderState>(
        listener: (context, state) {
          if (state is InvoiceLoaded && state.showWaitingSheet) {
            showBillingBottomSheet(
              context,
              state.waitingBilling,
            );
          }

          if (state is InvoiceLoaded &&
              state.employeeData != null) {
            _showDialogEmpDetails(state.employeeData!);
          }
        },
        builder: (context, state) {
          if (state is InvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InvoiceError) {
            return Center(child: Text(state.message));
          }

          if (state is! InvoiceLoaded) {
            return const SizedBox();
          }


          final data =
          state.saleDataAll.isNotEmpty ? state.saleDataAll[0] : {};

          return Column(
            children: [
              // ✅ ListView — Expanded la
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [

                      /// RANGE TOGGLE
                      Row(
                        children: [
                          _rangeButton(
                            text: "6 Months",
                            selected: state.is6Months,
                            onTap: () => context.read<SalesOrderBloc>().add(LoadMonthRange(6)),
                          ),
                          const SizedBox(width: 10),
                          _rangeButton(
                            text: "1 Year",
                            selected: !state.is6Months,
                            onTap: () => context.read<SalesOrderBloc>().add(LoadMonthRange(12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// BLUE HEADER CARD
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B9BD5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${state.currentMonthName} Sales",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// TOP SMALL STAT CARDS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _smallStatCard("Today", data["TodaySales"].toString(), data["TodayAmount"].toString(), true),
                          _smallStatCard("Yesterday", data["YesterdaySales"].toString(), data["YesterdayAmount"].toString(), false),
                          _smallStatCard("Weekly", data["WeekSales"].toString(), data["WeekAmount"].toString(), true),
                          _smallStatCard("Monthly", data["MonthSales"].toString(), data["MonthAmount"].toString(), true),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// WAITING BILLING ROW
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: InkWell(
                                onTap: () => context.read<SalesOrderBloc>().add(LoadWaitingBills(0)),
                                child: Text(
                                  "Waiting for Billing ",
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                      color: Color(0xFF1A2E5A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 15),
                              child: InkWell(
                                onTap: () => showBillingBottomSheet(context, state.waitingBilling),
                                child: Text(
                                  "${state.waitingBilling.length}",
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                      color: Color(0xFF1A2E5A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// MONTH LIST
                      SizedBox(
                        height: height * 0.55,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(), // 👈 இது முக்கியம்
                          itemCount: state.monthList.length,
                          itemBuilder: (context, index) {
                            final month = state.monthList[index];
                            final current = state.monthData[index]["SalesAmount"].toDouble();
                            final prev = index == 0 ? current : state.monthData[index - 1]["SalesAmount"].toDouble();
                            final diff = prev == 0 ? 0 : ((current - prev) / prev) * 100;
                            final isGrowth = diff >= 0;

                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => context.read<SalesOrderBloc>().add(LoadEmployeeInvData(index + 3)),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(month, style: const TextStyle(color: Color(0xFF1A2E5A), fontWeight: FontWeight.bold)),
                                    Text(current.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        Icon(isGrowth ? Icons.arrow_upward : Icons.arrow_downward,
                                            size: 16, color: isGrowth ? Colors.green : Colors.red),
                                        const SizedBox(width: 4),
                                        Text("${diff.abs().toStringAsFixed(1)}%",
                                            style: TextStyle(color: isGrowth ? Colors.green : Colors.red)),
                                      ],
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
              ),

              // ✅ Tab — எப்பவும் கீழே fixed ஆ தெரியும்
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 70,
                  child: Card(
                    elevation: 6,
                    color: colour.commonColorLight,
                    child: SalomonBottomBar(
                      duration: const Duration(seconds: 1),
                      currentIndex: state.selectedTabIndex,
                      onTap: (index) {
                        context.read<SalesOrderBloc>().add(LoadInvoiceByType(index + 1));
                      },
                      items: [
                        SalomonBottomBarItem(
                          icon: const Icon(Icons.receipt, color: colour.commonColor),
                          title: Text("All",
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: colour.commonColor,
                                fontSize: width <= 370 ? objfun.FontCardText + 2 : objfun.FontLow,
                              ),
                            ),
                          ),
                        ),
                        SalomonBottomBarItem(
                          icon: const Icon(Icons.receipt_long, color: colour.commonColor),
                          title: Text("With",
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: colour.commonColor,
                                fontSize: width <= 370 ? objfun.FontCardText + 2 : objfun.FontLow,
                              ),
                            ),
                          ),
                        ),
                        SalomonBottomBarItem(
                          icon: const Icon(Icons.receipt_long_outlined, color: colour.commonColor),
                          title: Text("Without",
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: colour.commonColor,
                                fontSize: width <= 370 ? objfun.FontCardText + 2 : objfun.FontLow,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          );

        },
      ),
    );
  }

  void _showDialogEmpDetails(List<dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// 🔵 HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Employee Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2E5A),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 15),

                /// 🔵 EMPLOYEE LIST
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final emp = data[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.grey.shade50,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// 👤 Employee Name
                            Row(
                              children: [
                                const Icon(Icons.person,
                                    size: 18,
                                    color: Color(0xFF5B9BD5)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    emp["EmployeeName"].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF1A2E5A),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            /// 💰 Sales Details Row
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [

                                /// Amount
                                Row(
                                  children: [
                                    const Text(
                                      "RM",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      emp["Amount"].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),


                                /// Sales Count
                                Row(
                                  children: [
                                    const Icon(Icons.shopping_cart,
                                        size: 16,
                                        color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      emp["SalesCount"].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔴 CLOSE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9BD5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Back to Dashboard",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }


}




Widget _rangeButton({
  required String text,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF5B9BD5)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
void showBillingBottomSheet(BuildContext context, List<dynamic> billingData) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Title + Close button
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Waiting for Billing Details",
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Scrollable list with modern design
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: billingData.length,
                  itemBuilder: (context, index) {
                    final item = billingData[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFFAD691),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Open detailed dialog
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFAD691),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Billing Details",
                                              style: GoogleFonts.lato(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, color: Colors.black),
                                              onPressed: () => Navigator.pop(context),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // Details
                                        _buildDetailRow(Icons.confirmation_number, "Bill No", "${item['BillNoDisplay']}"),
                                        _buildDetailRow(Icons.date_range, "Bill Date", "${item['BillDate']}"),
                                        _buildDetailRow(Icons.access_time, "Bill Time", "${item['BillTime']}"),
                                        _buildDetailRow(Icons.assignment, "Job Status", "${item['JobStatus']}"),
                                        _buildDetailRow(Icons.person, "Customer", "${item['CustomerName']}"),
                                        _buildDetailRow(Icons.badge, "Employee", "${item['EmployeeName']}"),
                                        _buildDetailRow(Icons.local_shipping, "Vessel", "${item['Loadingvesselname']}"),
                                        _buildDetailRow(Icons.anchor, "Port", "${item['SPort']}"),
                                        _buildDetailRow(Icons.calendar_today, "Pickup Date", "${item['SPickupDate']}"),
                                        _buildDetailRow(Icons.flight_takeoff, "ETA", "${item['ETA']}"),
                                        _buildDetailRow(Icons.monetization_on, "Net Amount", "₹${item['NetAmt']}"),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Left Icon inside circle
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.receipt_long, color: Color(0xFFE67E22), size: 28),
                              ),
                              const SizedBox(width: 12),

                              // Texts
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bill No: ${item['BillNo'] ?? ''}",
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3E50), // Dark Navy for readability
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Customer: ${item['CustomerName'] ?? ''}",
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold, // 👈 makes text bold
                                        color: Color(0xFF145A32),    // Dark green for readability
                                      ),
                                    ),

                                    const SizedBox(height: 2),
                                    Text(
                                      "Amount: ₹${item['NetAmt'] ?? ''}",
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE67E22), // Elegant orange highlight
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Trailing arrow inside box
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFE67E22)),
                              ),
                            ],
                          ),

                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
Widget _buildDetailRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF6A994E), ),
        const SizedBox(width: 8),
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color:Color(0xFF2C3E50),),
          ),
        ),
      ],
    ),
  );
}
Widget _smallStatCard(
    String title, String count, String amount, bool positive) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A2E5A))),
          const SizedBox(height: 6),
          Text(count,
              style: const TextStyle(
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              color: positive ? Colors.green : Colors.red,
            ),
          )
        ],
      ),
    ),
  );
}

