import 'package:maleva/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/palette.dart';
import '../bloc/driversalary_bloc.dart';
import '../bloc/driversalary_event.dart';
import '../bloc/driversalary_state.dart';

const kGradient = LinearGradient(
  colors: [Palette.blue700, Palette.blue400],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Embeddable Dashboard Widget ─────────────────────────────────────────────
class DriverSalaryWidget extends StatelessWidget {
  const DriverSalaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DriverSalaryBloc>()..add(DriverSalaryStarted()),
      child: const _DriverSalaryView(),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────
class _DriverSalaryView extends StatelessWidget {
  const _DriverSalaryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverSalaryBloc, DriverSalaryState>(
      builder: (context, state) {
        if (state is DriverSalaryInitial || state is DriverSalaryLoading) {
          return Center(
            child: SpinKitFoldingCube(color: Palette.blue400, size: 35),
          );
        }
        if (state is DriverSalaryLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > kTabletBreak;
              return _DriverSalaryBody(state: state, isTablet: isTablet);
            },
          );
        }
        if (state is DriverSalaryError) {
          return Center(
            child: Text(state.message,
                style: AppTypography.bodyLarge(color: Palette.redAccent)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

void _showSalaryDetailsDialog(BuildContext context, Map<String, dynamic> item) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _SalaryDetailsDialogContent(item: item),
  );
}

class _SalaryDetailsDialogContent extends StatefulWidget {
  final Map<String, dynamic> item;
  const _SalaryDetailsDialogContent({required this.item});

  @override
  State<_SalaryDetailsDialogContent> createState() => _SalaryDetailsDialogContentState();
}

class _SalaryDetailsDialogContentState extends State<_SalaryDetailsDialogContent> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollable();
    });
  }

  void _checkScrollable() {
    if (_scrollController.hasClients) {
      final isScrollable = _scrollController.position.maxScrollExtent > 0;
      final isAtBottom = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 20;
      final shouldShow = isScrollable && !isAtBottom;
      
      if (_showScrollHint != shouldShow) {
        setState(() {
          _showScrollHint = shouldShow;
        });
      }
    }
  }

  void _onScroll() {
    _checkScrollable();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null || dateString.toString().isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateString.toString());
      if (dt.year < 2000) return '-'; // Ignore 0001-01-01
      return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
    } catch (e) {
      return dateString.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                  gradient: kGradient, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['CNumberDisplay']?.toString() ?? 'RTI DETAILS',
                      style: AppTypography.heading2(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable detail rows with Stack for Hint
            Flexible(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24), // Space for the pill
                      child: Column(
                        children: [
                          _DetailRow('RTI Date', item['SSaleDate']?.toString() ?? '-'),
                          _DetailRow('Job No', item['JobNo']?.toString() ?? '-'),
                          _DetailRow('Driver', item['DriverName']?.toString() ?? '-'),
                          _DetailRow('Truck', item['TruckName']?.toString() ?? '-'),
                          _DetailRow('Truck Type', item['TruckType']?.toString() ?? '-'),
                          const Divider(height: 24),
                          _DetailRow('Customer', item['CustomerName']?.toString() ?? '-'),
                          _DetailRow('Origin', item['Origin']?.toString() ?? '-'),
                          _DetailRow('Destination', item['Destination']?.toString() ?? '-'),
                          _DetailRow('Full Route', item['FullDestination']?.toString() ?? '-'),
                          const Divider(height: 24),
                          _DetailRow('Quantity', item['Quantity']?.toString() ?? '-'),
                          _DetailRow('Pick Date', _formatDate(item['PickDate'])),
                          _DetailRow('Delivery Date', _formatDate(item['DliveryDate'])),
                          _DetailRow('E-Link', item['ELink']?.toString() ?? '-'),
                          _DetailRow('EX-Link', item['EXLink']?.toString() ?? '-'),
                          if (item['Remarks'] != null && item['Remarks'].toString().isNotEmpty)
                            _DetailRow('Remarks', item['Remarks'].toString()),
                          if (item['Comments'] != null && item['Comments'].toString().isNotEmpty)
                            _DetailRow('Comments', item['Comments'].toString()),
                          const Divider(height: 24),
                          _DetailRow('Base Salary', item['Salary']?.toString() ?? '0.0'),
                          _DetailRow('Pickup Amount', item['PickupAmount']?.toString() ?? '0.0'),
                          _DetailRow('Drop Amount', item['DropAmount']?.toString() ?? '0.0'),
                          _DetailRow('Sleeping Amount', item['SleepingAmount']?.toString() ?? '0.0'),
                          _DetailRow('Exit Amount', item['ExitAmount']?.toString() ?? '0.0'),
                          _DetailRow('Empty Delivery', item['EmptyDeliveryAmount']?.toString() ?? '0.0'),
                          _DetailRow('Manpower Amount', item['ManpwAmount']?.toString() ?? '0.0'),
                          const Divider(height: 24),
                          _DetailRow('Total Amount', item['Amount']?.toString() ?? '0.0'),
                        ],
                      ),
                    ),
                  ),

                  // Floating Scroll Hint Pill
                  if (_showScrollHint)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Palette.blue700,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Scroll down for more',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(width: 6),
                            Icon(Icons.keyboard_double_arrow_down_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close',
                    style: AppTypography.heading2(color: Palette.blue700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: AppTypography.bodyLarge(
                    color: Palette.textMid, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value,
                style: AppTypography.bodyLarge(
                    color: Palette.textDark2, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _DriverSalaryBody extends StatelessWidget {
  final DriverSalaryLoaded state;
  final bool isTablet;

  const _DriverSalaryBody({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(isTablet ? 20 : 10, 15, isTablet ? 20 : 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 7),

          // ── Salary title + amount ───────────────────
          _SalaryTitleRow(amount: state.salaryAmount, isTablet: isTablet),
          const SizedBox(height: 10),

          // ── Date filter row ─────────────────────────
          _DateFilterRow(state: state, isTablet: isTablet),
          const SizedBox(height: 10),

          // ── Grid header ─────────────────────────────
          _GridHeader(isTablet: isTablet),
          const SizedBox(height: 6),

          // ── List / Grid ─────────────────────────────
          Expanded(
            child: state.salaryList.isEmpty
                ? _EmptyState(isTablet: isTablet)
                : isTablet
                    ? _TabletGrid(state: state)
                    : _MobileList(state: state),
          ),
        ],
      ),
    );
  }
}

// ─── Salary Title Row ─────────────────────────────────────────────────────────
class _SalaryTitleRow extends StatelessWidget {
  final double amount;
  final bool isTablet;
  const _SalaryTitleRow({required this.amount, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('SALARY', style: AppTypography.heading1(color: Palette.redAccent)),
        const SizedBox(width: 6),
        Text('- ${amount.toStringAsFixed(2)}',
            style: AppTypography.heading1(color: Palette.greenSuccess)),
      ],
    );
  }
}

// ─── Date Filter Row ──────────────────────────────────────────────────────────
class _DateFilterRow extends StatelessWidget {
  final DriverSalaryLoaded state;
  final bool isTablet;
  const _DateFilterRow({required this.state, required this.isTablet});

  Future<void> _pick(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Palette.blue700,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Palette.textDark2,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final f = DateFormat('yyyy-MM-dd').format(picked);
    if (isFrom) {
      if (!context.mounted) return;
      context.read<DriverSalaryBloc>().add(DriverSalaryFromDateChanged(f));
    } else {
      if (!context.mounted) return;
      context.read<DriverSalaryBloc>().add(DriverSalaryToDateChanged(f));
    }
  }

  @override
  Widget build(BuildContext context) {
    String fmt(String d) {
      try {
        return DateFormat('dd-MM-yy').format(DateTime.parse(d));
      } catch (_) {
        return d;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _DateTile(
            label: 'From',
            display: fmt(state.fromDate),
            onTap: () => _pick(context, true),
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DateTile(
            label: 'To',
            display: fmt(state.toDate),
            onTap: () => _pick(context, false),
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String display;
  final bool isTablet;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.display,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Palette.grey200p,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Palette.cardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: AppTypography.badgeText(
                    color: Palette.kTextMuted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(display,
                    style: AppTypography.heading3(
                        color: Palette.textDark2, fontWeight: FontWeight.w700)),
                const Icon(Icons.calendar_month_outlined,
                    size: 18, color: Palette.blue400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grid Header ─────────────────────────────────────────────────────────────
class _GridHeader extends StatelessWidget {
  final bool isTablet;
  const _GridHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.badgeText(
        color: Colors.white.withValues(alpha: 0.85),
        fontWeight: FontWeight.w600);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(children: [
            Expanded(
                flex: 2,
                child:
                    Text('RTI Date', textAlign: TextAlign.left, style: style)),
            Expanded(
                flex: 2,
                child: Text('RTI No', textAlign: TextAlign.left, style: style)),
          ]),
          const SizedBox(height: 3),
          Row(children: [
            Expanded(
                flex: 2,
                child: Text('Job No', textAlign: TextAlign.left, style: style)),
            Expanded(
                flex: 2,
                child: Text('Amount', textAlign: TextAlign.left, style: style)),
          ]),
        ],
      ),
    );
  }
}

// ─── Mobile: single column ListView ──────────────────────────────────────────
class _MobileList extends StatelessWidget {
  final DriverSalaryLoaded state;
  const _MobileList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.salaryList.length,
      itemBuilder: (ctx, i) => _SalaryCard(
        item: state.salaryList[i],
        isTablet: false,
      ),
    );
  }
}

// ─── Tablet: 2-column GridView ────────────────────────────────────────────────
class _TabletGrid extends StatelessWidget {
  final DriverSalaryLoaded state;
  const _TabletGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 10,
        childAspectRatio: 3.2,
      ),
      itemCount: state.salaryList.length,
      itemBuilder: (ctx, i) => _SalaryCard(
        item: state.salaryList[i],
        isTablet: true,
      ),
    );
  }
}

