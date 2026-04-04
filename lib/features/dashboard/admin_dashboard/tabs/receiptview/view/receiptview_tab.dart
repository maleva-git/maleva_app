import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/colors/colors.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/receiptview_bloc.dart';
import '../bloc/receiptview_event.dart';
import '../bloc/receiptview_state.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocBuilder<ReceiptBloc, ReceiptState>(
      builder: (context, state) {
        return Container(
          color: const Color(0xFFF4F6FF),
          child: isTablet
              ? _buildTabletLayout(context, state)
              : _buildMobileLayout(context, state),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(BuildContext context, ReceiptState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (60%) — Filter + List
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _FilterCard(state: state, isTablet: true),
                const SizedBox(height: 12),
                Expanded(
                  child: !state.progress
                      ? const Center(
                    child: CircularProgressIndicator(color: AppTokens.brandGradientStart),
                  )
                      : _ReceiptList(state: state, isTablet: true),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT (40%) — Summary + Stats
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _SummaryCard(state: state, isTablet: true),
                  const SizedBox(height: 16),
                  _StatsPanel(state: state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMobileLayout(BuildContext context, ReceiptState state) {
    return Column(
      children: [
        _FilterCard(state: state, isTablet: false),
        _SummaryCard(state: state, isTablet: false),
        Expanded(
          child: !state.progress
              ? const Center(
            child: CircularProgressIndicator(color: AppTokens.brandGradientStart),
          )
              : _ReceiptList(state: state, isTablet: false),
        ),
      ],
    );
  }
}
class _FilterCard extends StatelessWidget {
  final ReceiptState state;
  final bool isTablet;
  const _FilterCard({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isTablet ? 0 : 16,
        isTablet ? 0 : 16,
        isTablet ? 0 : 16,
        isTablet ? 0 : 8,
      ),
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandGradientStart.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _DateButton(
              label: state.fromDate == null
                  ? 'From Date'
                  : DateFormat('dd MMM yyyy').format(state.fromDate!),
              icon: Icons.calendar_today_rounded,
              isTablet: isTablet,
              onTap: () =>
                  context.read<ReceiptBloc>().pickDate(context, true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DateButton(
              label: state.toDate == null
                  ? 'To Date'
                  : DateFormat('dd MMM yyyy').format(state.toDate!),
              icon: Icons.event_rounded,
              isTablet: isTablet,
              onTap: () =>
                  context.read<ReceiptBloc>().pickDate(context, false),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context
                .read<ReceiptBloc>()
                .add(LoadReceiptEvent(isDateSearch: true)),
            child: Container(
              padding: EdgeInsets.all(isTablet ? 15 : 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTokens.brandGradientStart, AppTokens.brandDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.brandGradientStart.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.search_rounded,
                  color: kWhite, size: isTablet ? 24 : 22),
            ),
          ),
        ],
      ),
    );
  }
}
class _DateButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isTablet;

  const _DateButton({
    required this.label,
    required this.icon,
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
          vertical: isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: kAccent,
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          border: Border.all(color: AppTokens.brandMid.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 6 : 5),
              decoration: BoxDecoration(
                color: AppTokens.brandGradientStart.withOpacity(0.12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: isTablet ? 15 : 13, color: AppTokens.brandGradientStart),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.brandDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _SummaryCard extends StatelessWidget {
  final ReceiptState state;
  final bool isTablet;
  const _SummaryCard({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isTablet ? 0 : 16,
        isTablet ? 0 : 0,
        isTablet ? 0 : 16,
        isTablet ? 0 : 8,
      ),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandGradientStart.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryTile(
            label: 'Total Amount',
            value: 'RM ${state.totalAmount.toStringAsFixed(2)}',
            icon: Icons.account_balance_wallet_rounded,
            iconBg: kWhite.withOpacity(0.2),
            isTablet: isTablet,
          ),
          Container(
            width: 1,
            height: isTablet ? 60 : 50,
            color: kWhite.withOpacity(0.2),
          ),
          _SummaryTile(
            label: 'Outstanding',
            value: 'RM ${state.totalBalance.toStringAsFixed(2)}',
            icon: Icons.warning_amber_rounded,
            iconBg: Colors.red.withOpacity(0.25),
            alignEnd: true,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }
}
class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color valueColor;
  final bool alignEnd;
  final bool isTablet;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.isTablet,
    this.valueColor = kWhite,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!alignEnd) ...[
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: kWhite, size: isTablet ? 16 : 14),
              ),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: GoogleFonts.poppins(
                    color: kWhite.withOpacity(0.7),
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w500)),
            if (alignEnd) ...[
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: kWhite, size: isTablet ? 16 : 14),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                color: valueColor,
                fontSize: isTablet ? 18 : 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
class _StatsPanel extends StatelessWidget {
  final ReceiptState state;
  const _StatsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final total     = state.totalAmount;
    final balance   = state.totalBalance;
    final collected = total - balance;
    final paidCount = state.receiptMaster
        .where((m) =>
    (double.tryParse(m["Balance"].toString()) ?? 0) <= 0)
        .length;
    final pendingCount = state.receiptMaster.length - paidCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandGradientStart.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              width: 4, height: 20,
              decoration: BoxDecoration(
                color: AppTokens.brandGradientStart,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text('Summary',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.brandDark,
                )),
          ]),

          const SizedBox(height: 16),

          // Stat rows
          _statRow('Total Bills',
              '${state.receiptMaster.length}',
              Icons.receipt_long_rounded,
              AppTokens.brandGradientStart),
          const SizedBox(height: 10),
          _statRow('Paid',
              '$paidCount',
              Icons.check_circle_rounded,
              const Color(0xFF059669)),
          const SizedBox(height: 10),
          _statRow('Pending',
              '$pendingCount',
              Icons.pending_rounded,
              const Color(0xFFEA580C)),

          const SizedBox(height: 16),
          Divider(color: kAccent, height: 1),
          const SizedBox(height: 16),

          // Amount rows
          _amountRow('Collected',
              'RM ${collected.toStringAsFixed(2)}',
              const Color(0xFF059669)),
          const SizedBox(height: 10),
          _amountRow('Outstanding',
              'RM ${balance.toStringAsFixed(2)}',
              const Color(0xFFEA580C)),

          const SizedBox(height: 16),

          // Progress bar
          _buildProgressBar(collected, total),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTokens.brandDark,
                fontWeight: FontWeight.w500,
              )),
        ]),
        Text(value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }

  Widget _amountRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTokens.brandDark.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            )),
        Text(value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }

  Widget _buildProgressBar(double collected, double total) {
    final percent = total == 0 ? 0.0 : (collected / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Collection Progress',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTokens.brandDark.withOpacity(0.6),
                )),
            Text('${(percent * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTokens.brandGradientStart,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: kAccent,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTokens.brandGradientStart),
          ),
        ),
      ],
    );
  }
}
class _ReceiptList extends StatelessWidget {
  final ReceiptState state;
  final bool isTablet;
  const _ReceiptList({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 0 : 16,
        4,
        isTablet ? 0 : 16,
        16,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Container(
              width: 4, height: 20,
              decoration: BoxDecoration(
                color: AppTokens.brandGradientStart,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Receipts (${state.receiptMaster.length})',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w700,
                color: AppTokens.brandDark,
              ),
            ),
          ]),
        ),
        ...state.receiptMaster
            .map((m) => _ReceiptCard(data: m, isTablet: isTablet)),
      ],
    );
  }
}
class _ReceiptCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isTablet;
  const _ReceiptCard({required this.data, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    double billAmount =
        double.tryParse(data["BillAmount"].toString()) ?? 0;
    double balance   =
        double.tryParse(data["Balance"].toString()) ?? 0;
    double collected = billAmount - balance;
    bool isPaid      = balance <= 0;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(color: kAccent, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandGradientStart.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["CustomerName"] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.brandDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${data["BillNo"]} • ${data["BillDate"]}',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 12 : 11,
                          color: AppTokens.brandMid.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 14 : 10,
                    vertical: isTablet ? 7 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFFD1FAE5)
                        : kAccent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaid
                          ? const Color(0xFF0F766E).withOpacity(0.3)
                          : AppTokens.brandMid.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    isPaid ? '✓ Paid' : 'Pending',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 12 : 11,
                      fontWeight: FontWeight.w700,
                      color: isPaid
                          ? const Color(0xFF0F766E)
                          : AppTokens.brandGradientStart,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 16 : 14),
            Divider(color: kAccent, height: 1),
            SizedBox(height: isTablet ? 14 : 12),

            // ── Amount Chips
            Row(
              children: [
                Expanded(
                  child: _AmountChip(
                    label: 'Total',
                    amount: 'RM ${billAmount.toStringAsFixed(2)}',
                    color: AppTokens.brandGradientStart,
                    bgColor: RWhite,
                    isTablet: isTablet,
                  ),
                ),
                const SizedBox(width: 8), // Gap between chip 1 and 2
                Expanded(
                  child: _AmountChip(
                    label: 'Collected',
                    amount: 'RM ${collected.toStringAsFixed(2)}',
                    color: AppTokens.brandGradientStart,
                    bgColor: RWhite,
                    isTablet: isTablet,
                  ),
                ),
                const SizedBox(width: 8), // Gap between chip 2 and 3
                Expanded(
                  child: _AmountChip(
                    label: 'Balance',
                    amount: 'RM ${balance.toStringAsFixed(2)}',
                    color: balance > 0
                        ? const Color(0xFF740000)
                        : AppTokens.brandGradientStart,
                    bgColor: balance > 0 // Note: Both conditions evaluate to RWhite here, you might want to check this!
                        ? RWhite
                        : RWhite,
                    isTablet: isTablet,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
class _AmountChip extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final Color bgColor;
  final bool isTablet;

  const _AmountChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Good practice to prevent infinite height issues
        children: [
          Text(
            label,
            maxLines: 1, // Restrict to one line
            overflow: TextOverflow.ellipsis, // Add ellipsis if it shrinks
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 11 : 10,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            amount,
            maxLines: 1, // Restrict to one line
            overflow: TextOverflow.ellipsis, // Add ellipsis if it shrinks
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 13 : 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}