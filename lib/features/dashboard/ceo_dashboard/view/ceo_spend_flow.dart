import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/overview_widgets.dart';

import '../bloc/ceo_dashboard_cubit.dart';
import '../data/ceo_analytics_models.dart';
import 'ceo_details_sheet.dart';
import 'ceo_tab_kit.dart';
import 'ceo_widgets.dart';

/// The screen a paid line was entered on, in the users' words (web `model/spendGroups.ts`).
enum CeoPaidScreen {
  payment('Payment (pay bill)', Icons.payments_rounded),
  voucher('Payment Voucher', Icons.receipt_rounded),
  cashBill('Cash bill', Icons.point_of_sale_rounded);

  const CeoPaidScreen(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Payment = `SUPPLIER_PAYMENTS`; Cash bill = `CASH_BILLS`; Payment Voucher = the rest (for a PO, or opened
  /// directly by type: hire purchase, tenancy, salary…).
  static CeoPaidScreen of(CeoSpendPart part) => switch (part.key.toUpperCase()) {
        'SUPPLIER_PAYMENTS' => CeoPaidScreen.payment,
        'CASH_BILLS' => CeoPaidScreen.cashBill,
        _ => CeoPaidScreen.voucher,
      };
}

/// A paid line's own label under its screen: "Supplier bills", "Paid when billed", "For a PO" or the
/// voucher type.
String ceoPaidLineLabel(CeoSpendPart part) => switch (part.key.toUpperCase()) {
      'SUPPLIER_PAYMENTS' => 'Supplier bills',
      'CASH_BILLS' => 'Paid when billed',
      'PO_VOUCHERS' => 'For a PO',
      _ => part.name.isEmpty ? part.key.replaceFirst(RegExp('^DIRECT:', caseSensitive: false), '') : part.name,
    };

/// The paid money per screen.
Map<CeoPaidScreen, double> ceoPaidByScreen(List<CeoSpendPart> parts) {
  final totals = {for (final s in CeoPaidScreen.values) s: 0.0};
  for (final p in parts) {
    totals[CeoPaidScreen.of(p)] = totals[CeoPaidScreen.of(p)]! + p.amount;
  }
  return totals;
}

const _approvedColor = Color(0xFF10B981);
const _waitingColor = Color(0xFFF59E0B);
const _alertColor = Color(0xFFE11D48);

/// The money flow of the CEO period (`/spend`): four stages, where the paid money went by screen, the
/// checks (money entered twice, counted once), and "How is this counted?".
class CeoSpendFlowView extends StatelessWidget {
  const CeoSpendFlowView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<CeoDashboardCubit, CeoDashboardState>(builder: (context, _) {
        final cubit = context.read<CeoDashboardCubit>();
        final range = cubit.range;
        if (!cubit.hasSpend(range: range)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!cubit.isClosed) cubit.loadSpend(range: range);
          });
        }
        final s = cubit.spendOf(range: range);
        final f = s.data;
        if (f == null) {
          return s.error != null
              ? CeoErrorBox(message: s.error!, onRetry: () => cubit.loadSpend(range: range, force: true))
              : const CeoSpinner();
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('ceo_spend_help'),
              onPressed: () => showCeoSpendHelp(context),
              icon: const Icon(Icons.help_outline_rounded, size: 16),
              label: const Text('How is this counted?'),
            ),
          ),
          _Stages(flow: f),
          const SizedBox(height: 12),
          _PaidByScreen(flow: f),
          const SizedBox(height: 12),
          _Checks(flow: f),
          if (f.unavailable.isNotEmpty) ...[
            const SizedBox(height: 10),
            CeoUnavailableNote(parts: [
              for (final u in f.unavailable) u == 'spend.monthlyDues' ? 'monthly dues (needs the payable update)' : u,
            ]),
          ],
        ]);
      });
}

