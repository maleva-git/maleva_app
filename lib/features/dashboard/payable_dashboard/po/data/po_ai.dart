import 'package:maleva/core/utils/json_read.dart';

import '../../records/data/payable_record.dart';
import 'po_draft.dart';

/// What the AI read: the filled draft, warnings to show, and supplier candidates when none matched.
class PoAiResult {
  const PoAiResult({required this.draft, required this.warnings, required this.candidates});

  final PoDraft draft;
  final List<String> warnings;
  final List<Option> candidates;
}

/// Puts the AI extraction (`PurchaseOrderExtractionResponse`) on a copy of [base], the web's way
/// (`hooks/usePurchaseOrderAiReading.ts`, `utils/purchaseOrderAi.ts`): supplier and truck / driver by id, invoice no.
/// upper case, dates only when found (PO date falls back to the invoice date), expense type only when it is in
/// [descriptions], lines with qty 1 by default and the rate from the unit price or (amount − tax) ÷ qty, accounts by
/// id, code then name in [accounts]. Nothing is saved: the person checks and saves (playbook §6).
PoAiResult applyPoExtraction(
  Map<String, dynamic> ai,
  PoDraft base, {
  required List<Option> suppliers,
  required List<Option> accounts,
  required List<Option> trucks,
  required List<Option> drivers,
  required List<String> descriptions,
}) {
  final d = PoDraft(
    id: base.id,
    number: base.number,
    poDate: base.poDate,
    invoiceDate: base.invoiceDate,
    payTo: base.payTo,
    status: base.status,
    paymentTermId: base.paymentTermId,
  );
  final warnings = <String>[
    for (final w in (JsonRead.field(ai, 'warnings') as List? ?? const [])) '$w',
  ];
  Option? byId(List<Option> list, int id) {
    for (final o in list) {
      if (o.id == id) return o;
    }
    return null;
  }

  // supplier
  final sup = JsonRead.map(JsonRead.field(ai, 'supplier'));
  final supplierId = JsonRead.integer(JsonRead.field(sup, 'supplierId'));
  final candidates = <Option>[];
  if (supplierId > 0) {
    d.supplier = byId(suppliers, supplierId) ?? Option(supplierId, pick(sup, const ['extractedName']));
    final term = JsonRead.integer(JsonRead.field(sup, 'paymentTermsId'));
    if (term > 0) d.paymentTermId = term;
  } else {
    for (final c in JsonRead.listOfMaps(JsonRead.field(sup, 'candidates')).take(3)) {
      final id = JsonRead.integer(JsonRead.field(c, 'id'));
      if (id > 0) candidates.add(byId(suppliers, id) ?? Option(id, pick(c, const ['name'])));
    }
    final name = pick(sup, const ['extractedName']);
    warnings.add(name.isEmpty ? 'Supplier not found: choose it' : 'Supplier "$name" not matched: choose it');
  }

  // header
  final h = JsonRead.map(JsonRead.field(ai, 'header'));
  final inv = pick(h, const ['invoiceNo']);
  if (inv.isNotEmpty) d.invoiceNo = inv.toUpperCase();
  final invDate = readDate(pick(h, const ['invoiceDate']));
  if (invDate != null) d.invoiceDate = invDate;
  final poDate = readDate(pick(h, const ['poDate'])) ?? invDate;
  if (poDate != null) d.poDate = poDate;
  final due = readDate(pick(h, const ['dueDate']));
  if (due != null) d.dueDate = due;
  final desc = pick(h, const ['description']).toUpperCase();
  for (final x in descriptions) {
    if (x.toUpperCase() == desc) d.description = x;
  }
  final ref = pick(h, const ['purchaseOrderNo']);
  final delivery = pick(h, const ['deliveryDate']);
  d.remarks = pick(h, const ['remarks']).isNotEmpty
      ? pick(h, const ['remarks'])
      : [if (ref.isNotEmpty) 'SUPPLIER REF $ref', if (delivery.isNotEmpty) 'DELIVERY $delivery'].join(' / ');
  final truckId = JsonRead.integer(JsonRead.field(h, 'truckId'));
  if (truckId > 0) d.truck = byId(trucks, truckId) ?? Option(truckId, pick(h, const ['truckName']));
  final driverId = JsonRead.integer(JsonRead.field(h, 'driverId'));
  if (driverId > 0) {
    d.driver = byId(drivers, driverId) ?? Option(driverId, pick(h, const ['driverMatchedName', 'driverName']));
  }
  final job = pick(h, const ['jobNo']);
  if (job.isNotEmpty) d.jobNo = job;
  d.loadingVessel = pick(h, const ['loadingVessel']);
  d.offVessel = pick(h, const ['offVessel']);

  // lines
  Option? account(Map<String, dynamic> l) {
    final id = JsonRead.integer(JsonRead.field(l, 'accountId'));
    if (id > 0) return byId(accounts, id) ?? Option(id, pick(l, const ['accountName']));
    final code = pick(l, const ['accountCode']).toUpperCase();
    final name = pick(l, const ['accountName']).toUpperCase();
    for (final a in accounts) {
      if (code.isNotEmpty && a.sub.toUpperCase().startsWith(code)) return a;
    }
    for (final a in accounts) {
      if (name.isNotEmpty && a.name.toUpperCase() == name) return a;
    }
    return null;
  }

  for (final l in JsonRead.listOfMaps(JsonRead.field(ai, 'lines'))) {
    var qty = pickNumber(l, const ['quantity']);
    if (qty <= 0) qty = 1;
    final tax = pickNumber(l, const ['taxAmount']);
    var rate = pickNumber(l, const ['unitPrice']);
    if (rate <= 0) rate = (pickNumber(l, const ['amount']) - tax) / qty;
    final base = qty * rate;
    var taxPct = pickNumber(l, const ['taxPercent']);
    if (taxPct <= 0 && tax > 0 && base > 0) taxPct = (tax / base * 100 * 100).roundToDouble() / 100;
    d.lines.add(PoLine(
      account: account(l),
      remarks: pick(l, const ['description']),
      serialNo: pick(l, const ['serialNo']),
      qty: qty,
      rate: (rate * 100).roundToDouble() / 100,
      taxPercent: taxPct,
    ));
  }
  final noAccount = d.lines.where((l) => l.account == null).length;
  if (noAccount > 0) warnings.add('$noAccount item${noAccount == 1 ? '' : 's'} without an account: choose it');
  final docTotal = pickNumber(h, const ['totalAmount']);
  if (docTotal > 0 && (docTotal - d.total).abs() > 0.05) {
    warnings.add(
        'The document says RM ${docTotal.toStringAsFixed(2)}; the items add up to RM ${d.total.toStringAsFixed(2)}');
  }
  return PoAiResult(draft: d, warnings: warnings, candidates: candidates);
}
