import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';

double _r2(double v) => (v * 100).roundToDouble() / 100;

/// Pay bill statuses (web `paymentStatusOptions` without the empty one; the web requires a status).
const payBillStatuses = ['SEND FOR APPROVAL', 'PENDING DOCUMENTS', 'ACCEPETED', 'REJECTED', 'COMPLETED'];

/// One open document of the supplier (`/api/payments/supplier-bills`): a bill, a purchase, or the supplier's opening
/// balance; [amount] is what this payment puts on it.
class PayRow {
  PayRow({
    this.billMasterRefId,
    this.purchaseMasterRefId,
    this.supplieropenRefId,
    this.billNo = '',
    this.invoiceNo = '',
    this.billDate = '',
    this.billAmount = 0,
    this.paid = 0,
    this.balance = 0,
    this.amount = 0,
  });

  factory PayRow.fromJava(Map<String, dynamic> m) => PayRow(
        billMasterRefId: _id(m, 'billMasterRefId'),
        purchaseMasterRefId: _id(m, 'purchaseMasterRefId'),
        supplieropenRefId: _id(m, 'supplieropenRefId'),
        billNo: pick(m, const ['billNo']),
        invoiceNo: pick(m, const ['invoiceNo']),
        billDate: pick(m, const ['sBillDate', 'billDate']),
        billAmount: pickNumber(m, const ['billAmount']),
        paid: pickNumber(m, const ['payment']),
        balance: pickNumber(m, const ['balance']),
        amount: pickNumber(m, const ['amount']),
      );

  static int? _id(Map<String, dynamic> m, String k) {
    final v = JsonRead.intOrNull(JsonRead.field(m, k));
    return (v ?? 0) > 0 ? v : null;
  }

  final int? billMasterRefId;
  final int? purchaseMasterRefId;
  final int? supplieropenRefId;
  final String billNo;
  final String invoiceNo;
  final String billDate;
  final double billAmount;
  final double paid;
  final double balance;
  double amount;

  /// What people call the document.
  String get label {
    if (supplieropenRefId != null) return 'Opening balance';
    final no = billNo.isNotEmpty ? billNo : invoiceNo;
    return no.isEmpty ? 'Document' : no;
  }

  bool get overpaid => amount > balance + 0.001;
}

/// A pay bill (supplier payment) being made or changed in the app (change `payable-paybill-form`): the web Payment
/// page's fields and rules (`features/payment/pages/PaymentPage.tsx`, `api/paymentApi.ts` insertPayment).
class PayBillDraft {
  PayBillDraft({
    this.id = 0,
    this.number = '',
    this.supplier,
    this.bank,
    DateTime? date,
    this.refNo = '',
    this.payTo = 'DIRECT PAYMENT',
    this.description = '',
    this.remarks = '',
    this.status = 'SEND FOR APPROVAL',
    this.sendToVoucher = false,
    this.bankCharges = 0,
    this.bankName = '',
    this.accountNo = '',
    this.tinNo = '',
    this.sstNo = '',
    this.msicCode = '',
    this.serviceTaxType = '',
    List<PayRow>? rows,
  })  : date = date ?? Fmt.today(),
        rows = rows ?? [];

  int id;
  String number;
  Option? supplier;

  /// "Payment by": the bank the money goes from.
  Option? bank;
  DateTime date;
  String refNo;
  String payTo;
  String description;
  String remarks;
  String status;

  /// The web's "send for approval" tick (`PVStatus` 1): moves the payment into the voucher queue.
  bool sendToVoucher;
  double bankCharges;

  /// The supplier's bank and tax details, as on the web form (from the supplier record; editable there).
  String bankName;
  String accountNo;
  String tinNo;
  String sstNo;
  String msicCode;
  String serviceTaxType;
  List<PayRow> rows;

  bool get isNew => id == 0;

  List<PayRow> get selected => rows.where((r) => r.amount != 0).toList();

  double get total => _r2(selected.fold(0.0, (s, r) => s + r.amount));

  double get outstanding => _r2(rows.fold(0.0, (s, r) => s + r.balance));

  /// Every open document paid in full.
  void payAll() {
    for (final r in rows) {
      r.amount = r.balance > 0 ? r.balance : 0;
    }
  }

