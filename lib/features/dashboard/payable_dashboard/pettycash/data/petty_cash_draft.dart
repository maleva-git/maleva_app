import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';

/// Petty cash money rules (change `payable-pettycash-form`), the web's `utils/pettyCashBalance.ts`.

/// Two decimals, half away from zero, without the 1.005 → 1.00 float slip; never "-0.00".
double roundMoney(double value) {
  if (!value.isFinite) return 0;
  final sign = value < 0 ? -1 : 1;
  final r = sign * (value.abs() * 100 + 2.220446049250313e-14).round() / 100;
  return r == 0 ? 0 : r;
}

/// A typed or wire amount as a number; blanks and non-numbers count as 0.
double moneyOf(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.isFinite ? value.toDouble() : 0;
  final t = '$value'.replaceAll(',', '').trim();
  if (t.isEmpty) return 0;
  return double.tryParse(t) ?? 0;
}

/// A typed or wire amount for the API: null when blank or not a number.
double? toMoneyOrNull(Object? value) {
  if (value == null) return null;
  if (value is num) return value.isFinite ? roundMoney(value.toDouble()) : null;
  final t = '$value'.replaceAll(',', '').trim();
  if (t.isEmpty) return null;
  final v = double.tryParse(t);
  return v == null ? null : roundMoney(v);
}

/// A number as the text a money box holds ('' for null).
String moneyText(num? value) => value == null || !value.isFinite ? '' : roundMoney(value.toDouble()).toStringAsFixed(2);

/// This balance = Last balance + Cash received − Total, rounded to two decimals.
double computeThisBalance(Object? before, Object? received, Object? total) =>
    roundMoney(moneyOf(before) + moneyOf(received) - moneyOf(total));

/// The web's payment status list (`constants/formOptions.ts` paymentStatusOptions); '' = no status.
const pettyCashStatuses = ['', 'SEND FOR APPROVAL', 'PENDING DOCUMENTS', 'ACCEPETED', 'REJECTED', 'COMPLETED'];

/// The employee types used when `/api/employees/types` fails (web fallbackDepartmentOptions).
const pettyCashFallbackTypes = ['ACCOUNTS', 'ADMIN'];

/// An expense account of `select-coa-expense`: [extra] is its e-Invoice classification id, as on the web
/// (`pettyCashAccounts.ts` accountPatchOf: the classification comes from the account).
class PettyCashAccount extends Option {
  const PettyCashAccount(super.id, super.name, {super.sub, super.extra, this.code = '', this.classificationName = ''});

  final String code;
  final String classificationName;

  int get classification => extra;
}

/// One row of the sheet, typed text kept as typed (a blank amount stays blank).
class PettyCashLine {
  PettyCashLine({this.id = 0, this.items = '', this.notes = '', this.amount = '', this.account});

  int id;
  String items;
  String notes;
  String amount;
  PettyCashAccount? account;

  /// A row with an item or an amount typed (web hasPettyCashLineData).
  bool get hasData => items.trim().isNotEmpty || amount.trim().isNotEmpty;

  /// No item, no amount, or an amount that is not a number (negative passes) (web isIncompletePettyCashLine).
  bool get incomplete => items.trim().isEmpty || amount.trim().isEmpty || double.tryParse(amount.trim()) == null;

  PettyCashLine copy() => PettyCashLine(id: id, items: items, notes: notes, amount: amount, account: account);
}

/// `GET /api/petty-cash-book/last-balance`.
class PettyCashLastBalance {
  const PettyCashLastBalance(
      {required this.ready, required this.found, this.sheetId, this.number = '', this.date, this.balanceAfter});

  factory PettyCashLastBalance.fromJava(Map<String, dynamic> m) {
    final id = JsonRead.integer(JsonRead.field(m, 'sheetId'));
    return PettyCashLastBalance(
      ready: JsonRead.field(m, 'ready') == true,
      found: JsonRead.field(m, 'found') == true,
      sheetId: id > 0 ? id : null,
      number: pick(m, const ['number']),
      date: readDate(_dateText(JsonRead.field(m, 'date'))),
      balanceAfter: toMoneyOrNull(JsonRead.field(m, 'balanceAfter')),
    );
  }

  /// False until the server's SQL p02 has run.
  final bool ready;
  final bool found;
  final int? sheetId;
  final String number;
  final DateTime? date;
  final double? balanceAfter;
}

/// A LocalDate as Jackson may write it: "2026-09-12" or [2026, 9, 12].
String _dateText(dynamic v) {
  if (v is List && v.length >= 3) {
    String two(dynamic x) => '${JsonRead.integer(x)}'.padLeft(2, '0');
    return '${v[0]}-${two(v[1])}-${two(v[2])}';
  }
  return JsonRead.string(v);
}

