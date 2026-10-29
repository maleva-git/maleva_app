import 'package:maleva/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/palette.dart';
import 'package:maleva/core/ui/premium.dart';
import '../bloc/driversalary_bloc.dart';
import '../bloc/driversalary_event.dart';
import '../bloc/driversalary_state.dart';


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
          return const ColoredBox(color: Px.page, child: Center(child: CircularProgressIndicator(color: Px.brand)));
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

  /// The report's `dd/MM/yyyy HH:mm:ss` ('' for none) as `dd/MM/yyyy hh:mm a`.
  String _formatDate(dynamic dateString) {
    if (dateString == null || dateString.toString().isEmpty) return '-';
    try {
      final dt = DateFormat('dd/MM/yyyy HH:mm:ss').parseStrict(dateString.toString());
      return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
    } catch (e) {
      return dateString.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                  gradient: Px.gradient, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['rtiNo']?.toString() ?? 'RTI DETAILS',
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
                          _DetailRow('RTI Date', item['rtiDate']?.toString() ?? '-'),
                          _DetailRow('Job No', item['jobNo']?.toString() ?? '-'),
                          _DetailRow('Driver', item['driverName']?.toString() ?? '-'),
                          _DetailRow('Truck', item['truckName']?.toString() ?? '-'),
                          _DetailRow('Truck Type', item['truckType']?.toString() ?? '-'),
                          const Divider(height: 24),
                          _DetailRow('Customer', item['customerName']?.toString() ?? '-'),
                          _DetailRow('Origin', item['origin']?.toString() ?? '-'),
                          _DetailRow('Destination', item['destination']?.toString() ?? '-'),
                          _DetailRow('Full Route', item['place']?.toString() ?? '-'),
                          const Divider(height: 24),
                          _DetailRow('Quantity', item['quantity']?.toString() ?? '-'),
                          _DetailRow('Pick Date', _formatDate(item['pickupDate'])),
                          _DetailRow('Delivery Date', _formatDate(item['deliveryDate'])),
                          _DetailRow('E-Link', item['enterLink']?.toString() ?? '-'),
                          _DetailRow('EX-Link', item['exitLink']?.toString() ?? '-'),
                          if (item['remarks'] != null && item['remarks'].toString().isNotEmpty)
                            _DetailRow('Remarks', item['remarks'].toString()),
                          if (item['comments'] != null && item['comments'].toString().isNotEmpty)
                            _DetailRow('Comments', item['comments'].toString()),
                          const Divider(height: 24),
                          _DetailRow('Base Salary', item['salary']?.toString() ?? '0.0'),
                          _DetailRow('Pickup Amount', item['pickupAmount']?.toString() ?? '0.0'),
                          _DetailRow('Drop Amount', item['dropAmount']?.toString() ?? '0.0'),
                          _DetailRow('Sleeping Amount', item['sleepingAmount']?.toString() ?? '0.0'),
                          _DetailRow('Exit Amount', item['exitAmount']?.toString() ?? '0.0'),
                          _DetailRow('Empty Delivery', item['emptyDeliveryAmount']?.toString() ?? '0.0'),
                          _DetailRow('Manpower Amount', item['manpowerAmount']?.toString() ?? '0.0'),
                          const Divider(height: 24),
                          _DetailRow('Total Amount', item['amount']?.toString() ?? '0.0'),
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
                          color: Px.brand,
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
                child: Text('Close', style: Px.t(15, weight: FontWeight.w700, color: Px.brand)),
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
            child: Text(label, style: Px.t(14, color: Px.sub)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value, style: Px.t(14, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Body (premium look, owner 2026-10-29) ──────────────────────────────────────
class _DriverSalaryBody extends StatelessWidget {
  final DriverSalaryLoaded state;
  final bool isTablet;

  const _DriverSalaryBody({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    String fmt(String d) {
      try {
        return DateFormat('dd MMM').format(DateTime.parse(d));
      } catch (_) {
        return d;
      }
    }

    final side = isTablet ? 24.0 : 14.0;
    return ColoredBox(
      color: Px.page,
      child: ListView(
        padding: EdgeInsets.fromLTRB(side, 12, side, 28),
        children: [
          PHero(
            label: 'Salary for these dates',
            value: 'RM ${NumberFormat('#,##0.00').format(state.salaryAmount)}',
            footnote: '${fmt(state.fromDate)} – ${fmt(state.toDate)}  ·  ${state.salaryList.length} trip(s)',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 12),
          _DateFilterRow(state: state, isTablet: isTablet),
          const PSection('Trips', subtitle: 'Tap a trip to see how it is paid'),
          if (state.salaryList.isEmpty)
            const PCard(
              child: PEmpty(icon: Icons.payments_rounded, title: 'No salary records', subtitle: 'Choose other dates to see your trips'),
            )
          else
            for (final item in state.salaryList) _SalaryCard(item: item),
        ],
      ),
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
            primary: Px.brand,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Px.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final f = DateFormat('yyyy-MM-dd').format(picked);
    if (!context.mounted) return;
    if (isFrom) {
      context.read<DriverSalaryBloc>().add(DriverSalaryFromDateChanged(f));
    } else {
      context.read<DriverSalaryBloc>().add(DriverSalaryToDateChanged(f));
    }
  }

  @override
  Widget build(BuildContext context) {
    String fmt(String d) {
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(d));
      } catch (_) {
        return d;
      }
    }

    return Row(children: [
      Expanded(
        child: PPill(caption: 'FROM', label: fmt(state.fromDate), icon: Icons.calendar_month_rounded, onTap: () => _pick(context, true)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: PPill(caption: 'TO', label: fmt(state.toDate), icon: Icons.calendar_month_rounded, onTap: () => _pick(context, false)),
      ),
    ]);
  }
}

// ─── One trip ─────────────────────────────────────────────────────────────────
class _SalaryCard extends StatelessWidget {
  final dynamic item;

  const _SalaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rtiDate = item['rtiDate']?.toString() ?? '';
    final rtiNo = item['rtiNo']?.toString() ?? '-';
    final jobNo = item['jobNo']?.toString() ?? '';
    final amount = double.tryParse(item['amount']?.toString() ?? '');
    final route = [item['origin'], item['destination']].where((v) => v != null && v.toString().trim().isNotEmpty).join(' → ');
    return PCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      onTap: () => _showSalaryDetailsDialog(context, Map<String, dynamic>.from(item as Map)),
      child: Row(children: [
        const PIcon(Icons.route_rounded, size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rtiNo, maxLines: 1, overflow: TextOverflow.ellipsis, style: Px.t(15, weight: FontWeight.w800)),
            const SizedBox(height: 2),
            if (jobNo.isNotEmpty) Text(jobNo, maxLines: 1, overflow: TextOverflow.ellipsis, style: Px.t(13, weight: FontWeight.w600)),
            Text([rtiDate, route].where((v) => v.isNotEmpty).join('  ·  '), maxLines: 2, overflow: TextOverflow.ellipsis, style: Px.small),
          ]),
        ),
        const SizedBox(width: 8),
        Text(amount == null ? (item['amount']?.toString() ?? '-') : 'RM ${NumberFormat('#,##0.00').format(amount)}',
            style: Px.t(15, weight: FontWeight.w800, color: Px.green)),
        const SizedBox(width: 2),
        const Icon(Icons.chevron_right_rounded, color: Px.muted),
      ]),
    );
  }
}
