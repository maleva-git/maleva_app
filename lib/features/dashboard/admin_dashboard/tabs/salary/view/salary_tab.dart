import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/theme/palette.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/salary_bloc.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Entry point — BlocProvider wrapper
// ─────────────────────────────────────────────────────────────────────────────
class SalaryTab extends StatelessWidget {
  /// Optional: pass a callback to open the salary detail bottom-sheet / page.
  final void Function(Map<String, dynamic> item)? onRowTap;

  const SalaryTab({super.key, this.onRowTap});

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider(
        create: (_) => sl<SalaryBloc>()..add(const SalaryInitialLoad()),
        child: _SalaryView(onRowTap: onRowTap),
      );
  }
}

class _SalaryView extends StatelessWidget {
  final void Function(Map<String, dynamic>)? onRowTap;

  const _SalaryView({this.onRowTap});

  static const double _tabletBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalaryBloc, SalaryState>(
      builder: (context, state) {
        final isTablet =
            MediaQuery.of(context).size.width >= _tabletBreakpoint;

        return isTablet
            ? _TabletLayout(state: state, onRowTap: onRowTap)
            : _PhoneLayout(state: state, onRowTap: onRowTap);
      },
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  final SalaryState state;
  final void Function(Map<String, dynamic>)? onRowTap;

  const _PhoneLayout({required this.state, this.onRowTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SalaryHeader(state: state),
          const SizedBox(height: 10),
          _DateRangeRow(state: state),
          const SizedBox(height: 10),
          _TableHeader(),
          const SizedBox(height: 6),
          Expanded(
            child: _SalaryList(state: state, onRowTap: onRowTap),
          ),
        ],
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final SalaryState state;
  final void Function(Map<String, dynamic>)? onRowTap;

  const _TabletLayout({required this.state, this.onRowTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left panel — summary + date pickers ──────────
          SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SalaryHeader(state: state),
                const SizedBox(height: 24),
                _DatePickerCard(
                  label: 'From Date',
                  date: state.fromDate,
                  onPicked: (picked) => context.read<SalaryBloc>().add(
                    UpdateFromDate(
                      fromDate: DateFormat("yyyy-MM-dd").format(picked),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _DatePickerCard(
                  label: 'To Date',
                  date: state.toDate,
                  onPicked: (picked) => context.read<SalaryBloc>().add(
                    UpdateToDate(
                      toDate: DateFormat("yyyy-MM-dd").format(picked),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // ── Right panel — table + list ────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TableHeader(),
                const SizedBox(height: 6),
                Expanded(
                  child: _SalaryList(state: state, onRowTap: onRowTap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryHeader extends StatelessWidget {
  final SalaryState state;

  const _SalaryHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'SALARY',
          style: GoogleFonts.lato(
            color: Palette.redError,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          '  –  RM ${state.salaryAmount.toStringAsFixed(2)}',
          style: GoogleFonts.lato(
            color: Palette.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// Inline from / to date pickers — used on phone layout.
class _DateRangeRow extends StatelessWidget {
  final SalaryState state;

  const _DateRangeRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // From date
        Expanded(
          child: _InlineDatePicker(
            date: state.fromDate,
            onPicked: (picked) => context.read<SalaryBloc>().add(
              UpdateFromDate(
                fromDate: DateFormat("yyyy-MM-dd").format(picked),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // To date
        Expanded(
          child: _InlineDatePicker(
            date: state.toDate,
            onPicked: (picked) => context.read<SalaryBloc>().add(
              UpdateToDate(
                toDate: DateFormat("yyyy-MM-dd").format(picked),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineDatePicker extends StatelessWidget {
  final String date;
  final ValueChanged<DateTime> onPicked;

  const _InlineDatePicker({required this.date, required this.onPicked});

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(date) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTokens.brandPrimary,
            onPrimary: AppTokens.textOnDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat("dd-MM-yy")
        .format(DateTime.tryParse(date) ?? DateTime.now());

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTokens.surfaceCard,
          border: Border.all(color: AppTokens.surfaceBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 18, color: AppTokens.brandPrimary),
            const SizedBox(width: 8),
            Text(
              displayDate,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTokens.brandDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final String date;
  final ValueChanged<DateTime> onPicked;

  const _DatePickerCard({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(date) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTokens.brandPrimary,
            onPrimary: AppTokens.textOnDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat("dd MMM yyyy")
        .format(DateTime.tryParse(date) ?? DateTime.now());

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTokens.surfaceCard,
          border: Border.all(color: AppTokens.surfaceBorder),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTokens.brandGlow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 20, color: AppTokens.brandPrimary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color: AppTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayDate,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.brandDark,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down_rounded,
                color: AppTokens.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Sticky table header row (BillDate | BillNo | NetAmt)
class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTokens.brandDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _HeaderCell('Bill Date')),
          Expanded(flex: 3, child: _HeaderCell('Bill No')),
          Expanded(flex: 2, child: _HeaderCell('Net Amt', align: TextAlign.right)),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final TextAlign align;

  const _HeaderCell(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: GoogleFonts.lato(
        color: AppTokens.textOnDark,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// Full salary list with loading / empty / error states.
class _SalaryList extends StatelessWidget {
  final SalaryState state;
  final void Function(Map<String, dynamic>)? onRowTap;

  const _SalaryList({required this.state, this.onRowTap});

  @override
  Widget build(BuildContext context) {
    if (state.status == SalaryStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTokens.brandPrimary),
      );
    }

    if (state.status == SalaryStatus.failure) {
      return Center(
        child: Text(
          'Failed to load data.\n${state.errorMessage ?? ''}',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(color: AppTokens.statusDanger, fontSize: 14),
        ),
      );
    }

    if (state.salaryList.isEmpty) {
      return Center(
        child: Text(
          'No salary records found.',
          style: GoogleFonts.lato(
            color: AppTokens.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: state.salaryList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = state.salaryList[index];
        return _SalaryRow(item: item, onTap: () => onRowTap?.call(item));
      },
    );
  }
}

/// Single salary row card.
class _SalaryRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _SalaryRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final billDate = item['BillDate']?.toString() ?? '';
    final billNo = item['BillNoDisplay']?.toString() ?? '';
    final netAmt = (item['NetAmt'] as num?)?.toDouble() ?? 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppTokens.surfaceCard,
          border: Border.all(color: AppTokens.surfaceBorder),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTokens.brandGlow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bill Date
            Expanded(
              flex: 3,
              child: Text(
                billDate,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.brandDark,
                ),
              ),
            ),
            // Bill No
            Expanded(
              flex: 3,
              child: Text(
                billNo,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.maintTextMid,
                ),
              ),
            ),
            // Net Amount — right-aligned with accent chip
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTokens.maintDetailBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'RM ${netAmt.toStringAsFixed(2)}',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.brandPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}