/// What the edit call says about a saved sheet's balances.
class PettyCashSavedBalances {
  const PettyCashSavedBalances(
      {required this.ready, this.balanceBefore, this.cashReceived, this.balanceAfter, this.typed, this.expectedBefore});

  /// False until the server's SQL p02 has run; the form then shows only the total.
  final bool ready;
  final double? balanceBefore;
  final double? cashReceived;
  final double? balanceAfter;
  final bool? typed;

  /// Only when the sheet before now ends on another balance.
  final double? expectedBefore;
}

/// `POST /api/petty-cash-book/{id}/follow`.
class PettyCashFollowResult {
  const PettyCashFollowResult({required this.updated, this.stoppedAt, this.reason});

  factory PettyCashFollowResult.fromJava(Map<String, dynamic> m) => PettyCashFollowResult(
        updated: [for (final u in (JsonRead.field(m, 'updated') as List? ?? const [])) '$u'],
        stoppedAt: JsonRead.stringOrNull(JsonRead.field(m, 'stoppedAt')),
        reason: JsonRead.stringOrNull(JsonRead.field(m, 'reason')),
      );

  final List<String> updated;
  final String? stoppedAt;
  final String? reason;

  /// "Updated 2 sheet(s)", plus where it stopped and why (web followMessage).
  String get message {
    final u = 'Updated ${updated.length} sheet(s)';
    return stoppedAt == null ? u : '$u — stopped at $stoppedAt: ${reason ?? ''}'.trim();
  }
}

/// A petty cash sheet being made or changed in the app (change `payable-pettycash-form`): the web form's fields and
/// rules (`PettyCashFormPage.tsx`, `pettyCashApi.ts` buildSavePayload, `pettyCashLines.ts`, `usePettyCashBalance.ts`).
class PettyCashDraft {
  PettyCashDraft({
    this.id = 0,
    this.number = '',
    DateTime? date,
    this.employee,
    this.department = '',
    this.remark = '',
    this.paymentStatus = '',
    List<PettyCashLine>? lines,
    this.saved,
    this.lastBalance,
    this.typedBefore,
    this.cashReceived = '',
    this.dirty = false,
  })  : date = date ?? Fmt.today(),
        lines = lines ?? [];

  int id;
  String number;
  DateTime date;

  /// "Requested by": the person whose petty cash book this sheet is in.
  Option? employee;

  /// "Employee type" (stored in the Department column).
  String department;
  String remark;
  String paymentStatus;
  List<PettyCashLine> lines;

  /// The balances saved on an opened sheet; null on a new sheet.
  PettyCashSavedBalances? saved;

  /// The person's last sheet (server); null while unknown.
  PettyCashLastBalance? lastBalance;

  /// Null = Last balance follows the server; text = typed by hand (the pencil).
  String? typedBefore;
  String cashReceived;

  /// An amount was changed since the sheet was opened (an opened sheet shows its saved This balance until then).
  bool dirty;

  bool get isNew => id == 0;

  /// The balances can be used (SQL p02 has run).
  bool get ready => saved != null ? saved!.ready : lastBalance?.ready == true;

  bool get typed => typedBefore != null;

  /// An opened sheet with a saved balance shows what was signed.
  bool get usesSaved => saved?.balanceBefore != null;

  String get balanceBefore {
    if (typedBefore != null) return typedBefore!;
    if (usesSaved) return moneyText(saved!.balanceBefore);
    final last = lastBalance;
    return last != null && last.found ? moneyText(last.balanceAfter) : '';
  }

  /// Every row's amount, blanks and non-numbers as 0 (web computePettyCashTotal).
  double get total => roundMoney(lines.fold(0.0, (s, l) => s + moneyOf(l.amount)));

  double get thisBalance => usesSaved && !dirty && saved!.balanceAfter != null
      ? saved!.balanceAfter!
      : computeThisBalance(balanceBefore, cashReceived, total);

  /// More spent than cash in hand (the sheet still saves).
  bool get short => thisBalance < 0;

  /// Where Last balance came from (web PettyCashBalanceBlock sourceNote).
  String get sourceNote {
    final last = lastBalance;
    if (typed) {
      return last != null && last.found
          ? 'Typed by hand — last sheet says ${Fmt.rm(last.balanceAfter ?? 0)}'
          : 'Typed by hand';
    }
    if (!isNew || last == null) return '';
    if (!last.found) return 'No earlier sheet: type the opening balance';
    return 'from ${last.number}, ${Fmt.ddMMyyyy(last.date)}';
  }

