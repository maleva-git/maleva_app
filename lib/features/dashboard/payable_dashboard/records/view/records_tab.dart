import '../../levy/data/levy_api.dart';
import '../../levy/view/levy_form_page.dart';
import '../../pettycash/data/petty_cash_api.dart';
import '../../pettycash/view/petty_cash_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import 'package:maleva/core/files/attachments_api.dart';

import '../../bill/data/bill_api.dart';
import '../../bill/view/bill_form_page.dart';
import '../../po/data/po_api.dart';
import '../../po/view/po_form_page.dart';
import '../../paybill/data/paybill_api.dart';
import '../../paybill/view/paybill_form_page.dart';
import '../../voucher/data/voucher_api.dart';
import '../../voucher/view/voucher_form_page.dart';
import '../bloc/records_cubit.dart';
import '../data/payable_record.dart';
import '../data/payable_records_api.dart';
import 'record_detail_page.dart';
import 'record_style.dart';

/// The payable team's Records tab (change `payable-records`): PO, Bill, Pay bill, Voucher, Petty cash and Levy for a
/// period, searched and filtered by status on the phone; a card opens the record with its lines and files. Read only.
/// Which form to open: a new record of [kind], an edit of [editId], a bill / voucher made from PO [fromPoId], or a
/// pay bill for bill [fromBillId].
class FormRequest {
  const FormRequest(this.kind, {this.editId, this.fromPoId, this.fromBillId});

  final RecordKind kind;
  final int? editId;
  final int? fromPoId;
  final int? fromBillId;
}

/// Opens a form and answers whether something was saved.
typedef OpenForm = Future<bool> Function(BuildContext context, FormRequest request);

/// The kinds that have a form in the app (PO: change `payable-po-create`; bill: `payable-bill-form`; voucher:
/// `payable-voucher-form`).
const formKinds = {
  RecordKind.po,
  RecordKind.bill,
  RecordKind.voucher,
  RecordKind.payBill,
  RecordKind.pettyCash, // change payable-pettycash-form
  RecordKind.levy, // change payable-levy-form
};

/// The new-record button's words per kind.
String newLabel(RecordKind k) => switch (k) {
      RecordKind.po => 'New PO',
      RecordKind.bill => 'New bill',
      RecordKind.voucher => 'New voucher',
      RecordKind.payBill => 'Pay bills',
      RecordKind.pettyCash => 'New petty cash',
      RecordKind.levy => 'New levy',
    };

class RecordsTab extends StatelessWidget {
  const RecordsTab({super.key, this.api, this.cubit, this.openForm});

  /// Tests give their own.
  final PayableRecordsApi? api;
  final RecordsCubit? cubit;
  final OpenForm? openForm;

  static Future<bool> _open(BuildContext context, FormRequest r) async {
    final dio = sl<JavaApiClient>().dio;
    final po = PoApi(dio, companyId: AppPreferences.getComid);
    final files = sl<AttachmentsApi>();
    final Widget page = switch (r.kind) {
      RecordKind.bill => BillFormPage(api: BillApi(dio, po), files: files, editId: r.editId, fromPoId: r.fromPoId),
      RecordKind.voucher =>
        VoucherFormPage(api: VoucherApi(dio, po), files: files, editId: r.editId, fromPoId: r.fromPoId),
      RecordKind.payBill => PayBillFormPage(
          api: PayBillApi(dio, po, VoucherApi(dio, po)), files: files, editId: r.editId, fromBillId: r.fromBillId),
      RecordKind.pettyCash =>
        PettyCashFormPage(api: PettyCashApi(dio, companyId: AppPreferences.getComid()), files: files, editId: r.editId),
      RecordKind.levy =>
        LevyFormPage(api: LevyApi(dio, companyId: AppPreferences.getComid()), files: files, editId: r.editId),
      _ => PoFormPage(api: po, files: files, editId: r.editId),
    };
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => page));
    return saved == true;
  }

  @override
  Widget build(BuildContext context) {
    final a = api ?? PayableRecordsApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid);
    final c = cubit;
    final view = RecordsView(api: a, openForm: openForm ?? _open);
    return c != null
        ? BlocProvider.value(value: c, child: view)
        : BlocProvider(create: (_) => RecordsCubit(a)..load(), child: view);
  }
}

class RecordsView extends StatefulWidget {
  const RecordsView({super.key, required this.api, required this.openForm});

  final PayableRecordsApi api;
  final OpenForm openForm;

  @override
  State<RecordsView> createState() => _RecordsViewState();
}

