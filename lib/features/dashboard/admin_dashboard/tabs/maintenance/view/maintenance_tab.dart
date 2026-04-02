import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';


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

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class MaintenanceDashboard extends StatelessWidget {
  const MaintenanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaintenanceBloc()..add(MaintenanceStarted()),
      child: const _MaintenancePage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _MaintenancePage extends StatelessWidget {
  const _MaintenancePage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaintenanceBloc, MaintenanceState>(
      builder: (context, state) {
        if (state is MaintenanceInitial || state is MaintenanceLoading) {
          return const Center(
            child: SpinKitFoldingCube(color: kHeaderGradEnd, size: 35),
          );
        }
        if (state is MaintenanceLoaded) {
          return _MaintenanceBody(state: state);
        }
        if (state is MaintenanceError) {
          return Center(
            child: Text(state.message,
                style: GoogleFonts.lato(color: kAccentRed)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Body — LayoutBuilder ────────────────────────────────────────────────────
class _MaintenanceBody extends StatelessWidget {
  final MaintenanceLoaded state;
  const _MaintenanceBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        final hPad    = isTablet ? constraints.maxWidth * 0.08 : 10.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 15, hPad, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 7),

              // ── Month title ─────────────────────────────────────────
              Center(
                child: Text(
                  '${state.currentMonthName} Sales',
                  style: GoogleFonts.lato(
                    color: kAccentRed,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet
                        ? objfun.FontLarge + 2
                        : objfun.FontLarge,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Stats card ──────────────────────────────────────────
              _StatsCard(state: state, isTablet: isTablet),
              const SizedBox(height: 12),

              // ── Toggle buttons ──────────────────────────────────────
              _ToggleButtons(is6Months: state.is6Months, isTablet: isTablet),
              const SizedBox(height: 10),

              // ── List ────────────────────────────────────────────────
              Expanded(
                child: _MaintenanceList(
                  items: state.is6Months
                      ? state.pendingList
                      : state.summaryList,
                  is6Months: state.is6Months,
                  isTablet:  isTablet,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final MaintenanceLoaded state;
  final bool isTablet;

  const _StatsCard({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          _StatsHeaderRow(isTablet: isTablet),
          Divider(
              height: isTablet ? 14 : 10,
              color: kCardBorder,
              thickness: 0.5),
          // Data rows
          _MaintenanceStatRow(
            title: 'BREAKDOWN',
            count: state.breakdownCount,
            amount: state.breakdownAmount,
            isTablet: isTablet,
            color: const Color(0xFFE53935),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          _MaintenanceStatRow(
            title: 'REPAIR',
            count: state.repairCount,
            amount: state.repairAmount,
            isTablet: isTablet,
            color: const Color(0xFFF57C00),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          _MaintenanceStatRow(
            title: 'SERVICE',
            count: state.serviceCount,
            amount: state.serviceAmount,
            isTablet: isTablet,
            color: const Color(0xFF1565C0),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          _MaintenanceStatRow(
            title: 'SPARE PARTS',
            count: state.sparePartsCount,
            amount: state.sparePartsAmount,
            isTablet: isTablet,
            color: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }
}

class _StatsHeaderRow extends StatelessWidget {
  final bool isTablet;
  const _StatsHeaderRow({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.lato(
      color: kTextMuted,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 11 : 10,
      letterSpacing: 0.5,
    );
    return Row(
      children: [
        Expanded(flex: 5, child: Text('CATEGORY', style: style)),
        Expanded(flex: 2, child: Text('COUNT', style: style)),
        Expanded(
            flex: 3,
            child: Text('AMOUNT', style: style, textAlign: TextAlign.end)),
      ],
    );
  }
}

class _MaintenanceStatRow extends StatelessWidget {
  final String title;
  final int    count;
  final double amount;
  final bool   isTablet;
  final Color  color;

  const _MaintenanceStatRow({
    required this.title,
    required this.count,
    required this.amount,
    required this.isTablet,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.lato(
      color: kTextDark,
      fontWeight: FontWeight.w700,
      fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
    );
    final valueStyle = GoogleFonts.lato(
      color: kTextMid,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
    );

    return Row(
      children: [
        // Colour dot + title
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(title, style: labelStyle),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(' $count', style: valueStyle),
        ),
        Expanded(
          flex: 3,
          child: Text(
            amount.toStringAsFixed(2),
            style: valueStyle,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ─── Toggle Buttons ───────────────────────────────────────────────────────────
class _ToggleButtons extends StatelessWidget {
  final bool is6Months;
  final bool isTablet;

  const _ToggleButtons({required this.is6Months, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ToggleBtn(
          label: 'Pending',
          active: is6Months,
          isTablet: isTablet,
          onPressed: () => context
              .read<MaintenanceBloc>()
              .add(MaintenancePendingRequested()),
        ),
        const SizedBox(width: 8),
        _ToggleBtn(
          label: 'Summary',
          active: !is6Months,
          isTablet: isTablet,
          onPressed: () => context
              .read<MaintenanceBloc>()
              .add(MaintenanceSummaryRequested()),
        ),
      ],
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool   active;
  final bool   isTablet;
  final VoidCallback onPressed;

  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.isTablet,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: active ? kGradient : null,
        color:    active ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? kHeaderGradEnd : kCardBorder,
          width: active ? 0 : 0.5,
        ),
        boxShadow: active
            ? [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 14,
              vertical:   isTablet ? 9  : 7,
            ),
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontSize:   isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : kTextMid,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Maintenance List ─────────────────────────────────────────────────────────
class _MaintenanceList extends StatelessWidget {
  final List<MaintenanceModel> items;
  final bool is6Months;
  final bool isTablet;

  const _MaintenanceList({
    required this.items,
    required this.is6Months,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kChipBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.build_circle_outlined,
                  size: 28, color: kHeaderGradEnd),
            ),
            const SizedBox(height: 12),
            Text(
              'No Records Found',
              style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Tablet: 2-column grid
    if (isTablet) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:    2,
          crossAxisSpacing:  12,
          mainAxisSpacing:   10,
          childAspectRatio:  3.8,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) =>
            _MaintenanceCard(item: items[i], is6Months: is6Months, isTablet: isTablet),
      );
    }

    // Mobile: single column
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) =>
          _MaintenanceCard(item: items[i], is6Months: is6Months, isTablet: isTablet),
    );
  }
}

// ─── Single Maintenance Card ──────────────────────────────────────────────────
class _MaintenanceCard extends StatelessWidget {
  final MaintenanceModel item;
  final bool is6Months;
  final bool isTablet;

  const _MaintenanceCard({
    required this.item,
    required this.is6Months,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.lato(
      color: kTextDark,
      fontWeight: FontWeight.w700,
      fontSize: isTablet ? objfun.FontCardText + 1 : objfun.FontCardText,
    );
    final subStyle = GoogleFonts.lato(
      color: kTextMid,
      fontWeight: FontWeight.w500,
      fontSize: isTablet ? 12 : 11,
    );
    final amountStyle = GoogleFonts.lato(
      color: kHeaderGradStart,
      fontWeight: FontWeight.w700,
      fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
    );

    final title = is6Months
        ? (item.SupplierName ?? '')
        : (item.Description ?? '');
    final sub = is6Months ? (item.SDueDate ?? '') : null;
    final amount = item.Amount ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Left accent stripe
            Container(
              width: 4,
              color: is6Months
                  ? const Color(0xFFE53935)
                  : kHeaderGradEnd,
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title,
                              style: titleStyle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                          if (sub != null && sub.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 11,
                                    color: kTextMuted),
                                const SizedBox(width: 4),
                                Text('Due: $sub', style: subStyle),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Amount badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kDetailBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: kCardBorder, width: 0.5),
                      ),
                      child: Text(
                        'RM ${amount.toStringAsFixed(2)}',
                        style: amountStyle,
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