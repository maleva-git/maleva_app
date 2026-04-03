import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../../../../../core/theme/tokens.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;



const double kTabletBreak = 600;

// ─── Root — can be embedded inside a dashboard tab or used standalone ─────────
class MaintenanceDashboardWidget extends StatelessWidget {
  const MaintenanceDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaintenanceBloc()..add(MaintenanceStarted()),
      child: const _MaintenanceView(),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────
class _MaintenanceView extends StatelessWidget {
  const _MaintenanceView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaintenanceBloc, MaintenanceState>(
      builder: (context, state) {
        if (state is MaintenanceInitial || state is MaintenanceLoading) {
          return const Center(
            child: SpinKitFoldingCube(color: AppTokens.invoiceHeaderEnd, size: 35),
          );
        }
        if (state is MaintenanceLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > kTabletBreak;
              return _MaintenanceBody(
                  state: state, isTablet: isTablet, constraints: constraints);
            },
          );
        }
        if (state is MaintenanceError) {
          return Center(
            child: Text(state.message,
                style: GoogleFonts.lato(color: colour.kAccentRed, fontSize: 13)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _MaintenanceBody extends StatelessWidget {
  final MaintenanceLoaded state;
  final bool isTablet;
  final BoxConstraints constraints;

  const _MaintenanceBody({
    required this.state,
    required this.isTablet,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    // Tablet: wider horizontal padding, 2-column stats grid
    final hPad = isTablet ? constraints.maxWidth * 0.04 : 10.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 15, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 7),

          // ── Month title ─────────────────────────────────────────────
          Center(
            child: Text(
              '${state.currentMonthName} Sales',
              style: GoogleFonts.lato(
                color: colour.kAccentRed,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontLarge,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Stats section — 1-col mobile, 2-col tablet ──────────────
          isTablet ? _StatsGrid(state: state) : _StatsList(state: state),
          const SizedBox(height: 14),

          // ── Pending / Summary toggle buttons ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ToggleButton(
                label: 'Pending',
                active: state.is6Months,
                onPressed: () => context
                    .read<MaintenanceBloc>()
                    .add(MaintenancePendingRequested()),
              ),
              const SizedBox(width: 8),
              _ToggleButton(
                label: 'Summary',
                active: !state.is6Months,
                onPressed: () => context
                    .read<MaintenanceBloc>()
                    .add(MaintenanceSummaryRequested()),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── List ────────────────────────────────────────────────────
          Expanded(
            child: _MaintenanceList(state: state, isTablet: isTablet),
          ),
        ],
      ),
    );
  }
}

// ─── Stats List (mobile — single column) ─────────────────────────────────────
class _StatsList extends StatelessWidget {
  final MaintenanceLoaded state;
  const _StatsList({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MaintenanceStatRow(
            title: 'BREAKDOWN',
            count: state.breakdownCount,
            amount: state.breakdownAmount),
        const SizedBox(height: 8),
        _MaintenanceStatRow(
            title: 'REPAIR',
            count: state.repairCount,
            amount: state.repairAmount),
        const SizedBox(height: 8),
        _MaintenanceStatRow(
            title: 'SERVICE',
            count: state.serviceCount,
            amount: state.serviceAmount),
        const SizedBox(height: 8),
        _MaintenanceStatRow(
            title: 'SPARE PARTS',
            count: state.sparePartsCount,
            amount: state.sparePartsAmount),
      ],
    );
  }
}

// ─── Stats Grid (tablet — 2 columns) ─────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final MaintenanceLoaded state;
  const _StatsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('BREAKDOWN',  state.breakdownCount,  state.breakdownAmount),
      ('REPAIR',     state.repairCount,     state.repairAmount),
      ('SERVICE',    state.serviceCount,    state.serviceAmount),
      ('SPARE PARTS',state.sparePartsCount, state.sparePartsAmount),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 4.0,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _MaintenanceStatCard(
        title:  items[i].$1,
        count:  items[i].$2,
        amount: items[i].$3,
      ),
    );
  }
}

// ─── Single stat row (mobile) ─────────────────────────────────────────────────
class _MaintenanceStatRow extends StatelessWidget {
  final String title;
  final int count;
  final double amount;

