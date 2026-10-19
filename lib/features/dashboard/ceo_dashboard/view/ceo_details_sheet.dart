import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/core/widgets/ui/status_pill.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/overview_widgets.dart';

import '../bloc/ceo_dashboard_cubit.dart';
import '../data/ceo_analytics_models.dart';
import 'ceo_widgets.dart';

/// Opens the list behind a number (the web shows it on hover; a phone has none, so a tap) in a draggable
/// bottom sheet. [label] heads the sheet until the server's title arrives ("FUEL · 5 POs"). [range] is
/// the days asked (default: the chosen period). [invoice] / [customer] narrow sale order and invoice lists.
Future<void> showCeoDetails(
  BuildContext context, {
  required String kind,
  String? keyValue,
  required String label,
  required PanelAccent accent,
  (String, String)? range,
  String? invoice,
  int? customer,
}) {
  final cubit = context.read<CeoDashboardCubit>();
  final r = range ?? cubit.range;
  cubit.loadDetails(kind, keyValue, range: r, invoice: invoice, customer: customer);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, controller) => CeoDetailsSheet(
            kind: kind,
            keyValue: keyValue,
            label: label,
            accent: accent,
            range: r,
            invoice: invoice,
            customer: customer,
            controller: controller),
      ),
    ),
  );
}

class CeoDetailsSheet extends StatelessWidget {
  const CeoDetailsSheet({
    super.key,
    required this.kind,
    required this.keyValue,
    required this.label,
    required this.accent,
    this.range,
    this.controller,
    this.invoice,
    this.customer,
  });

  final String kind;
  final String? keyValue;
  final String label;
  final PanelAccent accent;
  final String? invoice;
  final int? customer;

  /// The days asked; null = the chosen period.
  final (String, String)? range;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CeoDashboardCubit, CeoDashboardState>(builder: (context, _) {
      final cubit = context.read<CeoDashboardCubit>();
      final r = range ?? cubit.range;
      final s = cubit.detailsOf(kind, keyValue, range: r, invoice: invoice, customer: customer);
      final d = s.data;
      final (from, to) = r;
      // a row of a breakdown (customers, employees, suppliers, trucks) opens its own list in the same days
      final drill = ceoDrillOf(kind, invoice: invoice);
      final ranked = drill != null;
      return _SheetFrame(controller: controller, children: [
        _Header(
          title: (d?.title.isNotEmpty ?? false) ? d!.title : label,
          range: '${_dmy(from)} – ${_dmy(to)}',
          details: d,
          accent: accent,
        ),
        const SizedBox(height: 8),
        ..._listBody(
          cubit: cubit,
          kind: kind,
          keyValue: keyValue,
          range: r,
          invoice: invoice,
          customer: customer,
          row: (d, i) => CeoDetailRowTile(
            row: d.rows[i],
            accent: accent,
            last: i == d.rows.length - 1,
            showAmount: d.kind.toUpperCase() != CeoDetailKind.leaveToday,
            rank: ranked,
            onTap: drill != null && drill.allowsRow(d.rows[i])
                ? () => drill.open(context, d.rows[i], accent: accent, range: r)
                : null,
          ),
        ),
      ]);
    });
  }

  static String _dmy(String ymd) {
    final d = DateTime.tryParse(ymd);
    return d == null ? ymd : DateFormat('d MMM yyyy').format(d);
  }
}

/// The sheet's white rounded body with the drag handle, scrolling [children].
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.controller, required this.children});

  final ScrollController? controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppTokens.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                decoration: BoxDecoration(color: Palette.grey500, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            ...children,
            const SizedBox(height: 24),
          ],
        ),
      );
}

