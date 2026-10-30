import 'package:maleva/core/utils/json_read.dart';

import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';
import 'bill_draft.dart';

/// What the AI read from a bill photo.
class BillAiResult {
  const BillAiResult({required this.draft, required this.warnings, required this.candidates});

  final BillDraft draft;
  final List<String> warnings;
  final List<Option> candidates;
}

/// Puts the bill extraction (`BillExtractionResponse`) on a copy of [base], the web's way (`useBillAiReading.ts`):
/// supplier by id (its term, currency and due date then follow the normal supplier choice, the AI's term is not used);
/// invoice no. upper case; dates only when found; expense type only when listed; remarks = the document's or "PO x";
/// lines in upper case, qty 1 by default, rate from the unit price or (amount − tax) ÷ qty; account by id then code.
/// Nothing is saved: the person checks and saves.
BillAiResult applyBillExtraction(Map<String, dynamic> ai, BillDraft base,
    {required List<Option> suppliers, required List<Option> accounts, required List<String> descriptions}) {
  final d = BillDraft(
    id: base.id,
    number: base.number,
    billDate: base.billDate,
    invoiceDate: base.invoiceDate,
    dueDate: base.dueDate,
    saleType: base.saleType,
    status: base.status,
    poId: base.poId,
    poNumber: base.poNumber,
    paymentTermId: base.paymentTermId,
  );
  final warnings = <String>[for (final w in (JsonRead.field(ai, 'warnings') as List? ?? const [])) '$w'];
  Option? byId(List<Option> list, int id) {
    for (final o in list) {
      if (o.id == id) return o;
    }
    return null;
  }

  final sup = JsonRead.map(JsonRead.field(ai, 'supplier'));
  final supplierId = JsonRead.integer(JsonRead.field(sup, 'supplierId'));
  final candidates = <Option>[];
  if (supplierId > 0) {
    d.supplier = byId(suppliers, supplierId) ?? Option(supplierId, pick(sup, const ['extractedName']));
  } else {
    for (final c in JsonRead.listOfMaps(JsonRead.field(sup, 'candidates')).take(3)) {
      final id = JsonRead.integer(JsonRead.field(c, 'id'));
      if (id > 0) candidates.add(byId(suppliers, id) ?? Option(id, pick(c, const ['name'])));
    }
    final name = pick(sup, const ['extractedName']);
    warnings.add(name.isEmpty ? 'Supplier not found: choose it' : 'Supplier "$name" not matched: choose it');
  }

  final h = JsonRead.map(JsonRead.field(ai, 'header'));
  final inv = pick(h, const ['invoiceNo']);
  if (inv.isNotEmpty) d.invoiceNo = inv.toUpperCase();
  final invDate = readDate(pick(h, const ['invoiceDate']));
  if (invDate != null) d.invoiceDate = invDate;
  final billDate = readDate(pick(h, const ['billDate']));
  if (billDate != null) d.billDate = billDate;
  final due = readDate(pick(h, const ['dueDate']));
  if (due != null) d.dueDate = due;
  final desc = pick(h, const ['description']).toUpperCase();
  for (final x in descriptions) {
    if (x.toUpperCase() == desc) d.description = x;
  }
  final poNo = pick(h, const ['purchaseOrderNo']);
  d.remarks = (pick(h, const ['remarks']).isNotEmpty ? pick(h, const ['remarks']) : (poNo.isEmpty ? '' : 'PO $poNo'))
      .toUpperCase();

  Option? account(Map<String, dynamic> l) {
    final id = JsonRead.integer(JsonRead.field(l, 'accountId'));
    if (id > 0) {
      final a = byId(accounts, id);
      if (a != null) return a;
    }
    final code = pick(l, const ['accountCode']).toUpperCase();
    for (final a in accounts) {
      if (code.isNotEmpty && a.sub.toUpperCase().startsWith(code)) return a;
    }
    return null;
  }

  for (final l in JsonRead.listOfMaps(JsonRead.field(ai, 'lines'))) {
    var qty = pickNumber(l, const ['quantity']);
    if (qty <= 0) qty = 1;
    final tax = pickNumber(l, const ['taxAmount']);
    var rate = pickNumber(l, const ['unitPrice']);
    if (rate <= 0) rate = (pickNumber(l, const ['amount']) - tax) / qty;
    var taxPct = pickNumber(l, const ['taxPercent']);
    if (taxPct <= 0 && tax > 0 && qty * rate > 0) taxPct = (tax / (qty * rate) * 100 * 100).roundToDouble() / 100;
    d.lines.add(PoLine(
      account: account(l),
      remarks: pick(l, const ['description']).toUpperCase(),
      qty: qty,
      rate: (rate * 100).roundToDouble() / 100,
      taxPercent: taxPct,
    ));
  }
  final noAccount = d.lines.where((l) => l.account == null).length;
  if (noAccount > 0) warnings.add('$noAccount item${noAccount == 1 ? '' : 's'} without an account: choose it');
  final docTotal = pickNumber(h, const ['totalAmount']);
  if (docTotal > 0 && (docTotal - d.total).abs() > 0.05) {
    warnings
        .add('The bill says RM ${docTotal.toStringAsFixed(2)}; the items add up to RM ${d.total.toStringAsFixed(2)}');
  }
  return BillAiResult(draft: d, warnings: warnings, candidates: candidates);
}
