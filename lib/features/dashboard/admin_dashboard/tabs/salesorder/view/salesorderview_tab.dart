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
import '../../../../../../core/colors/colors.dart';

const _kShadow = Color(0x0D000000);
const _kNavy   = Color(0xFF1A2E5A);
const _kBlue   = Color(0xFF5B9BD5);
const _kOrange = Color(0xFFE67E22);

class SalesOrderTab extends StatefulWidget {
  const SalesOrderTab({super.key});

  @override
  State<SalesOrderTab> createState() => _SalesOrderTabState();
}

class _SalesOrderTabState extends State<SalesOrderTab> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesOrderBloc>().add(LoadInvoiceByType(0));
    });
  }

  Future<void> _onRefresh() async {
    context.read<SalesOrderBloc>().add(RefreshSalesOrder());
    await context.read<SalesOrderBloc>().stream
        .firstWhere((s) => s is InvoiceLoaded || s is InvoiceError);
  }

  // ─────────────────────────────────────────────
  // Tab switching-ல் use பண்ண helper
  // InvoiceTabSwitching state-லயும் InvoiceLoaded return பண்றது
  // ─────────────────────────────────────────────
  InvoiceLoaded? _resolveLoaded(SalesOrderState state) {
    if (state is InvoiceLoaded) return state;
    if (state is InvoiceTabSwitching) return state.previous;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: BlocConsumer<SalesOrderBloc, SalesOrderState>(
        // Equatable handle பண்றதால் same props → no rebuild
        // InvoiceTabSwitching → rebuild (overlay காட்டணும்)
        buildWhen: (prev, curr) {
          // Tab switching state always rebuild (overlay update)
          if (curr is InvoiceTabSwitching) return true;
          // InvoiceTabSwitching → InvoiceLoaded transition
          if (prev is InvoiceTabSwitching && curr is InvoiceLoaded) return true;
          // Normal states — Equatable props handle பண்ணும்
          return prev != curr;
        },
        listenWhen: (prev, curr) {
          if (curr is InvoiceLoaded) {
            return curr.showWaitingSheet || curr.employeeData != null;
          }
          return false;
        },
        listener: (context, state) {
          if (state is InvoiceLoaded && state.showWaitingSheet) {
            showBillingBottomSheet(context, state.waitingBilling);
          }
          if (state is InvoiceLoaded && state.employeeData != null) {
            _showDialogEmpDetails(state.employeeData!);
          }
        },
        builder: (context, state) {
          // Full screen loading — only first time
          if (state is InvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InvoiceError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SalesOrderBloc>()
                        .add(RefreshSalesOrder()),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final loaded = _resolveLoaded(state);
          if (loaded == null) return const SizedBox();

          final isTabSwitching = state is InvoiceTabSwitching;
          final tabIndex = isTabSwitching
              ? (state as InvoiceTabSwitching).targetTabIndex
              : loaded.selectedTabIndex;

          final data = loaded.saleDataAll.isNotEmpty
              ? Map<String, dynamic>.from(loaded.saleDataAll[0] as Map)
              : <String, dynamic>{};

          // Tab switching-ல் existing UI + top loading bar
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.appBarColor,
                child: isTablet
                    ? _buildTabletLayout(
                    context, loaded, data, screenW, tabIndex)
                    : _buildMobileLayout(
                    context, loaded, data, screenW, tabIndex),
              ),
              // Tab switch-ல் top-ல் thin loading indicator
              if (isTabSwitching)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 3),
                ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // TABLET LAYOUT
  // ═══════════════════════════════════════════════════════
  Widget _buildTabletLayout(BuildContext context, InvoiceLoaded state,
      Map<String, dynamic> data, double screenW, int tabIndex) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(children: [
                      RepaintBoundary(
                          child: _SOChart(data: data, height: 260)),
                      const SizedBox(height: 16),
                      _RangeButtons(is6Months: state.is6Months),
                      const SizedBox(height: 16),
                      _buildHeaderCard(state, fontSize: 20),
                      const SizedBox(height: 16),
                      _buildStatCards(data, isTablet: true),
                      const SizedBox(height: 16),
                      _buildWaitingRow(context, state, isTablet: true),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                _SOTabBar(
                    selectedIndex: tabIndex,
                    screenW: screenW,
                    isTablet: true),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12, left: 4),
                  child: Text('Monthly Breakdown',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _kNavy)),
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

  // ═══════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ═══════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context, InvoiceLoaded state,
      Map<String, dynamic> data, double screenW, int tabIndex) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    RepaintBoundary(
                        child: _SOChart(data: data, height: 200)),
                    const SizedBox(height: 16),
                    _RangeButtons(is6Months: state.is6Months),
                    const SizedBox(height: 20),
                    _buildHeaderCard(state, fontSize: 18),
                    const SizedBox(height: 20),
                    _buildStatCards(data, isTablet: false),
                    const SizedBox(height: 16),
                    _buildWaitingRow(context, state, isTablet: false),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text('Monthly Breakdown',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _kNavy)),
                    ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMonthItem(
                        context, state, index,
                        isTablet: false),
                    childCount: state.monthList.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        _SOTabBar(
            selectedIndex: tabIndex, screenW: screenW, isTablet: false),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════

  Widget _buildHeaderCard(InvoiceLoaded state,
      {required double fontSize}) {
    return Container(
      width: double.infinity,
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
            fontSize: fontSize),
      ),
    );
  }

  Widget _buildStatCards(Map<String, dynamic> data,
      {required bool isTablet}) {
    return Row(
      children: [
        _SmallStatCard(
            title: "Today",
            count: data["TodaySales"]?.toString() ?? "0",
            amount: data["TodayAmount"]?.toString() ?? "0",
            positive: true,
            isTablet: isTablet),
        _SmallStatCard(
            title: "Yesterday",
            count: data["YesterdaySales"]?.toString() ?? "0",
            amount: data["YesterdayAmount"]?.toString() ?? "0",
            positive: false,
            isTablet: isTablet),
        _SmallStatCard(
            title: "Weekly",
            count: data["WeekSales"]?.toString() ?? "0",
            amount: data["WeekAmount"]?.toString() ?? "0",
            positive: true,
            isTablet: isTablet),
        _SmallStatCard(
            title: "Monthly",
            count: data["MonthSales"]?.toString() ?? "0",
            amount: data["MonthAmount"]?.toString() ?? "0",
            positive: true,
            isTablet: isTablet),
      ],
    );
  }

  Widget _buildWaitingRow(BuildContext context, InvoiceLoaded state,
      {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 16 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: _kShadow, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Row(children: [
        InkWell(
          onTap: () =>
              context.read<SalesOrderBloc>().add(LoadWaitingBills(0)),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text("Waiting for Billing ",
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: _kNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 14 : 12,
                        letterSpacing: 0.3))),
          ),
        ),
        InkWell(
          onTap: () =>
              showBillingBottomSheet(context, state.waitingBilling),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 5, left: 5, right: 5, bottom: 15),
            child: Text("${state.waitingBilling.length}",
                style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: _kNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 14 : 12,
                        letterSpacing: 0.3))),
          ),
        ),
      ]),
    );
  }

  Widget _buildMonthList(BuildContext context, InvoiceLoaded state,
      {required bool isTablet}) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: state.monthList.length,
      itemBuilder: (context, index) =>
          _buildMonthItem(context, state, index, isTablet: isTablet),
    );
  }

  Widget _buildMonthItem(
      BuildContext context, InvoiceLoaded state, int index,
      {required bool isTablet}) {
    final month = state.monthList[index];
    final current =
    (state.monthData[index]["SalesAmount"] as num).toDouble();
    final prev = index == 0
        ? current
        : (state.monthData[index - 1]["SalesAmount"] as num).toDouble();
    final diff = prev == 0 ? 0.0 : ((current - prev) / prev) * 100;
    final isGrowth = diff >= 0;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context
          .read<SalesOrderBloc>()
          .add(LoadEmployeeInvData(index + 3)),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 10 : 12),
        padding: EdgeInsets.all(isTablet ? 18 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: _kShadow, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(month,
                style: TextStyle(
                    color: _kNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 15 : 13)),
            Text(current.toStringAsFixed(0),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 15 : 13)),
            Row(children: [
              Icon(
                  isGrowth ? Icons.arrow_upward : Icons.arrow_downward,
                  size: isTablet ? 18 : 16,
                  color: isGrowth ? Colors.green : Colors.red),
              const SizedBox(width: 4),
              Text("${diff.abs().toStringAsFixed(1)}%",
                  style: TextStyle(
                      color: isGrowth ? Colors.green : Colors.red,
                      fontSize: isTablet ? 14 : 12)),
            ]),
          ],
        ),
      ),
    );
  }

  void _showDialogEmpDetails(List<dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white),
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
                          color: _kNavy)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.red,
                      child:
                      Icon(Icons.close, size: 16, color: Colors.white),
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
                        boxShadow: const [
                          BoxShadow(
                              color: _kShadow,
                              blurRadius: 6,
                              offset: Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.person,
                                size: 18, color: _kBlue),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(emp["EmployeeName"].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: _kNavy)),
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
                    backgroundColor: _kBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _RangeButtons