/// One details list in a sheet: loading, the server's message with Retry, empty, or [row] for each row
/// and "Showing N of M" when the server sent fewer rows than the count.
List<Widget> _listBody({
  required CeoDashboardCubit cubit,
  required String kind,
  required String? keyValue,
  required (String, String) range,
  required Widget Function(CeoDetails d, int index) row,
  String empty = 'Nothing to show for this period',
  String? invoice,
  int? customer,
}) {
  final s = cubit.detailsOf(kind, keyValue, range: range, invoice: invoice, customer: customer);
  final d = s.data;
  if (d != null && s.error == null) {
    return [
      if (d.rows.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: _Centered(icon: Icons.inbox_outlined, text: empty),
        )
      else
        for (var i = 0; i < d.rows.length; i++) row(d, i),
      if (d.truncated || d.count > d.rows.length)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text('Showing ${ceoCount(d.rows.length)} of ${ceoCount(d.count)}',
              textAlign: TextAlign.center, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        ),
    ];
  }
  if (s.error != null) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          const Icon(Icons.error_outline, color: Palette.rose, size: 28),
          const SizedBox(height: 8),
          Text(s.error!, textAlign: TextAlign.center, style: AppTypography.bodySmall(color: Palette.rose)),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () =>
                cubit.loadDetails(kind, keyValue, range: range, force: true, invoice: invoice, customer: customer),
            child: const Text('Retry'),
          ),
        ]),
      ),
    ];
  }
  return const [
    Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTokens.brandGradientStart)),
      ),
    ),
  ];
}

/// A rank in a small round badge.
class CeoRankBadge extends StatelessWidget {
  const CeoRankBadge({super.key, required this.text, required this.accent});

  final String text;
  final PanelAccent accent;

  @override
  Widget build(BuildContext context) => Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: accent.soft, shape: BoxShape.circle),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Text(text.isEmpty ? '·' : text,
                maxLines: 1, style: AppTypography.badgeText(color: accent.strong, fontWeight: FontWeight.w800)),
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.range, required this.details, required this.accent});

  final String title;
  final String range;
  final CeoDetails? details;
  final PanelAccent accent;

  @override
  Widget build(BuildContext context) {
    final d = details;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.soft, accent.soft.withValues(alpha: 0.35)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.heading2(color: accent.strong, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(range, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        if (d != null) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _Fact(label: 'Count', value: ceoCount(d.count), color: accent.strong)),
            const SizedBox(width: 8),
            // leave rows carry no amount
            if (d.kind.toUpperCase() != CeoDetailKind.leaveToday)
              Expanded(flex: 2, child: _Fact(label: 'Total', value: Fmt.rm(d.total), color: accent.strong))
            else
              const Spacer(flex: 2),
          ]),
        ],
      ]),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(color: AppTokens.surfaceCard, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w700)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, maxLines: 1, style: AppTypography.bodyLarge(color: color, fontWeight: FontWeight.w800)),
          ),
        ]),
      );
}

/// One row of the list: date block, reference, title and line, amount and status.
class CeoDetailRowTile extends StatelessWidget {
  const CeoDetailRowTile({
    super.key,
    required this.row,
    required this.accent,
    required this.last,
    this.showAmount = true,
    this.rank = false,
    this.onTap,
  });

  final CeoDetailRow row;

  /// The reference is a rank (customers list): shown as `#1`.
  final bool rank;
  final VoidCallback? onTap;

  /// False for a list that carries no amounts (leave today).
  final bool showAmount;
  final PanelAccent accent;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(row.date);
    final reference = rank && row.reference.isNotEmpty ? '#${row.reference}' : row.reference;
    final tile = Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppTokens.surfaceBorder))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (date != null)
          DateBlock(day: DateFormat('dd').format(date), month: DateFormat('MMM').format(date), accent: accent)
        else
          LetterAvatar(text: row.title, accent: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (reference.isNotEmpty)
              Text(reference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.badgeText(color: accent.strong, fontWeight: FontWeight.w800)),
            Text(row.title.isEmpty ? '—' : row.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
            if (row.subtitle.isNotEmpty)
              Text(row.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (showAmount)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(Fmt.rm(row.amount),
                    maxLines: 1,
                    style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
              ),
            if (showAmount && row.foreignAmount.isNotEmpty) CeoForeignAmount(row.foreignAmount),
            if (row.status.isNotEmpty) ...[
              if (showAmount) const SizedBox(height: 4),
              StatusPill(row.status),
            ],
          ]),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right_rounded, size: 18, color: Palette.textDim),
        ],
      ]),
    );
    return onTap == null ? tile : InkWell(onTap: onTap, child: tile);
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, size: 32, color: Palette.textDim),
        const SizedBox(height: 8),
        Text(text, textAlign: TextAlign.center, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
      ]);
}

