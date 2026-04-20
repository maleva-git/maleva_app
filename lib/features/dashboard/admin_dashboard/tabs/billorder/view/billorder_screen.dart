import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/billorder_bloc.dart';
import '../bloc/billorder_event.dart';
import '../bloc/billorder_state.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────
class BillOrderScreen extends StatelessWidget {
  const BillOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final now   = DateTime.now();
        final from  = DateTime(now.year, now.month, 1);
        final to    = DateTime(now.year, now.month + 1, 0);
        return BillOrderBloc(context)
          ..add(LoadBillOrderEvent(
            fromDate: DateFormat('MM/dd/yyyy').format(from),
            toDate:   DateFormat('MM/dd/yyyy').format(to),
          ));
      },
      child: const _BillOrderBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _BillOrderBody extends StatefulWidget {
  const _BillOrderBody();

  @override
  State<_BillOrderBody> createState() => _BillOrderBodyState();
}

class _BillOrderBodyState extends State<_BillOrderBody> {
  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _toDate   = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  // ── Date Picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate({required bool isFrom}) async {
    final DateTime? picked = await showDatePicker(
      context:     context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate:   DateTime(2020),
      lastDate:    DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   Color(0xFF10B981),
            onPrimary: Colors.white,
            surface:   Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      } else {
        _toDate = picked;
        if (_fromDate.isAfter(_toDate)) _fromDate = _toDate;
      }
    });

    if (mounted) {
      context.read<BillOrderBloc>().add(LoadBillOrderEvent(
        fromDate: DateFormat('MM/dd/yyyy').format(_fromDate),
        toDate:   DateFormat('MM/dd/yyyy').format(_toDate),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return isTablet
            ? _buildTabletLayout(context)
            : _buildMobileLayout(context);
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── LEFT panel (240px) ─────────────────────────────────────────
            SizedBox(
              width: 260,
              child: BlocBuilder<BillOrderBloc, BillOrderState>(
                builder: (context, state) {
                  final count = state is BillOrderLoaded
                      ? state.records.length
                      : 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _SectionTitle(isTablet: true),
                      const SizedBox(height: 20),

                      // Count badge
                      _CountBadge(count: count),
                      const SizedBox(height: 20),

                      // Date filters — stacked vertically
                      _DateFilterBar(
                        fromDate:  _fromDate,
                        toDate:    _toDate,
                        isTablet:  true,
                        onFromTap: () => _pickDate(isFrom: true),
                        onToTap:   () => _pickDate(isFrom: false),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(width: 20),

            // ── RIGHT panel — List ─────────────────────────────────────────
            Expanded(
              child: BlocBuilder<BillOrderBloc, BillOrderState>(
                builder: (context, state) {
                  if (state is BillOrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF10B981)),
                    );
                  }
                  if (state is BillOrderError) {
                    return _ErrorState(
                        message: state.message, isTablet: true);
                  }
                  if (state is BillOrderLoaded) {
                    if (state.records.isEmpty) {
                      return _EmptyState(isTablet: true);
                    }
                    return _BillList(
                        records: state.records, isTablet: true);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Header card
          _HeaderCard(isTablet: false),

          // Date filter row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _DateFilterBar(
              fromDate:  _fromDate,
              toDate:    _toDate,
              isTablet:  false,
              onFromTap: () => _pickDate(isFrom: true),
              onToTap:   () => _pickDate(isFrom: false),
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<BillOrderBloc, BillOrderState>(
              builder: (context, state) {
                if (state is BillOrderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF10B981)),
                  );
                }
                if (state is BillOrderError) {
                  return _ErrorState(
                      message: state.message, isTablet: false);
                }
                if (state is BillOrderLoaded) {
                  if (state.records.isEmpty) {
                    return _EmptyState(isTablet: false);
                  }
                  return _BillList(
                      records: state.records, isTablet: false);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Title (Tablet left panel) ───────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final bool isTablet;
  const _SectionTitle({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4, height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        'BILL ORDERS',
        style: GoogleFonts.inter(
          fontSize:      isTablet ? 20 : 17,
          fontWeight:    FontWeight.w700,
          color:         const Color(0xFF1E293B),
          letterSpacing: 1.2,
        ),
      ),
    ]);
  }
}

// ─── Header Card (Mobile) ─────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  final bool isTablet;
  const _HeaderCard({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:         Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:     Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset:    const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppTokens.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long,
              color: AppTokens.navBarFg, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bill Order Reports',
                style: GoogleFonts.inter(
                  fontSize:   20,
                  fontWeight: FontWeight.w700,
                  color:      const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'View all bill and order transactions',
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Count Badge ──────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:     const Color(0xFF10B981).withOpacity(0.30),
            blurRadius: 16,
            offset:    const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Records',
                style: GoogleFonts.inter(
                  fontSize:   12,
                  color:      Colors.white.withOpacity(0.80),
                  fontWeight: FontWeight.w500,
                )),
            Text('$count',
                style: GoogleFonts.inter(
                  fontSize:   28,
                  color:      Colors.white,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ]),
    );
  }
}

// ─── Date Filter Bar ──────────────────────────────────────────────────────────
class _DateFilterBar extends StatelessWidget {
  final DateTime     fromDate;
  final DateTime     toDate;
  final bool         isTablet;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  const _DateFilterBar({
    required this.fromDate,
    required this.toDate,
    required this.isTablet,
    required this.onFromTap,
    required this.onToTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');

    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateButton(
              label: 'From',
              value: fmt.format(fromDate),
              onTap: onFromTap,
              isTablet: isTablet),
          const SizedBox(height: 10),
          _DateButton(
              label: 'To',
              value: fmt.format(toDate),
              onTap: onToTap,
              isTablet: isTablet),
        ],
      );
    }

    return Row(children: [
      Expanded(
        child: _DateButton(
            label: 'From',
            value: fmt.format(fromDate),
            onTap: onFromTap,
            isTablet: isTablet),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _DateButton(
            label: 'To',
            value: fmt.format(toDate),
            onTap: onToTap,
            isTablet: isTablet),
      ),
    ]);
  }
}

// ─── Date Button ──────────────────────────────────────────────────────────────
class _DateButton extends StatelessWidget {
  final String       label;
  final String       value;
  final VoidCallback onTap;
  final bool         isTablet;

  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14 : 12,
          vertical:   isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color:         Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTokens.brandGradientStart,
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTokens.brandGradientStart,
              blurRadius: 8,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded,
              size:  isTablet ? 16 : 14,
              color: AppTokens.brandGradientStart),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                      fontSize:      isTablet ? 11 : 10,
                      color:         Colors.grey[500],
                      fontWeight:    FontWeight.w600,
                      letterSpacing: 0.5,
                    )),
                Text(value,
                    style: GoogleFonts.inter(
                      fontSize:   isTablet ? 13 : 12,
                      fontWeight: FontWeight.w700,
                      color:      const Color(0xFF1E293B),
                    )),
              ],
            ),
          ),
          Icon(Icons.arrow_drop_down_rounded,
              color: const Color(0xFF10B981),
              size:  isTablet ? 20 : 18),
        ]),
      ),
    );
  }
}