// ═══════════════════════════════════════════════════════════
class _RangeButtons extends StatelessWidget {
  final bool is6Months;
  const _RangeButtons({required this.is6Months});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _RangeBtn(
          text: "6 Months",
          selected: is6Months,
          onTap: () =>
              context.read<SalesOrderBloc>().add(LoadMonthRange(6))),
      const SizedBox(width: 10),
      _RangeBtn(
          text: "1 Year",
          selected: !is6Months,
          onTap: () =>
              context.read<SalesOrderBloc>().add(LoadMonthRange(12))),
    ]);
  }
}

class _RangeBtn extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _RangeBtn(
      {required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.appBarColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.appBarColor),
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _SmallStatCard
// ═══════════════════════════════════════════════════════════
class _SmallStatCard extends StatelessWidget {
  final String title;
  final String count;
  final String amount;
  final bool positive;
  final bool isTablet;

  const _SmallStatCard({
    required this.title,
    required this.count,
    required this.amount,
    required this.positive,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 5 : 4),
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: const [BoxShadow(color: _kShadow, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: isTablet ? 13 : 12, color: _kNavy)),
            SizedBox(height: isTablet ? 8 : 6),
            Text(count,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 14)),
            SizedBox(height: isTablet ? 5 : 4),
            Text(amount,
                style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: positive ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _SOTabBar — selectedIndex பாரமா receive பண்றோம்
// ═══════════════════════════════════════════════════════════
class _SOTabBar extends StatelessWidget {
  final int selectedIndex;
  final double screenW;
  final bool isTablet;

  const _SOTabBar({
    required this.selectedIndex,
    required this.screenW,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 0 : 16, vertical: 8),
      child: SizedBox(
        height: isTablet ? 60 : 70,
        child: Card(
          elevation: 6,
          color: colour.AppColors.appBarColor,
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(isTablet ? 20 : 12)),
          child: SalomonBottomBar(
            duration: const Duration(milliseconds: 300),
            currentIndex: selectedIndex,
            onTap: (index) => context
                .read<SalesOrderBloc>()
                .add(LoadInvoiceByType(index + 1)),
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.receipt,
                    color: colour.AppColors.whitecolor),
                title: Text("All",
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: colour.AppColors.whitecolor,
                            fontSize: isTablet
                                ? 14
                                : (screenW <= 370
                                ? objfun.FontCardText + 2
                                : objfun.FontLow)))),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.receipt_long,
                    color: colour.AppColors.whitecolor),
                title: Text("With",
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: colour.AppColors.whitecolor,
                            fontSize: isTablet
                                ? 14
                                : (screenW <= 370
                                ? objfun.FontCardText + 2
                                : objfun.FontLow)))),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.receipt_long_outlined,
                    color: colour.AppColors.whitecolor),
                title: Text("Without",
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: colour.AppColors.whitecolor,
                            fontSize: isTablet
                                ? 14
                                : (screenW <= 370
                                ? objfun.FontCardText + 2
                                : objfun.FontLow)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _SOChart
// ═══════════════════════════════════════════════════════════
class _SOChart extends StatelessWidget {
  final Map<String, dynamic> data;
  final double height;
  const _SOChart({required this.data, required this.height});

  @override
  Widget build(BuildContext context) {
    final today =
        double.tryParse(data["TodayAmount"]?.toString() ?? "0") ?? 0;
    final yesterday =
        double.tryParse(data["YesterdayAmount"]?.toString() ?? "0") ?? 0;

    return SizedBox(
      height: height,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.appBarColor, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: AppColors.appBarColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4)),
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
                      color: _kNavy)),
              const Spacer(),
              Container(
                  width: 12, height: 3, color: AppColors.appBarColor),
              const SizedBox(width: 4),
              const Text("Today",
                  style: TextStyle(fontSize: 11, color: _kNavy)),
              const SizedBox(width: 12),
              Container(width: 12, height: 3, color: Colors.orange),
              const SizedBox(width: 4),
              const Text("Yesterday",
                  style: TextStyle(fontSize: 11, color: _kNavy)),
            ]),
            const SizedBox(height: 10),
            Expanded(
              child: LineChart(LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                      color: Color(0x26808080), strokeWidth: 1),
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
                        final i = value.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(labels[i],
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
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
                    getTooltipItems: (spots) => spots.map((spot) {
                      final label =
                      spot.barIndex == 0 ? "Today" : "Yesterday";
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
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  _bar(today, AppColors.appBarColor),
                  _bar(yesterday, Colors.orange),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _bar(double value, Color color) {
    return LineChartBarData(
      spots: [FlSpot(0, 0), FlSpot(1, value * 0.6), FlSpot(2, value)],
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
            radius: 5,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: color),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// showBillingBottomSheet
// ═══════════════════════════════════════════════════════════
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
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
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
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFAD691),
                                borderRadius:
                                BorderRadius.circular(16)),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Billing Details",
                                          style: GoogleFonts.lato(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.black),
                                          onPressed: () =>
                                              Navigator.pop(context)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(
                                      Icons.confirmation_number,
                                      "Bill No",
                                      "${item['BillNoDisplay']}"),
                                  _buildDetailRow(Icons.date_range,
                                      "Bill Date", "${item['BillDate']}"),
                                  _buildDetailRow(Icons.access_time,
                                      "Bill Time", "${item['BillTime']}"),
                                  _buildDetailRow(Icons.assignment,
                                      "Job Status",
                                      "${item['JobStatus']}"),
                                  _buildDetailRow(Icons.person,
                                      "Customer",
                                      "${item['CustomerName']}"),
                                  _buildDetailRow(Icons.badge,
                                      "Employee",
                                      "${item['EmployeeName']}"),
                                  _buildDetailRow(Icons.local_shipping,
                                      "Vessel",
                                      "${item['Loadingvesselname']}"),
                                  _buildDetailRow(Icons.anchor, "Port",
                                      "${item['SPort']}"),
                                  _buildDetailRow(Icons.calendar_today,
                                      "Pickup Date",
                                      "${item['SPickupDate']}"),
                                  _buildDetailRow(Icons.flight_takeoff,
                                      "ETA", "${item['ETA']}"),
                                  _buildDetailRow(Icons.monetization_on,
                                      "Net Amount",
                                      "₹${item['NetAmt']}"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.receipt_long,
                                color: _kOrange, size: 28),
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
                                        color: const Color(0xFF2C3E50))),
                                const SizedBox(height: 4),
                                Text(
                                    "Customer: ${item['CustomerName'] ?? ''}",
                                    style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF145A32))),
                                const SizedBox(height: 2),
                                Text(
                                    "Amount: ₹${item['NetAmt'] ?? ''}",
                                    style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _kOrange)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius:
                                BorderRadius.circular(8)),
                            child: const Icon(Icons.arrow_forward_ios,
                                size: 16, color: _kOrange),
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
              fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
      const SizedBox(width: 8),
      Expanded(
          child: Text(value,
              style: const TextStyle(color: Color(0xFF2C3E50)))),
    ]),
  );
}