class _RecordsViewState extends State<RecordsView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickDates(RecordsCubit cubit, RecordsState s) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: DateTimeRange(start: s.from, end: s.to),
    );
    if (picked != null) cubit.chooseDates(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final pad = wide ? 20.0 : 12.0;
    return BlocBuilder<RecordsCubit, RecordsState>(builder: (context, s) {
      final cubit = context.read<RecordsCubit>();
      final shown = s.shown;
      final total = shown.fold<double>(0, (t, r) => t + r.amount);
      final withFiles = shown.where((r) => (s.fileCounts[r.id] ?? 0) > 0).length;
      return Scaffold(
        backgroundColor: AppTokens.surfacePage,
        floatingActionButton: !formKinds.contains(s.kind)
            ? null
            : FloatingActionButton.extended(
                key: ValueKey('records-new-${s.kind.name}'),
                onPressed: () async {
                  if (await widget.openForm(context, FormRequest(s.kind))) cubit.load();
                },
                icon: const Icon(Icons.add),
                label: Text(newLabel(s.kind)),
              ),
        body: Column(children: [
          // ── record type ──
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(pad, 6, pad, 4),
              children: [
                for (final k in RecordKind.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: ValueKey('kind-${k.name}'),
                      selected: s.kind == k,
                      onSelected: (_) {
                        _search.clear();
                        cubit.search('');
                        cubit.chooseKind(k);
                      },
                      avatar:
                          Icon(k.icon, size: 16, color: s.kind == k ? AppTokens.textOnDark : AppTokens.brandPrimary),
                      label: Text(k.label),
                      showCheckmark: false,
                      selectedColor: AppTokens.brandPrimary,
                      labelStyle: AppTypography.bodySmall(
                          color: s.kind == k ? AppTokens.textOnDark : AppTokens.textPrimary,
                          fontWeight: FontWeight.w600),
                      backgroundColor: AppTokens.surfaceCard,
                      side: const BorderSide(color: AppTokens.surfaceBorder),
                    ),
                  ),
              ],
            ),
          ),
          // ── period + search ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(pad, 4, pad, 0),
            child: Row(children: [
              _PeriodChip(
                  text: 'This month',
                  selected: s.period == RecordPeriod.thisMonth,
                  onTap: () => cubit.choosePeriod(RecordPeriod.thisMonth)),
              const SizedBox(width: 6),
              _PeriodChip(
                  text: 'Last month',
                  selected: s.period == RecordPeriod.lastMonth,
                  onTap: () => cubit.choosePeriod(RecordPeriod.lastMonth)),
              const SizedBox(width: 6),
              _PeriodChip(
                  key: const ValueKey('period-dates'),
                  text: s.period == RecordPeriod.custom ? '${_dm(s.from)} – ${_dm(s.to)}' : 'Dates…',
                  icon: Icons.date_range,
                  selected: s.period == RecordPeriod.custom,
                  onTap: () => _pickDates(cubit, s)),
            ]),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
            child: TextField(
              key: const ValueKey('records-search'),
              controller: _search,
              onChanged: cubit.search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search number, supplier, pay to, text',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: s.search.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _search.clear();
                          cubit.search('');
                        }),
                filled: true,
                fillColor: AppTokens.surfaceCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTokens.surfaceBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTokens.surfaceBorder)),
              ),
            ),
          ),
          // ── status chips ──
          if (s.statuses.length > 1)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
                children: [
                  _StatusChip(
                      text: 'All',
                      color: AppTokens.brandPrimary,
                      selected: s.status == null,
                      onTap: () => cubit.chooseStatus(null)),
                  for (final st in s.statuses)
                    _StatusChip(
                      text: st,
                      color: toneColor(statusTone(st == 'Pending' ? '' : st)),
                      selected: s.status == st,
                      onTap: () => cubit.chooseStatus(s.status == st ? null : st),
                    ),
                ],
              ),
            ),
          // ── summary ──
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 6),
            child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(
                  s.loading
                      ? 'Loading…'
                      : '${shown.length} ${s.kind.title.toLowerCase()}${shown.length == 1 ? '' : 's'}',
                  style: AppTypography.bodySmall(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
              if (!s.loading && shown.isNotEmpty) ...[
                Text('  ·  ', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                Text(Fmt.rm(total),
                    key: const ValueKey('records-total'),
                    style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                if (s.fileCounts.isNotEmpty) ...[
                  Text('  ·  ', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                  const Icon(Icons.attach_file, size: 13, color: AppTokens.textMuted),
                  Text('$withFiles', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                ],
              ],
            ]),
          ),
          // ── list ──
          Expanded(
            child: RefreshIndicator(
              onRefresh: cubit.load,
              child: _body(context, s, shown, pad),
            ),
          ),
        ]),
      );
    });
  }

  /// The buttons on a record's page: Edit, Push to Bill and Push to PV (PO), Pay this bill (credit bill).
  List<RecordAction> _actionsFor(PayableRecord r) => [
        if (formKinds.contains(r.kind))
          RecordAction('Edit', Icons.edit_outlined, (ctx) => widget.openForm(ctx, FormRequest(r.kind, editId: r.id))),
        if (r.kind == RecordKind.po) ...[
          RecordAction('Push to Bill', Icons.receipt_long_outlined,
              (ctx) => widget.openForm(ctx, FormRequest(RecordKind.bill, fromPoId: r.id))),
          RecordAction('Push to PV', Icons.request_quote_outlined,
              (ctx) => widget.openForm(ctx, FormRequest(RecordKind.voucher, fromPoId: r.id))),
        ],
        // a cash bill is paid when billed; only a credit bill is paid on the Pay bill screen
        if (r.kind == RecordKind.bill && r.tag.toUpperCase() != 'CASH')
          RecordAction('Pay this bill', Icons.payments_outlined,
              (ctx) => widget.openForm(ctx, FormRequest(RecordKind.payBill, fromBillId: r.id))),
      ];

  Widget _body(BuildContext context, RecordsState s, List<PayableRecord> shown, double pad) {
    if (s.loading && s.records.isEmpty) {
      return ListView(children: const [SizedBox(height: 80), Center(child: CircularProgressIndicator())]);
    }
    if (s.error != null) {
      return ListView(padding: EdgeInsets.all(pad), children: [
        const SizedBox(height: 40),
        const Icon(Icons.cloud_off_outlined, size: 40, color: AppTokens.textMuted),
        const SizedBox(height: 8),
        Text(s.error!, textAlign: TextAlign.center, style: AppTypography.bodySmall(color: Palette.redDanger)),
        const SizedBox(height: 8),
        Center(child: FilledButton(onPressed: context.read<RecordsCubit>().load, child: const Text('Retry'))),
      ]);
    }
    if (shown.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 60),
        Icon(s.kind.icon, size: 40, color: AppTokens.textMuted),
        const SizedBox(height: 8),
        Text(s.records.isEmpty ? 'No ${s.kind.title.toLowerCase()} in these dates' : 'Nothing matches',
            textAlign: TextAlign.center, style: AppTypography.bodyMedium(color: AppTokens.textMuted)),
      ]);
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(pad, 2, pad, formKinds.contains(s.kind) ? 88 : 24),
      itemCount: shown.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _RecordCard(
        record: shown[i],
        files: s.fileCounts[shown[i].id] ?? 0,
        onTap: () async {
          final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
              builder: (_) => RecordDetailPage(record: shown[i], api: widget.api, actions: _actionsFor(shown[i]))));
          if (changed == true && context.mounted) context.read<RecordsCubit>().load();
        },
      ),
    );
  }
}

