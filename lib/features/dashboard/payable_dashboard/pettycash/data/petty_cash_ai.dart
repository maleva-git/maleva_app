import 'package:maleva/core/utils/json_read.dart';

import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';
import 'petty_cash_draft.dart';

/// What the AI read from a petty cash sheet photo.
class PettyCashAiResult {
  const PettyCashAiResult(
      {required this.draft, required this.warnings, required this.candidates, this.unmatchedName = '', this.unmatched = false});

  final PettyCashDraft draft;
  final List<String> warnings;

  /// The closest people when no one was matched for sure (at most 3).
  final List<Option> candidates;

  /// The name as written on the sheet, when no one was matched for sure.
  final String unmatchedName;
  final bool unmatched;
}

final _isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

/// Puts the petty cash extraction (`PettyCashExtractionResponse`) on a copy of [base], the web's way
/// (`utils/pettyCashAi.ts` applyPettyCashExtraction): date, remark and Requested by only when given (the person only
/// when the server matched one); employee type when listed, else blank; Last balance typed by hand only when it is
/// not the server's last balance for that person; Cash received; the rows with an account only when the expense list
/// has it (by id, then by code / id / name). Nothing is saved: the person checks and saves.
PettyCashAiResult applyPettyCashExtraction(Map<String, dynamic> ai, PettyCashDraft base,
    {required List<PettyCashAccount> accounts, required List<String> types, List<Option> employees = const []}) {
  final h = JsonRead.map(JsonRead.field(ai, 'header'));
  final emp = JsonRead.map(JsonRead.field(ai, 'employee'));

  final d = PettyCashDraft(
    id: base.id,
    number: base.number,
    date: base.date,
    employee: base.employee,
    remark: base.remark,
    paymentStatus: base.paymentStatus,
    saved: base.saved,
    lastBalance: base.lastBalance,
    dirty: true,
  );

  final iso = _isoDate.firstMatch(JsonRead.string(JsonRead.field(h, 'date')));
  if (iso != null) d.date = DateTime(int.parse(iso[1]!), int.parse(iso[2]!), int.parse(iso[3]!));
  final remark = pick(h, const ['remark']);
  if (remark.isNotEmpty) d.remark = remark;

  final empId = JsonRead.integer(JsonRead.field(emp, 'employeeId'));
  if (empId > 0) {
    d.employee = employees.where((e) => e.id == empId).firstOrNull ??
        Option(empId, pick(emp, const ['employeeName', 'extractedName']).isEmpty ? '#$empId' : pick(emp, const ['employeeName', 'extractedName']));
  }

  final wanted = pick(h, const ['employeeTypeText']).toLowerCase();
  d.department = wanted.isEmpty ? '' : types.where((t) => t.toLowerCase() == wanted).firstOrNull ?? '';

  final before = JsonRead.field(h, 'balanceBefore');
  if (before != null && '$before'.trim().isNotEmpty) {
    final server = JsonRead.field(ai, 'lastBalance');
    final same = server != null && roundMoney(moneyOf(before)) == roundMoney(moneyOf(server));
    d.typedBefore = same ? null : moneyText(moneyOf(before));
  }
  final received = JsonRead.field(h, 'cashReceived');
  d.cashReceived = received == null ? '' : moneyText(moneyOf(received));

  PettyCashAccount? account(Map<String, dynamic> l) {
    final id = JsonRead.integer(JsonRead.field(l, 'accountId'));
    if (id > 0) {
      final a = accounts.where((a) => a.id == id).firstOrNull;
      if (a != null) return a;
    }
    final code = pick(l, const ['accountCode']).toLowerCase();
    if (code.isEmpty) return null;
    return accounts
        .where((a) => a.code.toLowerCase() == code || '${a.id}' == code || a.name.toLowerCase() == code)
        .firstOrNull;
  }

  for (final l in JsonRead.listOfMaps(JsonRead.field(ai, 'lines'))) {
    final amount = JsonRead.field(l, 'amount');
    d.lines.add(PettyCashLine(
      items: pick(l, const ['items']),
      notes: pick(l, const ['notes']),
      amount: amount == null ? '' : moneyText(moneyOf(amount)),
      account: account(l),
    ));
  }

  final warnings = <String>[for (final w in (JsonRead.field(ai, 'warnings') as List? ?? const [])) '$w'];
  final candidates = <Option>[];
  var name = '';
  var unmatched = false;
  if (empId <= 0) {
    name = pick(emp, const ['extractedName']);
    for (final c in JsonRead.listOfMaps(JsonRead.field(emp, 'candidates')).take(3)) {
      final id = JsonRead.integer(JsonRead.field(c, 'id'));
      if (id > 0) candidates.add(employees.where((e) => e.id == id).firstOrNull ?? Option(id, pick(c, const ['name'])));
    }
    unmatched = name.isNotEmpty || candidates.isNotEmpty;
  }
  return PettyCashAiResult(
      draft: d, warnings: warnings, candidates: candidates, unmatchedName: name, unmatched: unmatched);
}