// ─── Single Salary Card ───────────────────────────────────────────────────────
class _SalaryCard extends StatelessWidget {
  final dynamic item;
  final bool isTablet;

  const _SalaryCard({required this.item, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final valStyle = AppTypography.bodyLarge(color: Palette.textDark2);

    final rtiDate = item['SSaleDate']?.toString() ?? '-';
    final rtiNo = item['CNumberDisplay']?.toString() ?? '-';
    final jobNo = item['JobNo']?.toString() ?? '-';
    final amount = item['Amount']?.toString() ?? '-';

    return InkWell(
      onTap: () => _showSalaryDetailsDialog(
          context, Map<String, dynamic>.from(item as Map)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.cardBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Palette.blue700.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // Left gradient accent
              Container(
                width: 4,
                decoration: const BoxDecoration(gradient: kGradient),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: RTI Date + RTI No
                      Row(children: [
                        Expanded(
                          child: Text(rtiDate,
                              style: valStyle, overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          child: Text(rtiNo,
                              style: valStyle, overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      // Row 2: Job No + Amount
                      Row(children: [
                        Expanded(
                          child: Text(jobNo,
                              style: valStyle, overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          child: Text(
                            amount,
                            style:
                                valStyle.copyWith(color: Palette.greenSuccess),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              // Arrow hint
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: Palette.kTextMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isTablet;
  const _EmptyState({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: Palette.chipBg, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.payments_outlined,
                size: 32, color: Palette.blue400),
          ),
          const SizedBox(height: 14),
          Text('No Salary Records',
              style: AppTypography.heading2(
                  color: Palette.textDark2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Select a date range to view salary',
              style: AppTypography.bodyMedium(color: Palette.kTextMuted)),
        ],
      ),
    );
  }
}
