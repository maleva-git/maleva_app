import 'package:maleva/core/utils/json_read.dart';

/// The Payable Today tab's rows and rules (change `payable-desk-today`). The rows read the Java fields
/// as they arrive: `module/dashboard/dto/PendingPaymentDto` and `ExpenseDataDto` name them in PascalCase.

/// How close an unpaid row is to its due date: the server's `DueReportId` (2 past due, 1 due soon, 0 not yet).
enum DueState { overdue, dueSoon, scheduled }

/// One unpaid row of `GET /api/dashboard/pending-payment/{comId}`: a scheduled sub-expense or an unpaid
/// supplier bill.
class PendingPayment {
  const PendingPayment({
    required this.id,
    required this.expenseName,
    required this.subExpenseName,
    required this.amount,
    required this.dueDate,
    required this.dueDateText,
    required this.due,
    required this.isVendor,
    required this.bankName,
    required this.accountNo,
  });

  factory PendingPayment.fromJava(Map<String, dynamic> m) {
    final dueText = JsonRead.stringOrNull(JsonRead.field(m, 'DueDate'));
    return PendingPayment(
      id: JsonRead.integer(JsonRead.field(m, 'Id')),
      expenseName: JsonRead.stringOrNull(JsonRead.field(m, 'ExpenseName')),
      subExpenseName: JsonRead.stringOrNull(JsonRead.field(m, 'SubExpenseName')),
      amount: JsonRead.number(JsonRead.field(m, 'Amount')),
      dueDate: JsonRead.date(dueText),
      dueDateText: dueText,
      due: switch (JsonRead.integer(JsonRead.field(m, 'DueReportId'))) {
        2 => DueState.overdue,
        1 => DueState.dueSoon,
        _ => DueState.scheduled,
      },
      isVendor: JsonRead.integer(JsonRead.field(m, 'DetailedId')) == 1,
      bankName: JsonRead.stringOrNull(JsonRead.field(m, 'BankName')),
      accountNo: JsonRead.stringOrNull(JsonRead.field(m, 'AccountNo')),
    );
  }

  final int id;
  final String? expenseName;
  final String? subExpenseName;
  final double amount;
  final DateTime? dueDate;

  /// The due date as sent, shown when it cannot be read as a date.
  final String? dueDateText;
  final DueState due;

  /// `DetailedId` 1: the row names a supplier (vendor bill); 0: a sub-expense.
  final bool isVendor;
  final String? bankName;
  final String? accountNo;

  /// The sub-expense name, else the expense name (as the web desk shows it).
  String get name {
    final sub = subExpenseName?.trim() ?? '';
    if (sub.isNotEmpty) return sub;
    final exp = expenseName?.trim() ?? '';
    return exp.isNotEmpty ? exp : 'Payment';
  }
}

/// One settled payment of `GET /api/dashboard/completed-payment/{comId}`: a payment voucher
/// (`DetailedId` 0) or a supplier payment (`DetailedId` 1).
class CompletedPayment {
  const CompletedPayment({
    required this.id,
    required this.date,
    required this.number,
    required this.paidTo,
    required this.refNumber,
    required this.amount,
    required this.remarks,
    required this.isSupplier,
  });

  factory CompletedPayment.fromJava(Map<String, dynamic> m) => CompletedPayment(
        id: JsonRead.integer(JsonRead.field(m, 'Id')),
        date: JsonRead.stringOrNull(JsonRead.field(m, 'SSaleDate')),
        number: JsonRead.stringOrNull(JsonRead.field(m, 'CNumberDisplay')),
        paidTo: JsonRead.stringOrNull(JsonRead.field(m, 'ExpenseName')),
        refNumber: JsonRead.stringOrNull(JsonRead.field(m, 'RefNumber')),
        amount: JsonRead.number(JsonRead.field(m, 'Amount')),
        remarks: JsonRead.stringOrNull(JsonRead.field(m, 'Remarks')),
        isSupplier: JsonRead.integer(JsonRead.field(m, 'DetailedId')) == 1,
      );

  final int id;

  /// Already dd/MM/yyyy from the server.
  final String? date;
  final String? number;
  final String? paidTo;
  final String? refNumber;
  final double amount;
  final String? remarks;

  /// `DetailedId` 1: supplier payment (documents in PayBills); 0: payment voucher (PaymentVoucher).
  final bool isSupplier;
}

/// The record ids that have a document filed, per upload folder (`POST /api/common/checkFiles`).
class DocumentIndex {
  const DocumentIndex({required this.payBills, required this.paymentVoucher});

