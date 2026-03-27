import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../bloc/salesorder_bloc.dart';
import '../bloc/salesorder_event.dart';
import '../bloc/salesorder_state.dart';
import '../../../../../../core/colors/colors.dart' as colors;


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
    await context
        .read<SalesOrderBloc>()
        .stream
        .firstWhere((s) => s is InvoiceLoaded || s is InvoiceError);
  }
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
      backgroundColor: const Color(0xFFF0F4FA),
      body: BlocConsumer<SalesOrderBloc, SalesOrderState>(
        buildWhen: (prev, curr) {
          if (curr is InvoiceTabSwitching) return true;
          if (prev is InvoiceTabSwitching && curr is InvoiceLoaded) return true;
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
                    onPressed: () =>
                        context.read<SalesOrderBloc>().add(RefreshSalesOrder()),
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

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _onRefresh,
                color: colors.AppColors.appBarColor,
                child: isTablet
                    ? _buildTabletLayout(
                    context, loaded, data, screenW, tabIndex)
                    : _buildMobileLayout(
                    context, loaded, data, screenW, tabIndex),
              ),
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
                      _HeroHeaderCard(state: state, data: data),
                      const SizedBox(height: 16),
                      _buildOverviewGrid(context, state, data, isTablet: true),
                      const SizedBox(height: 16),
                      _buildStatusRow(context, state, isTablet: true),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                _SOTabBar(
                    selectedIndex: tabIndex, screenW: screenW, isTablet: true),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrendHeader(state, isTablet: true),
                const SizedBox(height: 12),
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
  Widget _buildMobileLayout(BuildContext context, InvoiceLoaded state,
      Map<String, dynamic> data, double screenW, int tabIndex) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _HeroHeaderCard(state: state, data: data),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewSection(context, state, data),
                      const SizedBox(height: 14),
                      _buildStatusRow(context, state, isTablet: false),
                      const SizedBox(height: 20),
                      _buildTrendHeader(state, isTablet: false),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                        _buildMonthItem(context, state, index, isTablet: false),
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
  Widget _buildOverviewSection(BuildContext context, InvoiceLoaded state,
      Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Overview',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2340))),
            GestureDetector(
              onTap: () {},
              child: const Text('See all →',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A6FE3),
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildOverviewGrid(context, state, data, isTablet: false),
      ],
    );
  }
  Widget _buildOverviewGrid(BuildContext context, InvoiceLoaded state,
      Map<String, dynamic> data,
      {required bool isTablet}) {
    final monthly = data["MonthSales"]?.toString() ?? "0";
    final monthAmt = data["MonthAmount"]?.toString() ?? "0";
    final weekly = data["WeekSales"]?.toString() ?? "0";
    final weekAmt = data["WeekAmount"]?.toString() ?? "0";
    final yesterday = data["YesterdaySales"]?.toString() ?? "0";
    final yestAmt = data["YesterdayAmount"]?.toString() ?? "0";
    final today = data["TodaySales"]?.toString() ?? "0";
    final todayAmt = data["TodayAmount"]?.toString() ?? "0";

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                label: 'MONTHLY',
                count: monthly,
                sub: '₹$monthAmt',
                subLabel: 'Invoices',
                subColor: Colors.blue,
                subIcon: Icons.receipt,
                isTablet: isTablet,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OverviewCard(
                label: 'WEEKLY',
                count: weekly,
                sub: '₹$weekAmt',
                subLabel: 'This week',
                subColor: Colors.purple,
                subIcon: Icons.calendar_today,
                isTablet: isTablet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                label: 'YESTERDAY',
                count: yesterday,
                sub: '₹$yestAmt',
                subLabel: 'Done',
                subColor: Colors.green,
                subIcon: Icons.check_circle,
                isTablet: isTablet,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OverviewCard(
                label: 'TODAY',
                count: today,
                sub: todayAmt == '0' ? 'No entries yet' : '₹$todayAmt',
                subLabel: 'Pending',
                subColor: Colors.orange,
                subIcon: null,
                isTablet: isTablet,
                isToday: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildStatusRow(BuildContext context, InvoiceLoaded state,
      {required bool isTablet}) {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            icon: Icons.hourglass_empty,
            iconColor: Colors.orange,
            count: state.waitingBilling.length.toString(),
            label: 'WAITING BILLING',
            bgColor: const Color(0xFFFFF3E0),
            onTap: () =>
                context.read<SalesOrderBloc>().add(LoadWaitingBills(0)),
            onCountTap: () =>
                showBillingBottomSheet(context, state.waitingBilling),
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatusCard(
            icon: Icons.check_box,
            iconColor: Colors.green,
            count: (Map<String, dynamic>.from(
                state.saleDataAll.isNotEmpty
                    ? state.saleDataAll[0] as Map
                    : {}))["MonthSales"]
                ?.toString() ??
                "0",
            label: 'BILLED MONTH',
            bgColor: const Color(0xFFE8F5E9),
            onTap: null,
            onCountTap: null,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }
  Widget _buildTrendHeader(InvoiceLoaded state, {required bool isTablet}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('MONTHLY TREND',
            style: TextStyle(
                fontSize: isTablet ? 15 : 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: const Color(0xFF1A2340))),
        _RangeButtons(is6Months: state.is6Months),
      ],
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

    // find max for bar width normalisation
    final maxVal = state.monthData
        .map((e) => (e["SalesAmount"] as num).toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);
    final barFraction = maxVal == 0 ? 0.0 : (current / maxVal).clamp(0.0, 1.0);

    // dot color cycling
    const dotColors = [
      Color(0xFF4A6FE3),
      Color(0xFF7B61FF),
      Color(0xFF00C9A7),
      Color(0xFFFF6B6B),
      Color(0xFFFFB300),
      Color(0xFF26C6DA),
    ];
    final dotColor = dotColors[index % dotColors.length];

    // format amount compactly e.g. ₹5.49L
    String fmtAmount(double v) {
      if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(2)}L';
      if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
      return '₹${v.toStringAsFixed(0)}';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () =>
          context.read<SalesOrderBloc>().add(LoadEmployeeInvData(index + 3)),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 10 : 10),
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 14, vertical: isTablet ? 14 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: isTablet ? 72 : 60,
              child: Text(month,
                  style: TextStyle(
                      color: const Color(0xFF1A2340),
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 13 : 12)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: barFraction,
                  minHeight: isTablet ? 8 : 7,
                  backgroundColor: const Color(0xFFEEF2F7),
                  valueColor: AlwaysStoppedAnimation<Color>(dotColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                Text(fmtAmount(current),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 13 : 12,
                        color: const Color(0xFF1A2340))),
                const SizedBox(width: 6),
                Icon(
                    isGrowth ? Icons.arrow_upward : Icons.arrow_downward,
                    size: isTablet ? 14 : 12,
                    color: isGrowth ? Colors.green : Colors.red),
              ],
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Employee Details",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2340))),
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
              const SizedBox(height: 14),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final emp = data[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFFF7F9FC),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 6,
                              offset: Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.person,
                                size: 18, color: Color(0xFF4A6FE3)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(emp["EmployeeName"].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF1A2340))),
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
                    backgroundColor: const Color(0xFF4A6FE3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
class _HeroHeaderCard extends StatelessWidget {
  final InvoiceLoaded state;
  final Map<String, dynamic> data;

  const _HeroHeaderCard({required this.state, required this.data});

  @override
  Widget build(BuildContext context) {
    final monthAmt =
        double.tryParse(data["MonthAmount"]?.toString() ?? "0") ?? 0;
    final monthSales = data["MonthSales"]?.toString() ?? "0";
    final weekSales = data["WeekSales"]?.toString() ?? "0";
    final waiting = state.waitingBilling.length;

    String fmtLarge(double v) {
      if (v >= 100000)
        return '₹${(v / 100000).toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{2})+(?!\d))'), (m) => ',')}L';
      return '₹${v.toStringAsFixed(0)}';
    }

    // formatted as ₹5,49,839
    String fmtIndian(double v) {
      final s = v.toStringAsFixed(0);
      if (s.length <= 3) return '₹$s';
      final last3 = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      final buf = StringBuffer();
      for (int i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
        buf.write(rest[i]);
      }
      return '₹${buf.toString()},$last3';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.kHeaderGradStart,colors.kHeaderGradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${state.currentMonthName} SALES - INV',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(fmtIndian(monthAmt),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('$monthSales invoices this month',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderChip(
                        icon: Icons.receipt_long,
                        label: '$weekSales this week',
                        color: Colors.white.withOpacity(0.18)),
                    _HeaderChip(
                        icon: Icons.hourglass_empty,
                        label: '$waiting waiting',
                        color: Colors.white.withOpacity(0.18)),
                    _HeaderChip(
                        icon: Icons.check_circle_outline,
                        label: '$monthSales billed',
                        color: Colors.green.withOpacity(0.35)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _HeaderChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
class _OverviewCard extends StatelessWidget {
  final String label;
  final String count;
  final String sub;
  final String subLabel;
  final Color subColor;
  final IconData? subIcon;
  final bool isTablet;
  final bool isToday;

  const _OverviewCard({
    required this.label,
    required this.count,
    required this.sub,
    required this.subLabel,
    required this.subColor,
    required this.subIcon,
    required this.isTablet,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTablet ? 11 : 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFF8A94A6))),
          SizedBox(height: isTablet ? 10 : 8),
          Text(count,
              style: TextStyle(
                  fontSize: isTablet ? 28 : 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2340))),
          SizedBox(height: isTablet ? 6 : 5),
          Text(sub,
              style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: isToday && count == '0'
                      ? const Color(0xFF8A94A6)
                      : subColor,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(children: [
            if (subIcon != null) ...[
              Icon(subIcon, size: 12, color: subColor),
              const SizedBox(width: 4),
            ],
            Text(subLabel,
                style: TextStyle(
                    fontSize: 11,
                    color: subColor,
                    fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }
}
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String count;
  final String label;
  final Color bgColor;
  final VoidCallback? onTap;
  final VoidCallback? onCountTap;
  final bool isTablet;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.bgColor,
    required this.onTap,
    required this.onCountTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),

            // --- THE FIX IS HERE ---
            // Wrapped the Column in an Expanded widget so it shrinks to fit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Keeps the column from expanding vertically
                children: [
                  GestureDetector(
                    onTap: onCountTap,
                    child: Text(
                      count,
                      maxLines: 1, // Restrict to one line
                      overflow: TextOverflow.ellipsis, // Add '...' if it overflows
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A2340),
                      ),
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1, // Restrict to one line
                    overflow: TextOverflow.ellipsis, // Add '...' if it overflows
                    style: TextStyle(
                      fontSize: isTablet ? 10 : 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: const Color(0xFF8A94A6),
                    ),
                  ),
                ],
              ),
            ),
            // -----------------------

          ],
        ),
      ),
    );
  }
}
class _RangeButtons extends StatelessWidget {
  final bool is6Months;
  const _RangeButtons({required this.is6Months});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _RangeBtn(
            text: "6 Months",
            selected: is6Months,
            onTap: () =>
                context.read<SalesOrderBloc>().add(LoadMonthRange(6))),
        _RangeBtn(
            text: "1 Year",
            selected: !is6Months,
            onTap: () =>
                context.read<SalesOrderBloc>().add(LoadMonthRange(12))),
      ]),
    );
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.kHeaderGradStart : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF8A94A6),
                fontWeight: FontWeight.w700,
                fontSize: 12)),
      ),
    );
  }
}
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
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 0 : 16, vertical: 8),
        child: SizedBox(
          height: isTablet ? 60 : 70,
          child: Card(
            elevation: 6,
            color: colors.AppColors.appBarColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 12)),
            child: SalomonBottomBar(
              duration: const Duration(milliseconds: 300),
              currentIndex: selectedIndex,
              onTap: (index) {
                // ── Guard: ignore tap on already-selected tab ──
                if (index == selectedIndex) return;
                context
                    .read<SalesOrderBloc>()
                    .add(LoadInvoiceByType(index + 1));
              },
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.receipt,
                      color: colors.AppColors.whitecolor),
                  title: Text("All",
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: colors.AppColors.whitecolor,
                              fontSize: isTablet
                                  ? 14
                                  : (screenW <= 370
                                  ? objfun.FontCardText + 2
                                  : objfun.FontLow)))),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.receipt_long,
                      color: colors.AppColors.whitecolor),
                  title: Text("With",
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: colors.AppColors.whitecolor,
                              fontSize: isTablet
                                  ? 14
                                  : (screenW <= 370
                                  ? objfun.FontCardText + 2
                                  : objfun.FontLow)))),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.receipt_long_outlined,
                      color: colors.AppColors.whitecolor),
                  title: Text("Without",
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: colors.AppColors.whitecolor,
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
      ),
    );
  }
}
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
                                borderRadius: BorderRadius.circular(16)),
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
                                color: colors.kOrange, size: 28),
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
                                        color: colors.kOrange)),
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
                                size: 16, color: colors.kOrange),
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