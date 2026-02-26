import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/colors/colors.dart';
import '../bloc/receiptview_bloc.dart';
import '../bloc/receiptview_event.dart';
import '../bloc/receiptview_state.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceiptBloc, ReceiptState>(
      builder: (context, state) {
        return Container(
          color: const Color(0xFFF0F4FF),
          child: Column(
            children: [
              /// 🔹 TOP FILTER CARD
              _FilterCard(state: state),

              /// 🔹 SUMMARY CARD
              _SummaryCard(state: state),

              /// 🔹 COMPANY LIST
              Expanded(
                child: !state.progress
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4F46E5),
                  ),
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

// ─────────────────────────────────────────
// 🔹 FILTER CARD
// ─────────────────────────────────────────
class _FilterCard extends StatelessWidget {
  final ReceiptState state;
  const _FilterCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
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
            onTap: () {
              context
                  .read<ReceiptBloc>()
                  .add(LoadReceiptEvent(isDateSearch: true));
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.appBarColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B9BD5).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 22),
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
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF5B9BD5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF5B9BD5)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F46E5),
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

// ─────────────────────────────────────────
// 🔹 SUMMARY CARD
// ─────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final ReceiptState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    double collected = state.totalAmount - state.totalBalance;
    double percentage = state.totalAmount > 0
        ? (collected / state.totalAmount).clamp(0.0, 1.0)
        : 0.0;
    int percentInt = (percentage * 100).toInt();

    return
      Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.appBarColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.appBarColor.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// AMOUNT ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryTile(
                label: 'Total Amount',
                value: 'RM ${state.totalAmount.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet_rounded,
                iconBg: Colors.white.withOpacity(0.2),
              ),
              Container(
                  width: 1, height: 50, color: Colors.white.withOpacity(0.2)),
              _SummaryTile(
                label: 'Outstanding',
                value: 'RM ${state.totalBalance.toStringAsFixed(2)}',
                icon: Icons.warning_amber_rounded,
                iconBg: Colors.red.withOpacity(0.25),
                valueColor: const Color(0xFFFFFFFF),
                alignEnd: true,
              ),
            ],
          ),


          const SizedBox(height: 12),

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
    this.valueColor = Colors.white,
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
                    color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            if (alignEnd) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─────────────────────────────────────────
// 🔹 RECEIPT LIST
// ─────────────────────────────────────────
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
                height: 18,
                decoration: BoxDecoration(
                    color: const Color(0xFF5B9BD5),
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 8),
              Text(
                'Receipts (${state.receiptMaster.length})',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1B4B)),
              ),
            ],
          ),
        ),
        ...state.receiptMaster.map((m) => _ReceiptCard(data: m)),
      ],
    );
  }
}

// ─────────────────────────────────────────
// 🔹 RECEIPT CARD
// ─────────────────────────────────────────
class _ReceiptCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ReceiptCard({required this.data});

  @override
  Widget build(BuildContext context) {
    double billAmount = double.tryParse(data["BillAmount"].toString()) ?? 0;
    double balance = double.tryParse(data["Balance"].toString()) ?? 0;
    double collected = billAmount - balance;
    double percentage =
    billAmount > 0 ? (collected / billAmount).clamp(0.0, 1.0) : 0.0;
    bool isPaid = balance <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.07),
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
            /// TOP ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["CustomerName"] ?? '',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1B4B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${data["BillNo"]} • ${data["BillDate"]}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),

                /// STATUS BADGE
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPaid ? '✓ Paid' : 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPaid
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFEA580C),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// AMOUNT CHIPS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AmountChip(
                  label: 'Total',
                  amount: 'RM ${billAmount.toStringAsFixed(2)}',
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFD1FAE5),
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
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFD1FAE5),
                ),
              ],
            ),

            const SizedBox(height: 12),


            /// EMPLOYEE + PERCENTAGE

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

  const _AmountChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(amount,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}