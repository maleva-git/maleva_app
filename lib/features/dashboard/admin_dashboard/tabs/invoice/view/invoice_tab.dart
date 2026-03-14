import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../../../core/colors/colors.dart';
import '../bloc/invoice_bloc.dart';
import '../bloc/invoice_event.dart';
import '../bloc/invoice_state.dart';

class InvoiceTab extends StatefulWidget {
  const InvoiceTab({super.key});

  @override
  State<InvoiceTab> createState() => _InvoiceTabState();
}

class _InvoiceTabState extends State<InvoiceTab> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceBloc>().add(LoadInvoiceByType(0));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceLoaded && state.showWaitingSheet) {
            showBillingBottomSheet(context, state.waitingBilling);
          }
          if (state is InvoiceLoaded && state.employeeData != null) {
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
          if (state is! InvoiceLoaded) return const SizedBox();

          final data = state.saleDataAll.isNotEmpty
              ? state.saleDataAll[0]
              : {};

          return isTablet
              ? _buildTabletLayout(context, state, data)
              : _buildMobileLayout(context, state, data);
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET LAYOUT
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context, InvoiceLoaded state, Map data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LEFT (60%)
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
                _buildTodayYesterdayChartSized(data, height: 260),
                const SizedBox(height: 16),
                Row(children: [
                  _rangeButton(
                    text: "6 Months",
                    selected: state.is6Months,
                    onTap: () =>
                        context.read<InvoiceBloc>().add(LoadMonthRange(6)),
                  ),
                  const SizedBox(width: 10),
                  _rangeButton(
                    text: "1 Year",
                    selected: !state.is6Months,
                    onTap: () =>
                        context.read<InvoiceBloc>().add(LoadMonthRange(12)),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildHeaderCard(state, fontSize: 20),
                const SizedBox(height: 16),
                _buildStatCards(context, state, data, isTablet: true),
                const SizedBox(height: 16),
                _buildWaitingRow(context, state, isTablet: true),
              ]),
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT (40%)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4),
                  child: Text(
                    'Monthly Breakdown',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2E5A),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildMonthList(context, state, isTablet: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context, InvoiceLoaded state, Map data) {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(children: [
        _buildTodayYesterdayChartSized(data, height: 200),
        const SizedBox(height: 16),
        Row(children: [
          _rangeButton(
            text: "6 Months",
            selected: state.is6Months,
            onTap: () =>
                context.read<InvoiceBloc>().add(LoadMonthRange(6)),
          ),
          const SizedBox(width: 10),
          _rangeButton(
            text: "1 Year",
            selected: !state.is6Months,
            onTap: () =>
                context.read<InvoiceBloc>().add(LoadMonthRange(12)),
          ),
        ]),
        const SizedBox(height: 20),
        _buildHeaderCard(state, fontSize: 18),
        const SizedBox(height: 20),
        _buildStatCards(context, state, data, isTablet: false),
        const SizedBox(height: 16),
        _buildWaitingRow(context, state, isTablet: false),
        const SizedBox(height: 20),
        SizedBox(
          height: height * 0.55,
          child: _buildMonthList(context, state, isTablet: false),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ══════════════════════════════════════════════════════

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
          color: selected ? AppColors.appBarColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.appBarColor),
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

  Widget _buildHeaderCard(InvoiceLoaded state,
      {required double fontSize}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appBarColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "${state.currentMonthName} Sales",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildStatCards(
      BuildContext context, InvoiceLoaded state, Map data,
      {required bool isTablet}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _smallStatCard("Today",
            data["TodaySales"].toString(),
            data["TodayAmount"].toString(),
            true, isTablet: isTablet),
        _smallStatCard("Yesterday",
            data["YesterdaySales"].toString(),
            data["YesterdayAmount"].toString(),
            false, isTablet: isTablet),
        _smallStatCard("Weekly",
            data["WeekSales"].toString(),
            data["WeekAmount"].toString(),
            true, isTablet: isTablet),
        _smallStatCard("Monthly",
            data["MonthSales"].toString(),
            data["MonthAmount"].toString(),
            true, isTablet: isTablet),
      ],
    );
  }

  Widget _smallStatCard(
      String title, String count, String amount, bool positive,
      {bool isTablet = false}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 5 : 4),
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  color: const Color(0xFF1A2E5A),
                )),
            SizedBox(height: isTablet ? 8 : 6),
            Text(count,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 16 : 14,
                )),
            SizedBox(height: isTablet ? 5 : 4),
            Text(amount,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  color: positive ? Colors.green : Colors.red,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingRow(
      BuildContext context, InvoiceLoaded state,
      {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 16 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: InkWell(
            onTap: () =>
                context.read<InvoiceBloc>().add(LoadWaitingBills(0)),
            child: Text(
              "Waiting for Billing ",
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: const Color(0xFF1A2E5A),
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 14 : 12,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              top: 5, left: 5, right: 5, bottom: 15),
          child: InkWell(
            onTap: () =>
                showBillingBottomSheet(context, state.waitingBilling),
            child: Text(
              "${state.waitingBilling.length}",
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: const Color(0xFF1A2E5A),
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 14 : 12,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildMonthList(
      BuildContext context, InvoiceLoaded state,
      {required bool isTablet}) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: state.monthList.length,
      itemBuilder: (context, index) {
        final month = state.monthList[index];
        final current =
        state.monthData[index]["SalesAmount"].toDouble();
        final prev = index == 0
            ? current
            : state.monthData[index - 1]["SalesAmount"].toDouble();
        final diff =
        prev == 0 ? 0 : ((current - prev) / prev) * 100;
        final isGrowth = diff >= 0;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context
              .read<InvoiceBloc>()
              .add(LoadEmployeeInvData(index + 3)),
          child: Container(
            margin: EdgeInsets.only(bottom: isTablet ? 10 : 12),
            padding: EdgeInsets.all(isTablet ? 18 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(month,
                    style: TextStyle(
                      color: const Color(0xFF1A2E5A),
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 15 : 13,
                    )),
                Text(current.toStringAsFixed(0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 15 : 13,
                    )),
                Row(children: [
                  Icon(
                    isGrowth
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: isTablet ? 18 : 16,
                    color: isGrowth ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${diff.abs().toStringAsFixed(1)}%",
                    style: TextStyle(
                      color: isGrowth ? Colors.green : Colors.red,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayYesterdayChartSized(Map data, {required double height}) {
    return SizedBox(
      height: height,
      child: _buildTodayYesterdayChart(
        Map<String, dynamic>.from(data),
      ),
    );
  }


  Widget _buildTodayYesterdayChart(Map<String, dynamic> data) {
    final today =
        double.tryParse(data["TodayAmount"].toString()) ?? 0;
    final yesterday =
        double.tryParse(data["YesterdayAmount"].toString()) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.appBarColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.appBarColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text("Today vs Yesterday",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1A2E5A))),
            const Spacer(),
            Container(
                width: 12, height: 3, color: AppColors.appBarColor),
            const SizedBox(width: 4),
            const Text("Today",
                style: TextStyle(
                    fontSize: 11, color: Color(0xFF1A2E5A))),
            const SizedBox(width: 12),
            Container(width: 12, height: 3, color: Colors.orange),
            const SizedBox(width: 4),
            const Text("Yesterday",
                style: TextStyle(
                    fontSize: 11, color: Color(0xFF1A2E5A))),
          ]),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Start', 'Mid', 'End'];
                        if (value.toInt() >= labels.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(labels[value.toInt()],
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipRoundedRadius: 8,
                    tooltipBorder: BorderSide(
                        color: AppColors.appBarColor, width: 1),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final label = spot.barIndex == 0
                            ? "Today"
                            : "Yesterday";
                        return LineTooltipItem(
                          "$label\nRM ${spot.y.toStringAsFixed(0)}",
                          TextStyle(
                            color: spot.barIndex == 0
                                ? AppColors.appBarColor
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 0),
                      FlSpot(1, today * 0.6),
                      FlSpot(2, today)
                    ],
                    isCurved: true,
                    color: AppColors.appBarColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: AppColors.appBarColor,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.appBarColor.withOpacity(0.2),
                          AppColors.appBarColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 0),
                      FlSpot(1, yesterday * 0.6),
                      FlSpot(2, yesterday)
                    ],
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.orange,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.2),
                          Colors.orange.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              borderRadius: BorderRadius.circular(25)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Employee Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E5A),
                        )),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
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
                            Row(children: [
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
                            ]),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Text("RM",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  const SizedBox(width: 4),
                                  Text(emp["Amount"].toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green)),
                                ]),
                                Row(children: [
                                  const Icon(Icons.shopping_cart,
                                      size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(emp["SalesCount"].toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange)),
                                ]),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appBarColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Dashboard",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

} // ← _InvoiceTabState closing brace

// ══════════════════════════════════════════════════════
// TOP-LEVEL FUNCTIONS (class வெளியே — OK)
// ══════════════════════════════════════════════════════
void showBillingBottomSheet(
    BuildContext context, List<dynamic> billingData) {
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
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Waiting for Billing Details",
                      style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: billingData.length,
                itemBuilder: (context, index) {
                  final item = billingData[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAD691),
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
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAD691),
                                borderRadius:
                                BorderRadius.circular(16),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text("Billing Details",
                                            style: GoogleFonts.lato(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.bold,
                                              color: Colors.black,
                                            )),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.close,
                                              color: Colors.black),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                        Icons.confirmation_number,
                                        "Bill No",
                                        "${item['BillNoDisplay']}"),
                                    _buildDetailRow(Icons.date_range,
                                        "Bill Date",
                                        "${item['BillDate']}"),
                                    _buildDetailRow(Icons.access_time,
                                        "Bill Time",
                                        "${item['BillTime']}"),
                                    _buildDetailRow(Icons.assignment,
                                        "Job Status",
                                        "${item['JobStatus']}"),
                                    _buildDetailRow(Icons.person,
                                        "Customer",
                                        "${item['CustomerName']}"),
                                    _buildDetailRow(Icons.badge,
                                        "Employee",
                                        "${item['EmployeeName']}"),
                                    _buildDetailRow(
                                        Icons.local_shipping,
                                        "Vessel",
                                        "${item['Loadingvesselname']}"),
                                    _buildDetailRow(Icons.anchor,
                                        "Port", "${item['SPort']}"),
                                    _buildDetailRow(
                                        Icons.calendar_today,
                                        "Pickup Date",
                                        "${item['SPickupDate']}"),
                                    _buildDetailRow(
                                        Icons.flight_takeoff,
                                        "ETA",
                                        "${item['ETA']}"),
                                    _buildDetailRow(
                                        Icons.monetization_on,
                                        "Net Amount",
                                        "₹${item['NetAmt']}"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long,
                                color: Color(0xFFE67E22), size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bill No: ${item['BillNo'] ?? ''}",
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Customer: ${item['CustomerName'] ?? ''}",
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF145A32),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Amount: ₹${item['NetAmt'] ?? ''}",
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE67E22),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFFE67E22)),
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]);
        },
      );
    },
  );
}

Widget _buildDetailRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF6A994E)),
      const SizedBox(width: 8),
      Text("$label:",
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723))),
      const SizedBox(width: 8),
      Expanded(
          child: Text(value,
              style: const TextStyle(color: Color(0xFF2C3E50)))),
    ]),
  );
}