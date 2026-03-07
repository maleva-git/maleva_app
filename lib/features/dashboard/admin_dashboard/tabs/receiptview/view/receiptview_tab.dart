import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/colors/colors.dart';
import '../bloc/receiptview_bloc.dart';
import '../bloc/receiptview_event.dart';
import '../bloc/receiptview_state.dart';

// ─── Color Palette ─────────────────────────────────────────────────────────────

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceiptBloc, ReceiptState>(
      builder: (context, state) {
        return Container(
          color: const Color(0xFFF4F6FF),
          child: Column(
            children: [
              _FilterCard(state: state),
              _SummaryCard(state: state),
              Expanded(
                child: !state.progress
                    ? const Center(
                  child: CircularProgressIndicator(color: kPrimary),
                )
                    : _ReceiptList(state: state),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Filter Card ──────────────────────────────────────────────────────────────
class _FilterCard extends StatelessWidget {
  final ReceiptState state;
  const _FilterCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.08),
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
              onTap: () => context.read<ReceiptBloc>().pickDate(context, true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DateButton(
              label: state.toDate == null
                  ? 'To Date'
                  : DateFormat('dd MMM yyyy').format(state.toDate!),
              icon: Icons.event_rounded,
              onTap: () => context.read<ReceiptBloc>().pickDate(context, false),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context
                .read<ReceiptBloc>()
                .add(LoadReceiptEvent(isDateSearch: true)),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, kPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.search_rounded,
                  color: kWhite, size: 22),
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

  const _DateButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kAccent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryLight.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 13, color: kPrimary),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryDark,
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

// ─── Summary Card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final ReceiptState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.4),
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
          ),
          Container(
            width: 1,
            height: 50,
            color: kWhite.withOpacity(0.2),
          ),
          _SummaryTile(
            label: 'Outstanding',
            value: 'RM ${state.totalBalance.toStringAsFixed(2)}',
            icon: Icons.warning_amber_rounded,
            iconBg: Colors.red.withOpacity(0.25),
            alignEnd: true,
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

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: kWhite, size: 14),
              ),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: GoogleFonts.poppins(
                    color: kWhite.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            if (alignEnd) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: kWhite, size: 14),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─── Receipt List ─────────────────────────────────────────────────────────────
class _ReceiptList extends StatelessWidget {
  final ReceiptState state;
  const _ReceiptList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Receipts (${state.receiptMaster.length})',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryDark,
                ),
              ),
            ],
          ),
        ),
        ...state.receiptMaster.map((m) => _ReceiptCard(data: m)),
      ],
    );
  }
}

// ─── Receipt Card ─────────────────────────────────────────────────────────────
class _ReceiptCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ReceiptCard({required this.data});

  @override
  Widget build(BuildContext context) {
    double billAmount = double.tryParse(data["BillAmount"].toString()) ?? 0;
    double balance    = double.tryParse(data["Balance"].toString()) ?? 0;
    double collected  = billAmount - balance;
    bool isPaid       = balance <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row ──────────────────────────────────────────────────────
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${data["BillNo"]} • ${data["BillDate"]}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: kPrimaryLight.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Status Badge ──────────────────────────────────────────
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFFD1FAE5)
                        : kAccent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaid
                          ? const Color(0xFF0F766E).withOpacity(0.3)
                          : kPrimaryLight.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    isPaid ? '✓ Paid' : 'Pending',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPaid
                          ? const Color(0xFF0F766E)
                          : kPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: kAccent, height: 1),
            const SizedBox(height: 12),

            // ── Amount Chips ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AmountChip(
                  label: 'Total',
                  amount: 'RM ${billAmount.toStringAsFixed(2)}',
                  color: kPrimary,
                  bgColor: kAccent,
                ),
                _AmountChip(
                  label: 'Collected',
                  amount: 'RM ${collected.toStringAsFixed(2)}',
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFD1FAE5),
                ),
                _AmountChip(
                  label: 'Balance',
                  amount: 'RM ${balance.toStringAsFixed(2)}',
                  color: balance > 0 ? const Color(0xFFEA580C) : kPrimary,
                  bgColor: balance > 0
                      ? const Color(0xFFFEE2E2)
                      : kAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Amount Chip ──────────────────────────────────────────────────────────────
class _AmountChip extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final Color bgColor;

  const _AmountChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(amount,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}