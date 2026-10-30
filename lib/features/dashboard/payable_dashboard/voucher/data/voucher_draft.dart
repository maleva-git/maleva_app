import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';

double _r2(double v) => (v * 100).roundToDouble() / 100;

/// The voucher statuses of the web form (`constants/formOptions.ts`); '' is saved by the server as SEND FOR APPROVAL.
/// The stored spelling ACCEPETED is kept.
const voucherStatuses = ['', 'PENDING DOCUMENTS', 'ACCEPETED', 'REJECTED', 'COMPLETED'];

/// The fixed expense heads of the web form (`paymentDescriptionOptions`), merged with the company's saved ones.
const voucherDefaultHeads = [
  'HIRE PURCHASE', 'SALARY', 'OTHER EXPENSES', 'DIRECTOR EXPENSES', 'TENANCY', 'MAINTENANCE', 'UTILITY', 'VENDOR',
  'BACKLOG', 'FUEL', 'TOLL', 'CLAIM', 'KASTAM DUTY', 'BOAT CHARGES', 'Advance',
];

/// One voucher line: a GL account, what it is for, the amount; and the links the server keeps (a levy entry, a
/// pending monthly payment, a sub-expense). The server replaces every line on each save, so an edit carries them.
class VoucherLine {
  VoucherLine({
    this.id = 0,
    this.account,
    this.description = '',
    this.amount = 0,
    this.subExpenseRefid = 0,
    this.pendingPaymentRefId = 0,
    this.leviEntryRefId = 0,
  });

  int id;
  Option? account;
  String description;
  double amount;
  int subExpenseRefid;
  int pendingPaymentRefId;
  int leviEntryRefId;

  bool get hasData => account != null || amount != 0 || description.trim().isNotEmpty;

  /// Paid for a levy entry or a pending monthly bill: shown so the person knows the line is linked.
  String get linkLabel => leviEntryRefId > 0
      ? 'Levy'
      : pendingPaymentRefId > 0
          ? 'Monthly payment'
          : '';

  VoucherLine copy() => VoucherLine(
      id: id,
      account: account,
      description: description,
      amount: amount,
      subExpenseRefid: subExpenseRefid,
      pendingPaymentRefId: pendingPaymentRefId,
      leviEntryRefId: leviEntryRefId);
}

/// A payment voucher being made or changed in the app (change `payable-voucher-form`): the web form's fields and rules
/// (`features/payment-voucher/api/paymentVoucherApi.ts` buildSavePayload, `PaymentVoucherFormPage.tsx` checks).
class VoucherDraft {
  VoucherDraft({
    this.id = 0,
    this.number = '',
    DateTime? date,
    this.payTo = '',
    this.payFrom = '',
    this.bank,
    this.head = '',
    this.refNo = '',
    this.status = '',
    this.bankCharges = 0,
    this.poId,
    this.poNumber = '',
    this.selectedPayToId = 0,
    List<VoucherLine>? lines,
  })  : date = date ?? Fmt.today(),
        lines = lines ?? [];

  int id;
  String number;
  DateTime date;
  String payTo;
  String payFrom;

  /// "Payment by": the bank the money goes out from (required).
  Option? bank;

  /// The expense head (`Description`), which the expense report groups by.
  String head;
  String refNo;

  /// '' = send for approval (the server's default).
  String status;
  double bankCharges;
  int? poId;
  String poNumber;
  int selectedPayToId;
  List<VoucherLine> lines;

  bool get isNew => id == 0;

  List<VoucherLine> get filledLines => lines.where((l) => l.hasData).toList();

  double get total => _r2(filledLines.fold(0.0, (s, l) => s + l.amount));

  /// The web's checks in order: expense head, payment by, at least one line, every line an account and an amount ≥ 0.
  List<String> problems() {
    final p = <String>[];
    if (head.trim().isEmpty) p.add('Choose the expense head');
    if (bank == null) p.add('Choose the bank (payment by)');
    final filled = filledLines;
    if (filled.isEmpty) p.add('Add at least one line');
    for (var i = 0; i < filled.length; i++) {
      if (filled[i].account == null) p.add('Line ${i + 1}: choose the account');
      if (filled[i].amount < 0) p.add('Line ${i + 1}: the amount cannot be below zero');
    }
    if (bankCharges < 0) p.add('Bank charges cannot be below zero');
    return p;
  }