  /// The form has something typed (asked before the AI replaces it).
  bool get hasData => remark.trim().isNotEmpty || cashReceived.trim().isNotEmpty || lines.any((l) => l.hasData);

  List<PettyCashLine> get savedLines => lines.where((l) => l.hasData).toList();

  /// The web's checks in order (`PettyCashFormPage.tsx` save).
  List<String> problems() {
    if (department.trim().isEmpty) return const ['Choose the employee type'];
    final rows = savedLines;
    if (rows.isEmpty) return const ['Add at least one item'];
    if (rows.any((l) => l.incomplete)) return const ['Each row needs an item and a valid amount'];
    return const [];
  }

  /// The body of `POST /api/petty-cash-masters/save` (web buildSavePayload). [employeeId] = the signed-in employee,
  /// used only when no Requested by is chosen. Balances go only when ready, else empty.
  Map<String, dynamic> toJson({int? employeeId}) {
    final who = (employee?.id ?? 0) > 0 ? employee!.id : ((employeeId ?? 0) > 0 ? employeeId : null);
    final r = ready;
    return {
      'id': id,
      'employeeRefId': who,
      'department': department,
      'pettyCashDate': Fmt.ymd(date),
      'paymentStatus': paymentStatus,
      'remark': remark,
      'balanceBefore': r ? toMoneyOrNull(balanceBefore) : null,
      'cashReceived': r ? toMoneyOrNull(cashReceived) : null,
      'balanceBeforeTyped': r ? typed : false,
      'pettyCashDetails': [
        for (final l in savedLines)
          {
            'items': l.items,
            'amount': double.tryParse(l.amount.trim()) ?? 0,
            'notes': l.notes,
            'accountGroupRefId': l.account?.id ?? 0,
            'classification': l.account?.classification ?? 0,
          },
      ],
    };
  }

  /// A saved sheet (`GET /api/petty-cash-masters/edit` Data1). Each line keeps its own saved account and
  /// classification; the saved balances are what the form shows (what was signed).
  factory PettyCashDraft.fromEdit(Map<String, dynamic> m, {List<Option> employees = const []}) {
    double? money(String k) => toMoneyOrNull(JsonRead.field(m, k));
    final typedFlag = JsonRead.field(m, 'balanceBeforeTyped');
    final saved = PettyCashSavedBalances(
      ready: JsonRead.field(m, 'balancesReady') == true,
      balanceBefore: money('balanceBefore'),
      cashReceived: money('cashReceived'),
      balanceAfter: money('balanceAfter'),
      typed: typedFlag == null ? null : JsonRead.boolean(typedFlag),
      expectedBefore: money('expectedBalanceBefore'),
    );
    final empId = JsonRead.integer(JsonRead.field(m, 'employeeRefId'));
    Option? employee;
    if (empId > 0) {
      employee = employees.where((e) => e.id == empId).firstOrNull ?? Option(empId, '#$empId');
    }
    return PettyCashDraft(
      id: JsonRead.integer(JsonRead.field(m, 'id')),
      number: pick(m, const ['cNumberDisplay']),
      date: readDate(pick(m, const ['sPettyCashDate', 'pettyCashDate'])),
      employee: employee,
      department: pick(m, const ['department']),
      remark: pick(m, const ['remark']),
      paymentStatus: pick(m, const ['paymentStatus']),
      lines: [
        for (final l in JsonRead.listOfMaps(JsonRead.field(m, 'pettyCashDetails')))
          PettyCashLine(
            id: JsonRead.integer(JsonRead.field(l, 'id')),
            items: pick(l, const ['items']),
            notes: pick(l, const ['notes']),
            amount: JsonRead.field(l, 'amount') == null ? '' : _plain(JsonRead.number(JsonRead.field(l, 'amount'))),
            account: _lineAccount(l),
          ),
      ],
      saved: saved,
      typedBefore: saved.typed == true && saved.balanceBefore != null ? moneyText(saved.balanceBefore) : null,
      cashReceived: moneyText(saved.cashReceived),
    );
  }

  static String _plain(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : '$v';

  static PettyCashAccount? _lineAccount(Map<String, dynamic> l) {
    final id = JsonRead.integer(JsonRead.field(l, 'accountGroupRefId'));
    if (id <= 0) return null;
    final code = pick(l, const ['accountCode']);
    final name = pick(l, const ['accountName']);
    return PettyCashAccount(id, name.isEmpty ? (code.isEmpty ? '#$id' : code) : name,
        sub: code,
        code: code,
        extra: JsonRead.integer(JsonRead.field(l, 'classification')),
        classificationName: pick(l, const ['classificationName']));
  }
}