  /// The web's checks in order (`PaymentPage.tsx` handleSave).
  List<String> problems() {
    final p = <String>[];
    if (supplier == null) p.add('Choose the supplier');
    if (bank == null) p.add('Choose the bank (payment by)');
    if (refNo.trim().isEmpty) p.add('Type the reference number');
    if (status.trim().isEmpty) p.add('Choose the status');
    if (description.trim().isEmpty) p.add('Choose the description');
    if (selected.isEmpty) {
      p.add('Put an amount on at least one bill');
    } else if (total <= 0) {
      p.add('The payment must be more than zero');
    }
    for (final r in selected) {
      if (r.overpaid) p.add('${r.label}: the amount is more than its balance (${Fmt.rm(r.balance)})');
    }
    if (bankCharges < 0) p.add('Bank charges cannot be below zero');
    return p;
  }

  /// The body of `POST /api/payments/save` (web insertPayment): only the documents with an amount.
  Map<String, dynamic> toJson({required int? employeeId}) => {
        'id': id,
        'supplierRefId': supplier?.id ?? 0,
        'bankRefId': bank?.id ?? 0,
        'employeeRefId': (employeeId ?? 0) > 0 ? employeeId : null,
        'userRefId': null,
        'paymentDate': Fmt.ymd(date),
        'refNumber': refNo.trim(),
        'payTo': payTo.trim().isEmpty ? 'DIRECT PAYMENT' : payTo.trim(),
        'description': description.trim(),
        'remarks': remarks.trim(),
        'paymentStatus': status,
        'pvStatus': sendToVoucher ? 1 : 0,
        'amount': total,
        'bankCharges': bankCharges,
        'currencyValue': 0,
        'actualAmount': 0,
        'tinNo': tinNo,
        'sstNo': sstNo,
        'msicCode': msicCode,
        'serviceTaxType': serviceTaxType,
        'bankName': bankName,
        'accountNo': accountNo,
        'paymentDetails': [
          for (final r in selected)
            {
              'billMasterRefId': r.billMasterRefId,
              'purchaseMasterRefId': r.purchaseMasterRefId,
              'supplieropenRefId': r.supplieropenRefId,
              'amount': r.amount,
              'currencyValue': 0,
              'actualAmount': 0,
            },
        ],
      };

  /// A saved pay bill (`GET /api/payments/edit` Data1): `paymentDetails` is the supplier's whole open list with this
  /// payment's amounts filled in, so money can be moved between documents (web editPayment).
  factory PayBillDraft.fromEdit(Map<String, dynamic> m, {List<Option> suppliers = const [], List<Option> banks = const []}) {
    Option? find(List<Option> list, String key) {
      final id = JsonRead.integer(JsonRead.field(m, key));
      if (id <= 0) return null;
      for (final o in list) {
        if (o.id == id) return o;
      }
      return Option(id, '#$id');
    }

    return PayBillDraft(
      id: JsonRead.integer(JsonRead.field(m, 'id')),
      number: pick(m, const ['cNumberDisplay']),
      supplier: find(suppliers, 'supplierRefId'),
      bank: find(banks, 'bankRefId'),
      date: readDate(pick(m, const ['paymentDate', 'sPaymentDate'])),
      refNo: pick(m, const ['refNumber']),
      payTo: pick(m, const ['payTo']).isEmpty ? 'DIRECT PAYMENT' : pick(m, const ['payTo']),
      description: pick(m, const ['description']),
      remarks: pick(m, const ['remarks']),
      status: pick(m, const ['paymentStatus']).isEmpty ? 'SEND FOR APPROVAL' : pick(m, const ['paymentStatus']),
      sendToVoucher: JsonRead.integer(JsonRead.field(m, 'pvStatus')) == 1,
      bankCharges: pickNumber(m, const ['bankCharges']),
      bankName: pick(m, const ['bankName']),
      accountNo: pick(m, const ['accountNo']),
      tinNo: pick(m, const ['tinNo']),
      sstNo: pick(m, const ['sstNo']),
      msicCode: pick(m, const ['msicCode']),
      serviceTaxType: pick(m, const ['serviceTaxType']),
      rows: [for (final r in JsonRead.listOfMaps(JsonRead.field(m, 'paymentDetails'))) PayRow.fromJava(r)],
    );
  }
}