  /// The body of `POST /api/payment-voucher-masters/save` (bound without case on the server).
  Map<String, dynamic> toJson({required int companyId, required int? employeeId}) => {
        'id': id,
        'companyRefId': companyId,
        'userRefId': null,
        'employeeRefId': (employeeId ?? 0) > 0 ? employeeId : null,
        'paymentVoucherDate': Fmt.ymd(date),
        'payTo': payTo.trim(),
        'payFrom': payFrom.trim(),
        'paymentById': bank?.id ?? 0,
        'description': head.trim(),
        'refNo': refNo.trim(),
        'paymentStatus': status,
        'cNumberDisplay': 0,
        'cNumber': 0,
        'amount': total,
        'bankCharges': bankCharges,
        'billsOrderMasterRefId': (poId ?? 0) > 0 ? poId : null,
        'selectedPaytoid': selectedPayToId,
        'paymentVoucherDetails': [
          for (final l in filledLines)
            {
              'id': l.id,
              'accountCode': l.account?.sub.split(' · ').first ?? '',
              'accountName': l.account?.name ?? '',
              'accountGroupRefId': l.account?.id ?? 0,
              'description': l.description.trim(),
              'classification': (l.account?.extra ?? 0) > 0 ? l.account!.extra : null,
              'amount': l.amount,
              'paymentVoucherMasterRefId': id,
              'subExpenseRefid': l.subExpenseRefid,
              'pendingPaymentRefId': l.pendingPaymentRefId,
              'leviEntryRefId': l.leviEntryRefId,
              'editMode': 1,
            },
        ],
      };

  static VoucherLine _line(Map<String, dynamic> l, {required bool keepId}) {
    final acc = JsonRead.integer(pick(l, const ['accountGroupRefId', 'accountMasterRefId']));
    final code = pick(l, const ['accountCode', 'productCode']);
    return VoucherLine(
      id: keepId ? JsonRead.integer(JsonRead.field(l, 'id')) : 0,
      account: acc > 0
          ? Option(acc, pick(l, const ['accountName', 'productName']), sub: code,
              extra: JsonRead.integer(JsonRead.field(l, 'classification')))
          : null,
      description: pick(l, const ['description', 'remarksD']),
      amount: pickNumber(l, const ['amount']),
      subExpenseRefid: JsonRead.integer(pick(l, const ['subExpenseRefid'])),
      pendingPaymentRefId: JsonRead.integer(pick(l, const ['pendingPaymentRefId'])),
      leviEntryRefId: JsonRead.integer(pick(l, const ['leviEntryRefId'])),
    );
  }

  /// A saved voucher (`GET /api/payment-voucher-masters/edit` Data1), every line's links kept.
  factory VoucherDraft.fromEdit(Map<String, dynamic> m, {List<Option> banks = const []}) {
    final bankId = JsonRead.integer(JsonRead.field(m, 'paymentById'));
    Option? bank;
    for (final b in banks) {
      if (b.id == bankId) bank = b;
    }
    if (bank == null && bankId > 0) bank = Option(bankId, '#$bankId');
    return VoucherDraft(
      id: JsonRead.integer(JsonRead.field(m, 'id')),
      number: pick(m, const ['cNumberDisplay']),
      date: readDate(pick(m, const ['paymentVoucherDate', 'sPaymentVoucherDate'])),
      payTo: pick(m, const ['payTo']),
      payFrom: pick(m, const ['payFrom']),
      bank: bank,
      head: pick(m, const ['description']),
      refNo: pick(m, const ['refNo']),
      status: pick(m, const ['paymentStatus']).toUpperCase() == 'SEND FOR APPROVAL' ? '' : pick(m, const ['paymentStatus']),
      bankCharges: pickNumber(m, const ['bankCharges']),
      poId: JsonRead.intOrNull(JsonRead.field(m, 'billsOrderMasterRefId')),
      selectedPayToId: JsonRead.integer(JsonRead.field(m, 'selectedPaytoid')),
      lines: [for (final l in JsonRead.listOfMaps(JsonRead.field(m, 'paymentVoucherDetails'))) _line(l, keepId: true)],
    );
  }

  /// A new voucher paying a purchase order (web `PaymentVoucherFormPage.tsx` push): PO link, pay to, pay from,
  /// expense head, and one line per PO line (account, description, amount incl. tax, sub-expense). Bank, reference
  /// and status are the person's to choose.
  factory VoucherDraft.fromPo(Map<String, dynamic> po, {required String number}) => VoucherDraft(
        number: number,
        payTo: pick(po, const ['payTo']),
        payFrom: pick(po, const ['payFrom']),
        head: pick(po, const ['description']),
        poId: JsonRead.integer(JsonRead.field(po, 'id')),
        poNumber: pick(po, const ['cNumberDisplay']),
        lines: [for (final l in JsonRead.listOfMaps(JsonRead.field(po, 'billsOrderDetails'))) _line(l, keepId: false)],
      );
}
