import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/palette.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/invoice_bloc.dart';
import '../bloc/invoice_event.dart';
import '../bloc/invoice_state.dart';
import '../../../../../../core/colors/colors.dart' as colors;


class InvoiceTab extends StatefulWidget {
  const InvoiceTab({super.key});

  @override
  State<InvoiceTab> createState() => _InvoiceTabState();
}

class _InvoiceTabState extends State<InvoiceTab> {

  @override
  void initState() {
    super.initState();

      context.read<InvoiceBloc>().add(LoadInvoiceByType(0));

  }

  Future<void> _onRefresh() async {
    context.read<InvoiceBloc>().add(RefreshInvoice());
    await context.read<InvoiceBloc>().stream
        .firstWhere((s) => s is InvoiceLoaded || s is InvoiceError);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW >= 600;

    return Scaffold(
      backgroundColor: AppTokens.invoicePageBg,
      body: BlocConsumer<InvoiceBloc, InvoiceState>(
        buildWhen: (prev, curr) {
          if (prev is! InvoiceLoaded) return true;
          if (curr is! InvoiceLoaded) return true;
          return prev.is6Months != curr.is6Months ||
              prev.currentMonthName != curr.currentMonthName ||
              prev.monthList.length != curr.monthList.length ||
              prev.saleDataAll.length != curr.saleDataAll.length ||
              prev.monthData.length != curr.monthData.length;
        },
        listenWhen: (prev, curr) {
          if (prev is InvoiceLoaded && curr is InvoiceLoaded) {
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
                        context.read<InvoiceBloc>().add(RefreshInvoice()),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }
          if (state is! InvoiceLoaded) return const SizedBox();

          final data = state.saleDataAll.isNotEmpty
              ? Map<String, dynamic>.from(state.saleDataAll[0] as Map)
              : <String, dynamic>{};

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: colors.kHeaderGradStart,
            child: isTablet
                ? _buildTabletLayout(context, state, data)
                : _buildMobileLayout(context, state, data),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // TABLET LAYOUT
  // ═══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context, InvoiceLoaded state, Map<String, dynamic> data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _HeroHeader(state: state, data: data),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(children: [
                    _OverviewSection(state: state, data: data, isTablet: true),
                    const SizedBox(height: 20),
                    _MonthlyTrendSection(state: state, isTablet: true,
                      onMonthTap: (i) => context.read<InvoiceBloc>().add(LoadEmployeeInvData(i + 3)),
                    ),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: _TodayYesterdayChartCard(data: data),
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
  Widget _buildMobileLayout(
      BuildContext context, InvoiceLoaded state, Map<String, dynamic> data) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [

        SliverToBoxAdapter(child: _HeroHeader(state: state, data: data)),


        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _OverviewSection(state: state, data: data, isTablet: false,
                onWaitingTap: () {
                  if (state.waitingBilling.isEmpty) {

                    context.read<InvoiceBloc>().add(LoadWaitingBills(0));
                  } else {

                    showBillingBottomSheet(context, state.waitingBilling);
                  }
                },
                onWaitingCountTap: () => showBillingBottomSheet(context, state.waitingBilling),
              ),
              const SizedBox(height: 24),
              _MonthlyTrendHeader(is6Months: state.is6Months),
              const SizedBox(height: 12),
            ]),
          ),
        ),

        // ── Monthly list items ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _MonthBarItem(
                month: state.monthList[index],
                current: (state.monthData[index]["SalesAmount"] as num).toDouble(),
                prev: index == 0
                    ? (state.monthData[0]["SalesAmount"] as num).toDouble()
                    : (state.monthData[index - 1]["SalesAmount"] as num).toDouble(),
                count: state.monthData[index]["SalesCount"]?.toString() ?? "0",
                amount: state.monthData[index]["SalesAmount"]?.toString() ?? "0",
                maxAmount: state.monthData
                    .map((e) => (e["SalesAmount"] as num).toDouble())
                    .reduce((a, b) => a > b ? a : b),
                isTablet: false,
                onTap: () => context.read<InvoiceBloc>().add(LoadEmployeeInvData(index + 3)),
              ),
              childCount: state.monthList.length,
            ),
          ),
        ),
      ],
    );
  }

  void _showDialogEmpDetails(List<dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
                          fontSize: 18, fontWeight: FontWeight.bold, color: AppTokens.textNavy,
                        )),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
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
                            BoxShadow(color: Palette.grey200, blurRadius: 6, offset: Offset(0, 3))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.person, size: 18, color: AppTokens.transBlueLight),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(emp["EmployeeName"].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14, color: AppTokens.textNavy)),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Text("RM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  const SizedBox(width: 4),
                                  Text(emp["Amount"].toString(),
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                                ]),
                                Row(children: [
                                  const Icon(Icons.shopping_cart, size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(emp["SalesCount"].toString(),
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.orange)),
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
                      backgroundColor: AppTokens.invoiceHeaderStart,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Dashboard",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HERO HEADER  (gradient card — top section in screenshot)
// ═══════════════════════════════════════════════════════════
class _HeroHeader extends StatelessWidget {
  final InvoiceLoaded state;
  final Map<String, dynamic> data;
  const _HeroHeader({required this.state, required this.data});

  @override
  Widget build(BuildContext context) {
    final totalAmount = data["MonthAmount"]?.toString() ?? "0";
    final totalCount  = data["MonthSales"]?.toString()  ?? "0";
    final weekCount   = data["WeekSales"]?.toString()   ?? "0";
    final waitingCount = state.waitingBilling.length;
    final billedCount  = data["MonthSales"]?.toString() ?? "0"; // adjust key if needed

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTokens.invoiceHeaderStart, AppTokens.invoiceHeaderEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${state.currentMonthName.toUpperCase()} SALES · INV",
            style: GoogleFonts.lato(
              color: Colors.white.withOpacity(0.80),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${_fmt(totalAmount)}",
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "$totalCount invoices this month",
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.75), fontSize: 13),
          ),
          const SizedBox(height: 16),
          // ── pill row ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(icon: Icons.calendar_view_week, label: "$weekCount this week", iconColor: Colors.white),
              _Pill(icon: Icons.hourglass_empty, label: "$waitingCount waiting", iconColor: Colors.white),
              _Pill(icon: Icons.check_circle_outline, label: "$billedCount billed", iconColor: colors.kGreen, checkMark: true),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(String raw) {
    final n = double.tryParse(raw) ?? 0;
    // e.g. 549839 → 5,49,839
    final s = n.toStringAsFixed(0);
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest  = s.substring(0, s.length - 3);
    final buf   = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i != 0 && (rest.length - i) % 2 == 0) buf.write(',');
      buf.write(rest[i]);
    }
    return "${buf.toString()},$last3";
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool checkMark;

  const _Pill({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.checkMark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.kPillBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// OVERVIEW SECTION  (2×2 grid + waiting + billed row)
// ═══════════════════════════════════════════════════════════
class _OverviewSection extends StatelessWidget {
  final InvoiceLoaded state;
  final Map<String, dynamic> data;
  final bool isTablet;
  final VoidCallback? onWaitingTap;
  final VoidCallback? onWaitingCountTap;

  const _OverviewSection({
    required this.state,
    required this.data,
    required this.isTablet,
    this.onWaitingTap,
    this.onWaitingCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Overview",
                style: GoogleFonts.lato(
                    fontSize: 16, fontWeight: FontWeight.w800, color: AppTokens.textNavy)),
            TextButton(
              onPressed: () {},
              child: Text("See all →",
                  style: GoogleFonts.lato(
                      fontSize: 13, color: AppTokens.planCobalt, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── 2-column grid ──
        Row(children: [
          Expanded(child: _OverviewCard(
            label: "MONTHLY",
            count: data["MonthSales"]?.toString() ?? "0",
            amount: "${data["MonthAmount"] ?? "0"}",
            badgeLabel: "Invoices",
            badgeColor: colors.kOrange,
            badgeIcon: Icons.circle,
          )),
          const SizedBox(width: 12),
          Expanded(child: _OverviewCard(
            label: "WEEKLY",
            count: data["WeekSales"]?.toString() ?? "0",
            amount: "${data["WeekAmount"] ?? "0"}",
            badgeLabel: "This week",
            badgeColor: AppTokens.planCobalt,
            badgeIcon: Icons.calendar_today,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _OverviewCard(
            label: "YESTERDAY",
            count: data["YesterdaySales"]?.toString() ?? "0",
            amount: "${data["YesterdayAmount"] ?? "0"}",
            badgeLabel: "Done",
            badgeColor: AppTokens.statusSuccess,
            badgeIcon: Icons.check,
          )),
          const SizedBox(width: 12),
          Expanded(child: _OverviewCard(
            label: "TODAY",
            count: data["TodaySales"]?.toString() ?? "0",
            amount: data["TodaySales"] == "0" || data["TodaySales"] == null
                ? "No entries yet"
                : "${data["TodayAmount"] ?? "0"}",
            badgeLabel: "Pending",
            badgeColor: Colors.grey,
            badgeIcon: Icons.remove,
            isToday: true,
          )),
        ]),
        const SizedBox(height: 12),

        // ── Waiting + Billed row ──
        Row(children: [
          Expanded(child: _StatusCard(
            icon: Icons.timer_outlined,
            iconColor: Colors.amber.shade700,
            bgColor: Colors.amber.shade50,
            count: state.waitingBilling.length.toString(),
            label: "WAITING BILLING",
            onTap: onWaitingTap,
          )),
          const SizedBox(width: 12),
          Expanded(child: _StatusCard(
            icon: Icons.check_circle,
            iconColor: AppTokens.statusSuccess,
            bgColor: const Color(0xFFEAF7EF),
            count: data["MonthSales"]?.toString() ?? "0",
            label: "BILLED MONTH",
            onTap: onWaitingCountTap,
          )),
        ]),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String count;
  final String amount;
  final String badgeLabel;
  final Color badgeColor;
  final IconData badgeIcon;
  final bool isToday;

  const _OverviewCard({
    required this.label,
    required this.count,
    required this.amount,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeIcon,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.kCardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Palette.grey200, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text(count,
              style: GoogleFonts.lato(
                  fontSize: 28, fontWeight: FontWeight.w900, color: AppTokens.textNavy)),
          const SizedBox(height: 4),
          Text(amount,
              style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isToday ? Colors.grey : AppTokens.textNavy)),
          const SizedBox(height: 10),
          Row(children: [
            Icon(badgeIcon, size: 12, color: badgeColor),
            const SizedBox(width: 4),
            Text(badgeLabel,
                style: GoogleFonts.lato(
                    fontSize: 11, color: badgeColor, fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String count;
  final String label;
  final VoidCallback? onTap;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.count,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.kCardBg, // Assuming 'colors' is your theme instance
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Palette.grey200, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),

          // --- FIX APPLIED HERE ---
          // Wrapped the Column in an Expanded widget
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Good practice inside Rows
              children: [
                Text(
                  count,
                  overflow: TextOverflow.ellipsis, // Added overflow handling
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTokens.textNavy,
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis, // Added overflow handling
                  style: GoogleFonts.lato(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          // ------------------------

        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MONTHLY TREND HEADER  (title + 6M/1Y toggle)
// ═══════════════════════════════════════════════════════════
class _MonthlyTrendHeader extends StatelessWidget {
  final bool is6Months;
  const _MonthlyTrendHeader({required this.is6Months});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("MONTHLY TREND",
            style: GoogleFonts.lato(
                fontSize: 13, fontWeight: FontWeight.w800,
                color: AppTokens.textNavy, letterSpacing: 0.6)),
        Row(children: [
          _ToggleBtn(
            text: "6 Months",
            selected: is6Months,
            onTap: () => context.read<InvoiceBloc>().add(LoadMonthRange(6)),
          ),
          const SizedBox(width: 6),
          _ToggleBtn(
            text: "1 Year",
            selected: !is6Months,
            onTap: () => context.read<InvoiceBloc>().add(LoadMonthRange(12)),
          ),
        ]),
      ],
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleBtn({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTokens.invoiceHeaderStart : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(
            color: selected ? Colors.white : AppTokens.textNavy,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MONTHLY TREND SECTION  (for tablet)
// ═══════════════════════════════════════════════════════════
class _MonthlyTrendSection extends StatelessWidget {
  final InvoiceLoaded state;
  final bool isTablet;
  final void Function(int) onMonthTap;

  const _MonthlyTrendSection({
    required this.state,
    required this.isTablet,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxAmount = state.monthData.isEmpty
        ? 1.0
        : state.monthData
        .map((e) => (e["SalesAmount"] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        _MonthlyTrendHeader(is6Months: state.is6Months),
        const SizedBox(height: 12),
        ...List.generate(state.monthList.length, (i) {
          final current = (state.monthData[i]["SalesAmount"] as num).toDouble();
          final prev = i == 0
              ? current
              : (state.monthData[i - 1]["SalesAmount"] as num).toDouble();
          return _MonthBarItem(
            month: state.monthList[i],
            current: current,
            prev: prev,
            count: state.monthData[i]["SalesCount"]?.toString() ?? "0",
            amount: state.monthData[i]["SalesAmount"]?.toString() ?? "0",
            maxAmount: maxAmount,
            isTablet: isTablet,
            onTap: () => onMonthTap(i),
          );
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MONTH BAR ITEM  (screenshot style: dot · name · bar · count · amount)
// ═══════════════════════════════════════════════════════════
class _MonthBarItem extends StatelessWidget {
  final String month;
  final double current;
  final double prev;
  final String count;
  final String amount;
  final double maxAmount;
  final bool isTablet;
  final VoidCallback onTap;

  const _MonthBarItem({
    required this.month,
    required this.current,
    required this.prev,
    required this.count,
    required this.amount,
    required this.maxAmount,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxAmount > 0 ? (current / maxAmount).clamp(0.0, 1.0) : 0.0;
    final diff = prev == 0 ? 0.0 : ((current - prev) / prev) * 100;
    final isGrowth = diff >= 0;
    final amountLabel = _shortAmount(current);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 10 : 10),
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 18 : 12, vertical: isTablet ? 14 : 12),
        decoration: BoxDecoration(
          color: colors.kCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Palette.grey200, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            // colored dot
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: isGrowth ? AppTokens.statusSuccess : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),

            // month name
            SizedBox(
              width: isTablet ? 80 : 72,
              child: Text(month,
                  style: GoogleFonts.lato(
                      fontSize: isTablet ? 13 : 12,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.textNavy)),
            ),

            // horizontal bar
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: isTablet ? 10 : 8,
                  backgroundColor: const Color(0xFFE8ECF5),
                  valueColor: const AlwaysStoppedAnimation<Color>(colors.kBarBlue),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // count
            SizedBox(
              width: isTablet ? 40 : 34,
              child: Text(count,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.lato(
                      fontSize: isTablet ? 13 : 12,
                      fontWeight: FontWeight.w800,
                      color: AppTokens.textNavy)),
            ),

            const SizedBox(width: 10),

            // amount label (e.g. ₹35.49L)
            SizedBox(
              width: isTablet ? 56 : 50,
              child: Text(amountLabel,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.lato(
                      fontSize: isTablet ? 12 : 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
            ),
          ],
        ),
      ),
    );
  }

  String _shortAmount(double val) {
    if (val >= 10000000) return "₹${(val / 10000000).toStringAsFixed(2)}Cr";
    if (val >= 100000)   return "₹${(val / 100000).toStringAsFixed(2)}L";
    if (val >= 1000)     return "₹${(val / 1000).toStringAsFixed(1)}K";
    return "₹${val.toStringAsFixed(0)}";
  }
}

// ═══════════════════════════════════════════════════════════
// TODAY vs YESTERDAY CHART CARD  (tablet right panel)
// ═══════════════════════════════════════════════════════════
class _TodayYesterdayChartCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TodayYesterdayChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final today     = double.tryParse(data["TodayAmount"]?.toString()     ?? "0") ?? 0;
    final yesterday = double.tryParse(data["YesterdayAmount"]?.toString() ?? "0") ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.invoiceCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Palette.grey200, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today vs Yesterday",
              style: GoogleFonts.lato(
                  fontSize: 13, fontWeight: FontWeight.w800, color: AppTokens.textNavy)),
          const SizedBox(height: 4),
          Row(children: [
            _LegendDot(color: AppTokens.invoiceHeaderStart, label: "Today"),
            const SizedBox(width: 12),
            _LegendDot(color: Colors.orange, label: "Yesterday"),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(_buildChart(today, yesterday)),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChart(double today, double yesterday) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0x20808080), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              const labels = ['Start', 'Mid', 'End'];
              final i = v.toInt();
              if (i < 0 || i >= labels.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labels[i], style: const TextStyle(fontSize: 10, color: Colors.grey)),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.white,
          tooltipRoundedRadius: 8,
          tooltipBorder: const BorderSide(color: AppTokens.invoiceHeaderStart, width: 1),
          getTooltipItems: (spots) => spots.map((spot) {
            final label = spot.barIndex == 0 ? "Today" : "Yesterday";
            return LineTooltipItem(
              "$label\n₹${spot.y.toStringAsFixed(0)}",
              TextStyle(
                color: spot.barIndex == 0 ? AppTokens.invoiceHeaderStart : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        _bar(today, AppTokens.invoiceHeaderStart),
        _bar(yesterday, Colors.orange),
      ],
    );
  }

  LineChartBarData _bar(double value, Color color) {
    return LineChartBarData(
      spots: [FlSpot(0, 0), FlSpot(1, value * 0.6), FlSpot(2, value)],
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) =>
            FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: color),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.18), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 3, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════
// showBillingBottomSheet  (unchanged functionality)
// ═══════════════════════════════════════════════════════════
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
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Waiting for Billing Details",
                      style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color:  Colors.white,
                                  borderRadius: BorderRadius.circular(16)),
                              child: SingleChildScrollView(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Billing Details",
                                          style: GoogleFonts.lato(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      IconButton(
                                          icon: const Icon(Icons.close, color: Colors.black),
                                          onPressed: () => Navigator.pop(context)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(Icons.confirmation_number, "Bill No",   "${item['BillNoDisplay']}"),
                                  _buildDetailRow(Icons.date_range,          "Bill Date", "${item['BillDate']}"),
                                  _buildDetailRow(Icons.access_time,         "Bill Time", "${item['BillTime']}"),
                                  _buildDetailRow(Icons.assignment,          "Job Status","${item['JobStatus']}"),
                                  _buildDetailRow(Icons.person,              "Customer",  "${item['CustomerName']}"),
                                  _buildDetailRow(Icons.badge,               "Employee",  "${item['EmployeeName']}"),
                                  _buildDetailRow(Icons.local_shipping,      "Vessel",    "${item['Loadingvesselname']}"),
                                  _buildDetailRow(Icons.anchor,              "Port",      "${item['SPort']}"),
                                  _buildDetailRow(Icons.calendar_today,      "Pickup Date","${item['SPickupDate']}"),
                                  _buildDetailRow(Icons.flight_takeoff,      "ETA",       "${item['ETA']}"),
                                  _buildDetailRow(Icons.monetization_on,     "Net Amount","₹${item['NetAmt']}"),
                                ]),
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
                                shape: BoxShape.circle),
                            child: const Icon(Icons.receipt_long, color: AppTokens.invoiceHeaderStart, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(

                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("Bill No: ${item['BillNo'] ?? ''}",
                                  style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTokens.invoiceHeaderStart)),
                              const SizedBox(height: 4),
                              Text("Customer: ${item['CustomerName'] ?? ''}",
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF145A32))),
                              const SizedBox(height: 2),
                              Text("Amount: ₹${item['NetAmt'] ?? ''}",
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: colors.kOrange)),
                            ]),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.arrow_forward_ios, size: 16, color: colors.kOrange),
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
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
      const SizedBox(width: 8),
      Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF2C3E50)))),
    ]),
  );
}