/// Purchase Order → Bill → Paid out → Still owed today, as cards joined by arrows.
class _Stages extends StatelessWidget {
  const _Stages({required this.flow});

  final CeoSpendFlow flow;

  @override
  Widget build(BuildContext context) {
    final f = flow;
    final screens = ceoPaidByScreen(f.paidParts);
    const accent = CeoAccent.expenses;
    void open(String kind, String label, PanelAccent a) => showCeoDetails(context, kind: kind, label: label, accent: a);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _StageCard(
        key: const Key('ceo_stage_po'),
        step: '1',
        title: 'Purchase Order',
        icon: Icons.assignment_rounded,
        color: const Color(0xFF6366F1),
        value: Fmt.rm(f.ordered.amount),
        sub: '${ceoCount(f.ordered.count)} purchase orders',
        lines: [('Not billed or paid yet', '${ceoCount(f.orderedOpen.count)} · ${Fmt.rm(f.orderedOpen.amount)}')],
        onTap: () => open(CeoDetailKind.poOpen, 'Purchase orders not billed or paid', PanelAccent.indigo),
      ),
      const _Arrow(),
      _StageCard(
        key: const Key('ceo_stage_bill'),
        step: '2',
        title: 'Bill',
        icon: Icons.description_rounded,
        color: const Color(0xFF0EA5E9),
        value: Fmt.rm(f.billed.amount),
        sub: '${ceoCount(f.billed.count)} bills',
        lines: [
          ('Cash bills', Fmt.rm(f.billedCash)),
          ('Without a PO', Fmt.rm(f.billedWithoutPo)),
        ],
      ),
      const _Arrow(),
      _StageCard(
        key: const Key('ceo_stage_paid'),
        step: '3',
        title: 'Paid out',
        icon: Icons.account_balance_wallet_rounded,
        color: _approvedColor,
        value: Fmt.rm(f.paid.amount),
        sub: '${ceoCount(f.paid.count)} payments',
        lines: [
          for (final s in CeoPaidScreen.values) (s.label, Fmt.rm(screens[s] ?? 0)),
        ],
        footer: _ApprovalBar(approved: f.paid.approved, waiting: f.paid.waiting),
      ),
      const _Arrow(),
      _StageCard(
        key: const Key('ceo_stage_owed'),
        step: '4',
        title: 'Still owed today',
        icon: Icons.account_balance_rounded,
        color: _alertColor,
        value: Fmt.rm(f.stillOwed),
        sub: 'bills + monthly dues',
        lines: const [],
        footer: Column(children: [
          _TapLine(
            key: const Key('ceo_owed_bills'),
            label: 'Credit bills not fully paid',
            value: '${ceoCount(f.owed.count)} · ${Fmt.rm(f.owed.amount)}',
            onTap: () => open(CeoDetailKind.billsOutstanding, 'Credit bills still owing', accent),
          ),
          _TapLine(
            key: const Key('ceo_owed_dues'),
            label: 'Monthly dues (hire purchase, tenancy…)',
            value: '${ceoCount(f.monthlyDues.count)} · ${Fmt.rm(f.monthlyDues.amount)}',
            onTap: () => open(CeoDetailKind.monthlyDues, 'Monthly dues not yet paid', accent),
          ),
        ]),
      ),
    ]);
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    super.key,
    required this.step,
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.sub,
    required this.lines,
    this.footer,
    this.onTap,
  });

  final String step;
  final String title;
  final IconData icon;
  final Color color;
  final String value;
  final String sub;
  final List<(String, String)> lines;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration:
                              BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                          child: Icon(icon, size: 17, color: color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('STEP $step',
                                style: AppTypography.badgeText(color: color, fontWeight: FontWeight.w800)),
                            Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
                          ]),
                        ),
                        Flexible(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(value,
                                  maxLines: 1,
                                  style: AppTypography.heading2(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
                            ),
                            Text(sub,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                        if (onTap != null) const Icon(Icons.chevron_right_rounded, size: 18, color: Palette.textDim),
                      ]),
                      if (lines.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        for (final l in lines)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.6), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(l.$1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                              ),
                              Text(l.$2,
                                  style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                            ]),
                          ),
                      ],
                      if (footer != null) ...[const SizedBox(height: 8), footer!],
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 22,
        child: Center(child: Icon(Icons.keyboard_double_arrow_down_rounded, size: 20, color: Palette.textDim)),
      );
}

