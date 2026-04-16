import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../bloc/driversalary_bloc.dart';
import '../bloc/driversalary_event.dart';
import '../bloc/driversalary_state.dart';


// ─── Design Tokens ────────────────────────────────────────────────────────────
const kHeaderGradStart = Color(0xFF1A3A8F);
const kHeaderGradEnd   = Color(0xFF4A6FD4);
const kCardBorder      = Color(0xFFC5D0EE);
const kPageBg          = Color(0xFFF4F6FB);
const kTextDark        = Color(0xFF1E2D5E);
const kTextMid         = Color(0xFF4A5A8A);
const kTextMuted       = Color(0xFF8A96BF);
const kDetailBg        = Color(0xFFF0F4FF);
const kChipBg          = Color(0xFFEEF2FF);
const kAccentRed       = Color(0xFFB33040);
const kAccentGreen     = Color(0xFF2E7D32);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
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
      create: (_) =>
      DriverSalaryBloc()..add(DriverSalaryStarted()),
      child: const _DriverSalaryView(),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────
class _DriverSalaryView extends StatelessWidget {
  const _DriverSalaryView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverSalaryBloc, DriverSalaryState>(
      listener: (context, state) {
        if (state is DriverSalaryShowDetail) {
          _showSalaryDetails(context, state.item);
        }
      },
      builder: (context, state) {
        if (state is DriverSalaryInitial ||
            state is DriverSalaryLoading) {
          return const Center(
            child: SpinKitFoldingCube(
                color: kHeaderGradEnd, size: 35),
          );
        }
        if (state is DriverSalaryLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet =
                  constraints.maxWidth > kTabletBreak;
              return _DriverSalaryBody(
                  state: state, isTablet: isTablet);
            },
          );
        }
        if (state is DriverSalaryError) {
          return Center(
            child: Text(state.message,
                style: GoogleFonts.lato(
                    color: kAccentRed, fontSize: 13)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showSalaryDetails(
      BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    gradient: kGradient,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      item['CNumberDisplay']?.toString() ??
                          '-',
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Detail rows
              _DetailRow('RTI Date',
                  item['SSaleDate']?.toString() ?? '-'),
              _DetailRow('Job No',
                  item['JobNo']?.toString() ?? '-'),
              _DetailRow('Amount',
                  item['Amount']?.toString() ?? '-'),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close',
                      style: GoogleFonts.lato(
                          color: kHeaderGradStart,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: GoogleFonts.lato(
                    color: kTextMid,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: GoogleFonts.lato(
                    color: kTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
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

  const _DriverSalaryBody(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          isTablet ? 20 : 10, 15, isTablet ? 20 : 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 7),

          // ── Salary title + amount ───────────────────
          _SalaryTitleRow(
              amount: state.salaryAmount,
              isTablet: isTablet),
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
  final bool   isTablet;
  const _SalaryTitleRow(
      {required this.amount, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('SALARY',
            style: GoogleFonts.lato(
              color: kAccentRed,
              fontWeight: FontWeight.w700,
              fontSize: isTablet
                  ? objfun.FontLarge + 2
                  : objfun.FontLarge,
              letterSpacing: 0.3,
            )),
        const SizedBox(width: 6),
        Text('- ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.lato(
              color: kAccentGreen,
              fontWeight: FontWeight.w700,
              fontSize: isTablet
                  ? objfun.FontLarge + 2
                  : objfun.FontLarge,
              letterSpacing: 0.3,
            )),
      ],
    );
  }
}

// ─── Date Filter Row ──────────────────────────────────────────────────────────
class _DateFilterRow extends StatelessWidget {
  final DriverSalaryLoaded state;
  final bool isTablet;
  const _DateFilterRow(
      {required this.state, required this.isTablet});

  Future<void> _pick(
      BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kHeaderGradStart,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: kTextDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final f = DateFormat('yyyy-MM-dd').format(picked);
    if (isFrom) {
      context
          .read<DriverSalaryBloc>()
          .add(DriverSalaryFromDateChanged(f));
    } else {
      context
          .read<DriverSalaryBloc>()
          .add(DriverSalaryToDateChanged(f));
    }
  }

  @override
  Widget build(BuildContext context) {
    String _fmt(String d) {
      try {
        return DateFormat('dd-MM-yy')
            .format(DateTime.parse(d));
      } catch (_) {
        return d;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _DateTile(
            label:   'From',
            display: _fmt(state.fromDate),
            onTap:   () => _pick(context, true),
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DateTile(
            label:   'To',
            display: _fmt(state.toDate),
            onTap:   () => _pick(context, false),
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String   label;
  final String   display;
  final bool     isTablet;
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
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border:
          Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: GoogleFonts.lato(
                    color: kTextMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.6)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(display,
                    style: GoogleFonts.lato(
                        color: kTextDark,
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 14 : 13)),
                const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: kHeaderGradEnd),
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
    final style = GoogleFonts.lato(
      color: Colors.white.withOpacity(0.85),
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 11 : 10,
      letterSpacing: 0.5,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(children: [
            Expanded(
                flex: 2,
                child: Text('RTI Date',
                    textAlign: TextAlign.left,
                    style: style)),
            Expanded(
                flex: 2,
                child: Text('RTI No',
                    textAlign: TextAlign.left,
                    style: style)),
          ]),
          const SizedBox(height: 3),
          Row(children: [
            Expanded(
                flex: 2,
                child: Text('Job No',
                    textAlign: TextAlign.left,
                    style: style)),
            Expanded(
                flex: 2,
                child: Text('Amount',
                    textAlign: TextAlign.left,
                    style: style)),
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
        item:     state.salaryList[i],
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
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  10,
        childAspectRatio: 3.2,
      ),
      itemCount: state.salaryList.length,
      itemBuilder: (ctx, i) => _SalaryCard(
        item:     state.salaryList[i],
        isTablet: true,
      ),
    );
  }
}

// ─── Single Salary Card ───────────────────────────────────────────────────────
class _SalaryCard extends StatelessWidget {
  final dynamic item;
  final bool    isTablet;

  const _SalaryCard(
      {required this.item, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final valStyle = GoogleFonts.lato(
      color: kTextDark,
      fontWeight: FontWeight.w600,
      fontSize:
      isTablet ? objfun.FontCardText + 1 : objfun.FontCardText,
    );

    final rtiDate = item['SSaleDate']?.toString()    ?? '-';
    final rtiNo   = item['CNumberDisplay']?.toString() ?? '-';
    final jobNo   = item['JobNo']?.toString()          ?? '-';
    final amount  = item['Amount']?.toString()         ?? '-';

    return InkWell(
      onTap: () => context
          .read<DriverSalaryBloc>()
          .add(DriverSalaryDetailRequested(
          Map<String, dynamic>.from(item as Map))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kCardBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: kHeaderGradStart.withOpacity(0.06),
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
                decoration: const BoxDecoration(
                    gradient: kGradient),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // Row 1: RTI Date + RTI No
                      Row(children: [
                        Expanded(
                          child: Text(rtiDate,
                              style: valStyle,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          child: Text(rtiNo,
                              style: valStyle,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      // Row 2: Job No + Amount
                      Row(children: [
                        Expanded(
                          child: Text(jobNo,
                              style: valStyle,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          child: Text(
                            amount,
                            style: valStyle.copyWith(
                                color: kAccentGreen),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              // Arrow hint
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: kTextMuted),
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
                color: kChipBg,
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.payments_outlined,
                size: 32, color: kHeaderGradEnd),
          ),
          const SizedBox(height: 14),
          Text('No Salary Records',
              style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text('Select a date range to view salary',
              style: GoogleFonts.lato(
                  color: kTextMuted, fontSize: 12)),
        ],
      ),
    );
  }
}