  final Set<int> payBills;
  final Set<int> paymentVoucher;

  /// A supplier payment's file is under PayBills, a voucher's under PaymentVoucher (the web desk's rule).
  bool has(CompletedPayment p) => (p.isSupplier ? payBills : paymentVoucher).contains(p.id);
}

/// One expense head of the breakdown.
class ExpenseHead {
  const ExpenseHead({required this.name, required this.count, required this.amount, this.approved = 0});

  final String name;
  final int count;

  /// REJECTED left out (change payable-expense-report).
  final double amount;

  /// Of [amount], the approved part (COMPLETED / ACCEPETED); the rest waits for approval. 0 from an older server.
  final double approved;

  double get waiting => (amount - approved).clamp(0, double.infinity).toDouble();
}

/// A count and money pair.
class CountAmount {
  const CountAmount(this.count, this.amount);

  final int count;
  final double amount;
}

/// `GET /api/dashboard/expense/{comId}`: today / yesterday / week / month (the `Sales` names count expenses,
/// a name kept from the shared stored procedure) and the breakdown in the date range.
class ExpenseSummary {
  const ExpenseSummary({
    required this.today,
    required this.yesterday,
    required this.week,
    required this.month,
    required this.heads,
    this.rejected = const CountAmount(0, 0),
  });

  factory ExpenseSummary.fromJava(Map<String, dynamic> m) {
    CountAmount pair(String p) => CountAmount(
        JsonRead.integer(JsonRead.field(m, '${p}Sales')), JsonRead.number(JsonRead.field(m, '${p}Amount')));
    return ExpenseSummary(
      today: pair('Today'),
      yesterday: pair('Yesterday'),
      week: pair('Week'),
      month: pair('Month'),
      heads: [
        for (final e in JsonRead.listOfMaps(JsonRead.field(m, 'expenses')))
          ExpenseHead(
            name: (JsonRead.stringOrNull(JsonRead.field(e, 'ExpenseName')) ?? '').trim(),
            count: JsonRead.integer(JsonRead.field(e, 'ExpCount')),
            amount: JsonRead.number(JsonRead.field(e, 'ExpAmount')),
            approved: JsonRead.number(JsonRead.field(e, 'ExpApproved')),
          ),
      ],
      rejected: CountAmount(JsonRead.integer(JsonRead.field(m, 'RejectedCount')),
          JsonRead.number(JsonRead.field(m, 'RejectedAmount'))),
    );
  }

  final CountAmount today;
  final CountAmount yesterday;
  final CountAmount week;
  final CountAmount month;
  final List<ExpenseHead> heads;

  /// REJECTED vouchers and payments in the range, left out of every number (0 from an older server).
  final CountAmount rejected;

  /// The range's total over the heads, and its approved part.
  double get headsTotal => heads.fold(0.0, (s, h) => s + h.amount);
  double get headsApproved => heads.fold(0.0, (s, h) => s + h.approved);
  int get headsCount => heads.fold(0, (s, h) => s + h.count);

  /// The [n] heads with the largest amount.
  List<ExpenseHead> top(int n) => ([...heads]..sort((a, b) => b.amount.compareTo(a.amount))).take(n).toList();
}

/// The Today tab's rules, kept apart from the widgets so they can be tested alone.
abstract final class PayableRules {
  /// Overdue first, then due soon, then the rest; inside a group the earliest due date first, no date last.
  static List<PendingPayment> sortToPay(Iterable<PendingPayment> rows) {
    int rank(DueState d) => switch (d) { DueState.overdue => 0, DueState.dueSoon => 1, DueState.scheduled => 2 };
    final list = [...rows];
    list.sort((a, b) {
      final g = rank(a.due).compareTo(rank(b.due));
      if (g != 0) return g;
      final ad = a.dueDate, bd = b.dueDate;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
    return list;
  }

  /// How many rows are in [state] and their total amount.
  static CountAmount total(Iterable<PendingPayment> rows, DueState state) {
    final r = rows.where((p) => p.due == state);
    return CountAmount(r.length, r.fold(0.0, (s, p) => s + p.amount));
  }

  static CountAmount paid(Iterable<CompletedPayment> rows) =>
      CountAmount(rows.length, rows.fold(0.0, (s, p) => s + p.amount));

  /// The payments with no document filed; none when the file check is not known.
  static List<CompletedPayment> withoutDocument(Iterable<CompletedPayment> rows, DocumentIndex? docs) =>
      docs == null ? const [] : rows.where((p) => !docs.has(p)).toList();
}