/// Approved (green) and waiting for approval (amber) as one bar with the two amounts.
class _ApprovalBar extends StatelessWidget {
  const _ApprovalBar({required this.approved, required this.waiting});

  final double approved;
  final double waiting;

  @override
  Widget build(BuildContext context) {
    final total = approved + waiting;
    final a = total <= 0 ? 0 : (approved / total * 1000).round();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 8,
          child: total <= 0
              ? const ColoredBox(color: AppTokens.surfaceBorder)
              : Row(children: [
                  if (a > 0) Expanded(flex: a, child: const ColoredBox(color: _approvedColor)),
                  if (1000 - a > 0) Expanded(flex: 1000 - a, child: const ColoredBox(color: _waitingColor)),
                ]),
        ),
      ),
      const SizedBox(height: 5),
      Row(children: [
        _dot(_approvedColor),
        Expanded(
          child: Text('Approved ${Fmt.rm(approved)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.badgeText(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
        ),
        _dot(_waitingColor),
        Flexible(
          child: Text('Waiting ${Fmt.rm(waiting)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.badgeText(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
        ),
      ]),
    ]);
  }

  static Widget _dot(Color c) => Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _TapLine extends StatelessWidget {
  const _TapLine({super.key, required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ),
            Text(value, style: AppTypography.bodySmall(color: _alertColor, fontWeight: FontWeight.w800)),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Palette.textDim),
          ]),
        ),
      );
}

/// Where the paid money went, under the screen it was entered on.
class _PaidByScreen extends StatelessWidget {
  const _PaidByScreen({required this.flow});

  final CeoSpendFlow flow;

  @override
  Widget build(BuildContext context) {
    final f = flow;
    final totals = ceoPaidByScreen(f.paidParts);
    final top = f.paidParts.fold<double>(0, (a, p) => p.amount > a ? p.amount : a);
    const accent = PanelAccent.emerald;
    return AccentPanel(
      title: 'Where the paid money went',
      subtitle: '${Fmt.rm(f.paid.amount)} · by the screen it was entered on',
      icon: Icons.account_tree_rounded,
      accent: accent,
      child: f.paidParts.isEmpty
          ? const CeoEmpty(text: 'Nothing paid in this period')
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final screen in CeoPaidScreen.values)
                if (f.paidParts.any((p) => CeoPaidScreen.of(p) == screen)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 2),
                    child: Row(children: [
                      Icon(screen.icon, size: 15, color: accent.strong),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(screen.label.toUpperCase(),
                            style: AppTypography.badgeText(color: accent.strong, fontWeight: FontWeight.w800)),
                      ),
                      Text(Fmt.rm(totals[screen] ?? 0),
                          style: AppTypography.bodySmall(color: accent.strong, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  for (final part in f.paidParts.where((p) => CeoPaidScreen.of(p) == screen))
                    RankRow(
                      key: Key('ceo_paid_${part.key}'),
                      title: ceoPaidLineLabel(part),
                      subtitle: '${ceoCount(part.count)} paid'
                          '${part.waiting > 0 ? ' · ${Fmt.rm(part.waiting)} waiting' : ''}',
                      value: Fmt.rm(part.amount),
                      fraction: top <= 0 ? 0 : part.amount / top,
                      color: part.isDirect ? const Color(0xFF8B5CF6) : accent.end,
                      onTap: () => showCeoDetails(context,
                          kind: CeoDetailKind.spendPart,
                          keyValue: part.key,
                          label: '${screen.label} · ${ceoPaidLineLabel(part)}',
                          accent: accent),
                    ),
                ],
            ]),
    );
  }
}