String _dm(DateTime d) => '${d.day}/${d.month}';

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({super.key, required this.text, required this.selected, required this.onTap, this.icon});

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTokens.brandLight : AppTokens.surfaceCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppTokens.brandPrimary : AppTokens.surfaceBorder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 14, color: AppTokens.brandPrimary), const SizedBox(width: 4)],
            Text(text,
                style: AppTypography.bodySmall(
                    color: selected ? AppTokens.brandPrimary : AppTokens.textPrimary, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.color, required this.selected, required this.onTap});

  final String text;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: selected ? color : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          key: ValueKey('status-$text'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(text,
                style: AppTypography.badgeText(color: selected ? Colors.white : color, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.files, required this.onTap});

  final PayableRecord record;
  final int files;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = record;
    final tone = toneColor(statusTone(r.status));
    return Material(
      color: AppTokens.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTokens.surfaceBorder),
          ),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: tone,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Text(r.party.isEmpty ? r.number : r.party,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Text(Fmt.rm(r.amount),
                          style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 2),
                    Text([r.number, if (r.date != null) Fmt.ddMMyyyy(r.date)].join(' · '),
                        style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                    if (r.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(r.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall(color: AppTokens.textPrimary)),
                      ),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      StatusPill(status: r.status),
                      if (r.tag.isNotEmpty) SoftChip(text: r.tag),
                      if (files > 0) SoftChip(text: '$files', icon: Icons.attach_file),
                      if (r.lineCount > 0) SoftChip(text: '${r.lineCount} lines', icon: Icons.list),
                    ]),
                  ]),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.chevron_right, color: AppTokens.textSecondary),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