// ─── Bill List ────────────────────────────────────────────────────────────────
class _BillList extends StatelessWidget {
  final List<BillViewModel> records;
  final bool                isTablet;

  const _BillList({required this.records, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      // Grid 2 columns on tablet
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          crossAxisSpacing: 12,
          mainAxisSpacing:  12,
          childAspectRatio: 1.55,
        ),
        itemCount: records.length,
        itemBuilder: (ctx, i) => _BillCard(
            bill: records[i], isTablet: true),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (ctx, i) =>
          _BillCard(bill: records[i], isTablet: false),
    );
  }
}

// ─── Bill Card ────────────────────────────────────────────────────────────────
class _BillCard extends StatelessWidget {
  final BillViewModel bill;
  final bool          isTablet;

  const _BillCard({required this.bill, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:      () => _showDetailsDialog(context),
      onLongPress: () => _showDetailsDialog(context),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 0 : 14),
        padding: EdgeInsets.all(isTablet ? 14 : 16),
        decoration: BoxDecoration(
          color:         Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:     Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset:    const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    bill.BillNoDisplay,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize:   isTablet ? 15 : 16,
                      fontWeight: FontWeight.w700,
                      color:      const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Text(
                  bill.BillNoDisplay1,
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 12 : 13,
                    color:    const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 4 : 6),

            // Supplier
            Text(
              bill.SupplierName,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize:   isTablet ? 13 : 14,
                color:      const Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isTablet ? 3 : 4),

            // Employee + Invoice
            Row(children: [
              Icon(Icons.person,
                  size: isTablet ? 13 : 14,
                  color: const Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  bill.EmployeeName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 12 : 13,
                    color:    const Color(0xFF64748B),
                  ),
                ),
              ),
              if (bill.InvoiceNo.isNotEmpty) ...[
                Icon(Icons.description_outlined,
                    size: isTablet ? 13 : 14,
                    color: const Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  bill.InvoiceNo,
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 12 : 13,
                    color:    const Color(0xFF64748B),
                  ),
                ),
              ],
            ]),
            SizedBox(height: isTablet ? 6 : 8),

            // Status + Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (bill.PStatus == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:         const Color(0xFFFDE68A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Pending',
                        style: GoogleFonts.inter(
                          color:      const Color(0xFF92400E),
                          fontWeight: FontWeight.w600,
                          fontSize:   isTablet ? 11 : 12,
                        )),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:         const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Completed',
                        style: GoogleFonts.inter(
                          color:      const Color(0xFF047857),
                          fontWeight: FontWeight.w600,
                          fontSize:   isTablet ? 11 : 12,
                        )),
                  ),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:         const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'RM ${bill.NetAmt.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      color:      const Color(0xFF047857),
                      fontWeight: FontWeight.w700,
                      fontSize:   isTablet ? 12 : 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Details Dialog ──────────────────────────────────────────────────────────
  void _showDetailsDialog(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width >= 600;

    showGeneralDialog(
      context:            context,
      barrierDismissible: true,
      barrierLabel:       '',
      barrierColor:       Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
             width: isTablet
                ? 480
                : MediaQuery.of(context).size.width * 0.90,
            constraints: BoxConstraints(
              maxHeight:
              MediaQuery.of(context).size.height * 0.80,
            ),
            decoration: BoxDecoration(
              color:         Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:     Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset:    const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical:   isTablet ? 20 : 18,
                    horizontal: isTablet ? 28 : 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTokens.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(children: [
                    const Icon(Icons.receipt_long,
                        color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text('Bill Details',
                        style: GoogleFonts.inter(
                          fontSize:   isTablet ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color:      Colors.white,
                        )),
                  ]),
                ),

                // Scrollable body
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 28 : 24),
                    child: Column(children: [
                      _DetailRow(icon: Icons.receipt_long,
                          label: 'Bill No',
                          value: bill.BillNoDisplay),
                      _DetailRow(icon: Icons.local_shipping_outlined,
                          label: 'Supplier',
                          value: bill.SupplierName),
                      _DetailRow(icon: Icons.badge_outlined,
                          label: 'Employee',
                          value: bill.EmployeeName),
                      _DetailRow(icon: Icons.fire_truck_outlined,
                          label: 'Truck Name',
                          value: bill.TruckName),
                      _DetailRow(icon: Icons.account_circle_outlined,
                          label: 'Driver Name',
                          value: bill.DriverName),
                      _DetailRow(icon: Icons.numbers_outlined,
                          label: 'Job No',
                          value: bill.BillNoDisplay1),
                      _DetailRow(icon: Icons.description_outlined,
                          label: 'Invoice',
                          value: bill.InvoiceNo),
                      _DetailRow(
                          icon:  Icons.currency_exchange_outlined,
                          label: 'Net Amount',
                          value: 'RM ${bill.NetAmt.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),

                      // Status chip
                      Row(children: [
                        Text('Status:',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize:   isTablet ? 14 : 13,
                              color:      const Color(0xFF475569),
                            )),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: bill.PStatus == 0
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFD1FAE5),
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: Text(
                            bill.PStatus == 0
                                ? 'Pending'
                                : 'Completed',
                            style: GoogleFonts.inter(
                              fontSize:   isTablet ? 13 : 12,
                              fontWeight: FontWeight.w600,
                              color: bill.PStatus == 0
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pop(),
                          icon: const Icon(Icons.check, size: 18),
                          label: Text('Close',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 14 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(
            parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

// ─── Detail Row (Dialog) ──────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:         const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                color: const Color(0xFF10B981), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                      fontSize:   12,
                      color:      Colors.grey[500],
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    )),
                const SizedBox(height: 2),
                Text(
                  isEmpty ? 'N/A' : value,
                  style: GoogleFonts.inter(
                    fontSize:   14,
                    fontWeight: FontWeight.w600,
                    color: isEmpty
                        ? Colors.grey
                        : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final bool   isTablet;
  const _ErrorState(
      {required this.message, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              color: Colors.red, size: isTablet ? 60 : 48),
          SizedBox(height: isTablet ? 16 : 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color:    Colors.red,
                  fontSize: isTablet ? 15 : 14)),
          SizedBox(height: isTablet ? 20 : 16),
          ElevatedButton.icon(
            onPressed: () => context
                .read<BillOrderBloc>()
                .add(LoadBillOrderEvent(
              fromDate: DateFormat('MM/dd/yyyy')
                  .format(DateTime(DateTime.now().year,
                  DateTime.now().month, 1)),
              toDate: DateFormat('MM/dd/yyyy')
                  .format(DateTime(DateTime.now().year,
                  DateTime.now().month + 1, 0)),
            )),
            icon:  Icon(Icons.refresh,
                size: isTablet ? 20 : 18),
            label: Text('Retry',
                style: GoogleFonts.inter(
                    fontSize: isTablet ? 15 : 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 28 : 20,
                vertical:   isTablet ? 12 : 10,
              ),
            ),
          ),
        ],
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 26 : 22),
            decoration: BoxDecoration(
              color:  const Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined,
                size:  isTablet ? 52 : 44,
                color: const Color(0xFF10B981)),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text('No Bill Records',
              style: GoogleFonts.inter(
                fontSize:   isTablet ? 18 : 16,
                fontWeight: FontWeight.w700,
                color:      const Color(0xFF334155),
              )),
          SizedBox(height: isTablet ? 8 : 6),
          Text('No bill orders found for the selected period',
              style: GoogleFonts.inter(
                  fontSize: isTablet ? 14 : 13,
                  color:    Colors.grey)),
        ],
      ),
    );
  }
}