/// Where a row of a breakdown list leads: an employee's or customer's sale orders or invoices, a
/// supplier's or truck's purchase orders. [allowsRow] leaves out rows that cannot be opened (customer 0).
class CeoDrill {
  const CeoDrill({
    required this.kind,
    required this.byCustomer,
    required this.noun,
    this.invoice,
    this.zeroOk = false,
    this.byTitle = false,
  });

  /// The row's title is the key (a payable party has no id).
  final bool byTitle;

  /// The list opened.
  final String kind;

  /// The row id goes in `customer` (else in `key`).
  final bool byCustomer;
  final String noun;
  final String? invoice;

  /// Row 0 ("no employee", "no truck") can be opened.
  final bool zeroOk;

  bool allowsRow(CeoDetailRow row) => byTitle ? row.title.isNotEmpty : (zeroOk ? row.id >= 0 : row.id > 0);

  Future<void> open(BuildContext context, CeoDetailRow row,
          {required PanelAccent accent, required (String, String) range}) =>
      showCeoDetails(
        context,
        kind: kind,
        keyValue: byCustomer ? null : (byTitle ? row.title : '${row.id}'),
        customer: byCustomer ? row.id : null,
        invoice: invoice,
        label: '${row.title.isEmpty ? '#${row.id}' : row.title} · $noun',
        accent: accent,
        range: range,
      );
}

/// The drill of a breakdown [kind], or null when its rows are the documents themselves. The customers
/// list keeps opening `TOP_CUSTOMER` without an invoice filter (as before), and the customer's
/// `SALE_ORDERS` with one, so the filter carries on.
CeoDrill? ceoDrillOf(String kind, {String? invoice}) => switch (kind.toUpperCase()) {
      CeoDetailKind.customers => invoice == null
          ? const CeoDrill(kind: CeoDetailKind.topCustomer, byCustomer: false, noun: 'sale orders')
          : CeoDrill(kind: CeoDetailKind.saleOrders, byCustomer: true, noun: 'sale orders', invoice: invoice),
      CeoDetailKind.saleOrderEmployees =>
        CeoDrill(kind: CeoDetailKind.saleOrders, byCustomer: false, noun: 'sale orders', invoice: invoice, zeroOk: true),
      CeoDetailKind.invoiceCustomers => const CeoDrill(kind: CeoDetailKind.invoices, byCustomer: true, noun: 'invoices'),
      CeoDetailKind.invoiceEmployees =>
        const CeoDrill(kind: CeoDetailKind.invoices, byCustomer: false, noun: 'invoices', zeroOk: true),
      CeoDetailKind.poSuppliers => const CeoDrill(kind: CeoDetailKind.poSupplier, byCustomer: false, noun: 'purchase orders'),
      CeoDetailKind.poTrucks =>
        const CeoDrill(kind: CeoDetailKind.poTruck, byCustomer: false, noun: 'purchase orders', zeroOk: true),
      CeoDetailKind.fuelTrucks =>
        const CeoDrill(kind: CeoDetailKind.fuelEntries, byCustomer: false, noun: 'fuel entries', zeroOk: true),
      CeoDetailKind.receivableCustomers =>
        const CeoDrill(kind: CeoDetailKind.receivableCustomer, byCustomer: false, noun: 'unpaid invoices'),
      CeoDetailKind.payableParties =>
        const CeoDrill(kind: CeoDetailKind.payableParty, byCustomer: false, noun: 'what we owe', byTitle: true),
      _ => null,
    };
