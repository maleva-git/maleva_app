import 'package:maleva/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/colors/colors.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/theme/tokens.dart';
import '../bloc/receiptview_bloc.dart';
import '../bloc/receiptview_event.dart';
import '../bloc/receiptview_state.dart';


String _fmtAmount(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final whole = parts[0];
  final dec = parts.length > 1 ? '.' + parts[1] : '';
  if (whole.length <= 3) return s;
  final last3 = whole.substring(whole.length - 3);
  final rest = whole.substring(0, whole.length - 3);
  final buf = StringBuffer();
  for (int i = 0; i < rest.length; i++) {
    if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
    buf.write(rest[i]);
  }
  return '${buf.toString()},$last3$dec';
}

class ReceiptTab extends StatelessWidget {
  const ReceiptTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReceiptBloc>()
        ..add( LoadReceiptEvent()),
      child: const ReceiptPage(),
    );
  }
}

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !context.mounted) return;

    if (isFrom) {
      context.read<ReceiptBloc>().add(SelectFromDateEvent(picked));
    } else {
      context.read<ReceiptBloc>().add(SelectToDateEvent(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocListener<ReceiptBloc, ReceiptState>(
      listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: colour.commonColorred,
            ),
          );
        }
      },
      child: BlocBuilder<ReceiptBloc, ReceiptState>(
        // Only rebuild when status or data changes — not on date selection alone
        buildWhen: (prev, curr) =>
        prev.status != curr.status ||
            prev.receiptMaster.length != curr.receiptMaster.length ||
            prev.totalAmount != curr.totalAmount,
        builder: (context, state) {
          return Container(
            color: const Color(0xFFF4F6FF),
            child: isTablet
                ? _buildTabletLayout(context, state)
                : _buildMobileLayout(context, state),
          );
        },
      ),
    );
  }

  // ── TABLET ──────────────────────────────────────────────────
  Widget _buildTabletLayout(BuildContext context, ReceiptState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(children: [
              _FilterCard(
                state: state,
                isTablet: true,
                onFromTap: () => _pickDate(context, true),
                onToTap:   () => _pickDate(context, false),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: AppTokens.brandGradientStart,
                  ),
                )
                    : _ReceiptList(state: state, isTablet: true),
              ),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
                _SummaryCard(state: state, isTablet: true),
                const SizedBox(height: 16),
                _StatsPanel(state: state),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── MOBILE ──────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, ReceiptState state) {
    return Column(children: [
      _FilterCard(
        state: state,
        isTablet: false,
        onFromTap: () => _pickDate(context, true),
        onToTap:   () => _pickDate(context, false),
      ),
      _SummaryCard(state: state, isTablet: false),
      Expanded(
        child: state.isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: AppTokens.brandGradientStart,
          ),
        )
            : _ReceiptList(state: state, isTablet: false),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// FILTER CARD
// ══════════════════════════════════════════════════════════════
class _FilterCard extends StatelessWidget {
  final ReceiptState state;
  final bool isTablet;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  const _FilterCard({
    required this.state,
    required this.isTablet,
    required this.onFromTap,
    required this.onToTap,
  });

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
            color: AppTokens.brandGradientStart.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: _DateButton(
            label: state.fromDate == null
                ? 'From Date'
                : DateFormat('dd MMM yyyy').format(state.fromDate!),
            icon: Icons.calendar_today_rounded,
            isTablet: isTablet,
            onTap: onFromTap,   // ✅ callback from view — no context in BLoC
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
            onTap: onToTap,     // ✅ callback from view
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => context
              .read<ReceiptBloc>()
              .add( LoadReceiptEvent(isDateSearch: true)),
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
                  color: AppTokens.brandGradientStart.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.search_rounded,
                color: kWhite, size: isTablet ? 24 : 22),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DATE BUTTON
// ══════════════════════════════════════════════════════════════
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
          border: Border.all(color: AppTokens.brandMid.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 6 : 5),
            decoration: BoxDecoration(
              color: AppTokens.brandGradientStart.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon,
                size: isTablet ? 15 : 13,
                color: AppTokens.brandGradientStart),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: AppTypography.bodySmall(color: AppTokens.brandDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SUMMARY CARD
// ══════════════════════════════════════════════════════════════
class _SummaryCard extends StatelessWidget {
  final ReceiptState state;
  final bool isTablet;
  const _SummaryCard({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isTablet ? 0 : 16, 0, isTablet ? 0 : 16, isTablet ? 0 : 8,
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
            color: AppTokens.brandGradientStart.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _SummaryTile(
              label: 'Total Amount',
              value: 'RM ${_fmtAmount(state.totalAmount)}',
              icon: Icons.account_balance_wallet_rounded,
              iconBg: kWhite.withValues(alpha: 0.2),
              isTablet: isTablet,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(width: 1, height: isTablet ? 60 : 50,
                color: kWhite.withValues(alpha: 0.2)),
          ),
          Expanded(
            child: _SummaryTile(
              label: 'Outstanding',
              value: 'RM ${_fmtAmount(state.totalBalance)}',
              icon: Icons.warning_amber_rounded,
              iconBg: colour.commonColorred.withValues(alpha: 0.25),
              alignEnd: true,
              isTablet: isTablet,
            ),
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
  final bool alignEnd;
  final bool isTablet;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.isTablet,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
          if (!alignEnd) ...[
            Container(
              padding: EdgeInsets.all(isTablet ? 8 : 6),
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: kWhite, size: isTablet ? 16 : 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(label,
                style: AppTypography.bodySmall(color: kWhite.withValues(alpha: 0.7)),
                overflow: TextOverflow.ellipsis),
          ),
          if (alignEnd) ...[
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.all(isTablet ? 8 : 6),
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: kWhite, size: isTablet ? 16 : 14),
            ),
          ],
        ]),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(value,
              style: AppTypography.heading1(color: kWhite)),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STATS PANEL
// ══════════════════════════════════════════════════════════════
class _StatsPanel extends StatelessWidget {
  final ReceiptState state;
  const _StatsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final total     = state.totalAmount;
    final balance   = state.totalBalance;
    final collected = total - balance;
    final paidCount = state.receiptMaster
        .where((m) => (double.tryParse(m['Balance'].toString()) ?? 0) <= 0)
        .length;
    final pendingCount = state.receiptMaster.length - paidCount;
    final percent = total == 0 ? 0.0 : (collected / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandGradientStart.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                style: AppTypography.heading2(color: AppTokens.brandDark)),
          ]),
          const SizedBox(height: 16),
          _statRow('Total Bills',    '${state.receiptMaster.length}',
              Icons.receipt_long_rounded,  AppTokens.brandGradientStart),
          const SizedBox(height: 10),
          _statRow('Paid',           '$paidCount',
              Icons.check_circle_rounded,  const Color(0xFF059669)),
          const SizedBox(height: 10),
          _statRow('Pending',        '$pendingCount',
              Icons.pending_rounded,       const Color(0xFFEA580C)),
          const SizedBox(height: 16),
          const Divider(color: kAccent, height: 1),
          const SizedBox(height: 16),
          _amountRow('Collected',  'RM ${_fmtAmount(collected)}',
              const Color(0xFF059669)),
          const SizedBox(height: 10),
          _amountRow('Outstanding','RM ${_fmtAmount(balance)}',
              const Color(0xFFEA580C)),
          const SizedBox(height: 16),
          // Progress bar
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Collection Progress',
                style: AppTypography.bodySmall(color: AppTokens.brandDark.withValues(alpha: 0.6))),
            Text('${(percent * 100).toStringAsFixed(1)}%',
                style: AppTypography.bodySmall(color: AppTokens.brandGradientStart)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: kAccent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTokens.brandGradientStart),
            ),
          ),
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
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: AppTypography.bodyLarge(color: AppTokens.brandDark)),
        ]),
        Text(value,
            style: AppTypography.heading2(color: color)),
      ],
    );
  }

  Widget _amountRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.bodySmall(color: AppTokens.brandDark.withValues(alpha: 0.6))),
        Text(value,
            style: AppTypography.bodyLarge(color: color)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// RECEIPT LIST — ListView.builder (was ListView + .map())
// ══════════════════════════════════════════════════════════════
class _ReceiptList extends StatelessWidget {
  final ReceiptState state;
  final bool isTablet;
  const _ReceiptList({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    if (state.receiptMaster.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No receipts found',
                style: AppTypography.bodyLarge()),
          ],
        ),
      );
    }

    return ListView.builder(
      // ✅ builder — only visible items rendered, memory efficient
      padding: EdgeInsets.fromLTRB(
          isTablet ? 0 : 16, 4, isTablet ? 0 : 16, 16),
      itemCount: state.receiptMaster.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
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
                style: AppTypography.heading2(color: AppTokens.brandDark),
              ),
            ]),
          );
        }
        return _ReceiptCard(
          data: state.receiptMaster[index - 1],
          isTablet: isTablet,
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// RECEIPT CARD
// ══════════════════════════════════════════════════════════════
class _ReceiptCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isTablet;
  const _ReceiptCard({required this.data, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final billAmount = double.tryParse(data['BillAmount'].toString()) ?? 0;
    final balance    = double.tryParse(data['Balance'].toString())    ?? 0;
    final collected  = billAmount - balance;
    final isPaid     = balance <= 0;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(color: kAccent, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandGradientStart.withValues(alpha: 0.07),
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
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['CustomerName'] ?? '',
                          style: AppTypography.heading2(color: AppTokens.brandDark),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text('${data['BillNo']} • ${data['BillDate']}',
                          style: AppTypography.bodySmall(color: AppTokens.brandMid.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 14 : 10,
                    vertical:   isTablet ? 7  : 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFFD1FAE5) : kAccent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaid
                          ? const Color(0xFF0F766E).withValues(alpha: 0.3)
                          : AppTokens.brandMid.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    isPaid ? '✓ Paid' : 'Pending',
                    style: AppTypography.bodySmall(color: isPaid
                          ? const Color(0xFF0F766E)
                          : AppTokens.brandGradientStart),
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 16 : 14),
            const Divider(color: kAccent, height: 1),
            SizedBox(height: isTablet ? 14 : 12),

            // Amount chips
            Row(children: [
              Expanded(
                child: _AmountChip(
                  label: 'Total',
                  amount: 'RM ${_fmtAmount(billAmount)}',
                  color: AppTokens.brandGradientStart,
                  isTablet: isTablet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AmountChip(
                  label: 'Collected',
                  amount: 'RM ${_fmtAmount(collected)}',
                  color: AppTokens.brandGradientStart,
                  isTablet: isTablet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AmountChip(
                  label: 'Balance',
                  amount: 'RM ${_fmtAmount(balance)}',
                  color: balance > 0
                      ? const Color(0xFF740000)
                      : AppTokens.brandGradientStart,
                  isTablet: isTablet,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AMOUNT CHIP — fixed RWhite bug → kWhite
// ══════════════════════════════════════════════════════════════
class _AmountChip extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final bool isTablet;

  const _AmountChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical:   isTablet ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: kWhite,  // ✅ fixed: was RWhite (undefined)
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(color: color.withValues(alpha: 0.7))),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(amount,
                style: AppTypography.bodySmall(color: color)),
          ),
        ],
      ),
    );
  }
}