  const _MaintenanceStatRow({
    required this.title,
    required this.count,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppTokens.invoiceHeaderStart.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppTokens.headerGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),


          Expanded(
            flex: 5,
            child: Text(
              title,
              style: GoogleFonts.lato(
                color: colour.kTextDark,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontLow,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colour.kChipBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: AppTokens.invoiceHeaderStart,
                  fontWeight: FontWeight.w700,
                  fontSize: objfun.FontLow,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              amount.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: GoogleFonts.lato(
                color: AppTokens.maintTextMid,
                fontWeight: FontWeight.w600,
                fontSize: objfun.FontLow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single stat card (tablet) ────────────────────────────────────────────────
class _MaintenanceStatCard extends StatelessWidget {
  final String title;
  final int count;
  final double amount;

  const _MaintenanceStatCard({
    required this.title,
    required this.count,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppTokens.invoiceHeaderStart.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              gradient: AppTokens.headerGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lato(
                color: colour.kTextDark,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontLow,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colour.kChipBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.lato(
                color: AppTokens.invoiceHeaderStart,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontLow,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount.toStringAsFixed(2),
            style: GoogleFonts.lato(
              color: AppTokens.maintTextMid,
              fontWeight: FontWeight.w600,
              fontSize: objfun.FontLow,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Maintenance List ─────────────────────────────────────────────────────────
class _MaintenanceList extends StatelessWidget {
  final MaintenanceLoaded state;
  final bool isTablet;

  const _MaintenanceList(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final list =
    state.is6Months ? state.pendingList : state.summaryList;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colour.kChipBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.build_outlined,
                  size: 28, color: AppTokens.invoiceHeaderEnd),
            ),
            const SizedBox(height: 12),
            Text('No Records Found',
                style: GoogleFonts.lato(
                    color: AppTokens.maintTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      );
    }

    // Tablet: 2-column grid of cards
    if (isTablet) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3.8,
        ),
        itemCount: list.length,
        itemBuilder: (ctx, i) =>
            _MaintenanceCard(data: list[i], is6Months: state.is6Months),
      );
    }

    // Mobile: single column
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) =>
          _MaintenanceCard(data: list[i], is6Months: state.is6Months),
    );
  }
}

// ─── Single list card ─────────────────────────────────────────────────────────
class _MaintenanceCard extends StatelessWidget {
  final dynamic data;
  final bool is6Months;

  const _MaintenanceCard({required this.data, required this.is6Months});

  @override
  Widget build(BuildContext context) {
    // Data null-ah iruntha safe-ah handle panna
    if (data == null) return const SizedBox.shrink();

    final title = is6Months
        ? (data.SupplierName ?? 'No Supplier')
        : (data.Description ?? 'No Description');

    // Safe parsing: amount dynamic-ah iruntha double-ah mathurathuku
    final double amount = double.tryParse(data.Amount?.toString() ?? '0') ?? 0.0;

    final dueDate = is6Months ? (data.SDueDate ?? '') : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppTokens.invoiceHeaderStart.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight( // height: double.infinity-ku pathila
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Gradient bar full height vara
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(gradient: AppTokens.headerGradient),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.lato(
                              color: AppTokens.maintTextDark,
                              fontWeight: FontWeight.w700,
                              // Fallback value for font size
                              fontSize: objfun.FontCardText ?? 14.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (is6Months && dueDate.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 11, color: AppTokens.planTextMuted),
                                const SizedBox(width: 4),
                                Text(
                                  'Due: $dueDate',
                                  style: GoogleFonts.lato(
                                    color: AppTokens.planTextMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colour.kDetailBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
                      ),
                      child: Text(
                        'RM ${amount.toStringAsFixed(2)}', // Ippo ithu safe
                        style: GoogleFonts.lato(
                          color: AppTokens.invoiceHeaderStart,
                          fontWeight: FontWeight.w700,
                          fontSize: objfun.FontCardText ?? 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle Button (Pending / Summary) ───────────────────────────────────────
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onPressed;

  const _ToggleButton({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        gradient: active ? AppTokens.headerGradient : null,
        color: active ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppTokens.invoiceHeaderStart : AppTokens.invoiceHeaderEnd,
          width: active ? 0 : 1,
        ),
        boxShadow: active
            ? [
          BoxShadow(
            color: AppTokens.invoiceHeaderStart,
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: active ? Colors.white : AppTokens.maintTextMid,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}