/// Money that looks entered twice; it is counted once in Paid out and listed here to check.
class _Checks extends StatelessWidget {
  const _Checks({required this.flow});

  final CeoSpendFlow flow;

  @override
  Widget build(BuildContext context) {
    final checks = flow.checks;
    const accent = PanelAccent.rose;
    return AccentPanel(
      title: 'Check these',
      subtitle: checks.isEmpty ? 'No double entries found' : 'Possible duplicates · counted once in Paid out',
      icon: checks.isEmpty ? Icons.verified_rounded : Icons.warning_amber_rounded,
      accent: checks.isEmpty ? PanelAccent.green : accent,
      child: checks.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: _approvedColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Every payment in this period was entered once.',
                      style: AppTypography.bodySmall(color: AppTokens.textPrimary)),
                ),
              ]),
            )
          : Column(children: [
              for (final c in checks)
                InkWell(
                  key: Key('ceo_check_${c.key}'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => showCeoDetails(context,
                      kind: CeoDetailKind.spendCheck, keyValue: c.key, label: c.name, accent: accent),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: accent.soft, shape: BoxShape.circle),
                        child: Text(ceoCount(c.count),
                            style: AppTypography.badgeText(color: accent.strong, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(c.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                      ),
                      Text(Fmt.rm(c.amount), style: AppTypography.bodySmall(color: accent.strong, fontWeight: FontWeight.w800)),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: Palette.textDim),
                    ]),
                  ),
                ),
            ]),
    );
  }
}

/// "How is this counted?": the money flow in plain words (web `SpendHelp.tsx`).
Future<void> showCeoSpendHelp(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(
            color: AppTokens.surfaceCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: ListView(controller: controller, padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Palette.grey500, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            Text('How is this counted?',
                style: AppTypography.heading2(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Purchase Order → Bill → Payment → Payment Voucher, each payment counted once.',
                style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 12),
            for (final item in ceoSpendHelpItems) _HelpItem(icon: item.$1, title: item.$2, text: item.$3),
          ]),
        ),
      ),
    );

/// The explanation, step by step.
const ceoSpendHelpItems = <(IconData, String, String)>[
  (
    Icons.assignment_rounded,
    '1 Purchase Order',
    'What was ordered from suppliers in the period. No money has left yet. "Not billed or paid yet" = POs '
        'with no Bill and no Payment Voucher.'
  ),
  (
    Icons.description_rounded,
    '2 Bill',
    "The supplier's bill, entered on the Bill screen (from a PO or without one). Credit bills are paid later "
        'on the Payment screen; cash bills are paid when billed.'
  ),
  (
    Icons.account_balance_wallet_rounded,
    '3 Paid out',
    'Money that left the company, from three screens: Payment (pay bill), Payment Voucher (for a PO, or opened '
        'directly for hire purchase, tenancy, salary…) and Cash bill. Rejected payments are not counted. '
        'Green = approved, amber = waiting for approval.'
  ),
  (
    Icons.verified_user_rounded,
    'Each payment counted once',
    'If a PO was paid on the Payment screen and also by a Payment Voucher, the voucher is not added again: it '
        'is listed under "Check these" with the other possible duplicates (same PO billed twice, same Pay To + '
        'amount + day, bill paid more than its amount).'
  ),
  (
    Icons.account_balance_rounded,
    '4 Still owed today',
    'Credit bills not fully paid on the Payment screen, plus monthly dues (hire purchase, tenancy…) that are '
        'due and not yet paid by a Payment Voucher.'
  ),
];

class _HelpItem extends StatelessWidget {
  const _HelpItem({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTokens.surfaceBorder),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: PanelAccent.indigo.soft, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 18, color: PanelAccent.indigo.strong),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(text, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ]),
          ),
        ]),
      );
}
