
class PaymentPendingModel {
  final String? SubExpenseName;
  final String? ExpenseName;
  final String? InnerExpense;
  final String? DueDate;
  final String? Paiddate;
  final double Amount;
  final String Paiddamount;
  final double InnerAmount;
  final String? BankName;
  final int id;
  final int? ExpenceDueDate;
  final int? Paidstatus;
  final double DueAmount;

  PaymentPendingModel({
    this.SubExpenseName,
    this.ExpenseName,
    this.InnerExpense,
    this.DueDate,
    this.Paiddate,
    required this.Amount,
    required this.Paiddamount,
    required this.InnerAmount,
    this.BankName,
    required this.id,
    this.ExpenceDueDate,
    this.Paidstatus,
    this.DueAmount = 0.0,
  });

  // ── The Java pending payments board (GET /api/pending-payments/board) ──────

  /// A month's bill (`bills[]`: id, expenseName, subExpenseName, amount,
  /// dueDate yyyy-MM-dd, paid, paidAmount, paidDate, bankName, voucherAmount).
  factory PaymentPendingModel.fromBoardBill(Map<String, dynamic> b) {
    final due = DateTime.tryParse(b['dueDate']?.toString() ?? '');
    return PaymentPendingModel(
      id: (b['id'] as num?)?.toInt() ?? 0,
      ExpenseName: b['expenseName']?.toString(),
      SubExpenseName: b['subExpenseName']?.toString(),
      Amount: (b['amount'] as num?)?.toDouble() ?? 0,
      BankName: b['bankName']?.toString(),
      ExpenceDueDate: due?.day,
      DueDate: due == null ? null : _dmy(due),
      Paidstatus: b['paid'] == true ? 1 : 0,
      Paiddamount: (b['paidAmount'] ?? 0).toString(),
      Paiddate: b['paidDate']?.toString(),
      InnerAmount: 0,
    );
  }

  /// A supplier with unpaid credit bills (`vendors[]`), shown as a VENDOR line.
  factory PaymentPendingModel.fromBoardVendor(Map<String, dynamic> v) => PaymentPendingModel(
        id: 0,
        ExpenseName: 'VENDOR',
        SubExpenseName: v['supplierName']?.toString(),
        Amount: (v['outstanding'] as num?)?.toDouble() ?? 0,
        BankName: '',
        Paidstatus: 0,
        Paiddamount: '',
        InnerAmount: 0,
      );

  /// One unpaid credit bill of a supplier (`vendors[].bills[]`).
  factory PaymentPendingModel.fromBoardVendorBill(String? supplierName, Map<String, dynamic> b) {
    final due = DateTime.tryParse(b['dueDate']?.toString() ?? '');
    return PaymentPendingModel(
      id: (b['billMasterId'] as num?)?.toInt() ?? 0,
      ExpenseName: 'VENDOR',
      SubExpenseName: supplierName,
      Amount: (b['outstanding'] as num?)?.toDouble() ?? 0,
      DueDate: due == null ? null : _dmy(due),
      Paiddamount: (b['paid'] ?? 0).toString(),
      InnerAmount: 0,
    );
  }

  static String _dmy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  factory PaymentPendingModel.fromJson(Map<String, dynamic> json) {
    return PaymentPendingModel(
      // ✅ SAFE double parse
      Amount: (json['Amount'] as num?)?.toDouble() ?? 0,
      InnerAmount: (json['InnerAmount'] as num?)?.toDouble() ?? 0,
      DueAmount: (json['DueAmount'] as num?)?.toDouble() ?? (json['dueAmount'] as num?)?.toDouble() ?? 0,

      // ✅ ALWAYS string (even if null)
      Paiddamount: json['Paiddamount']?.toString() ?? json['paidAmount']?.toString() ?? json['PaidAmount']?.toString() ?? json['Paidamount']?.toString() ?? "0",

      ExpenseName: json['ExpenseName']?.toString(),
      SubExpenseName: json['SubExpenseName']?.toString(),
      InnerExpense: json['InnerExpense']?.toString(),
      Paiddate: json['Paiddate']?.toString() ?? json['PaidDate']?.toString() ?? json['paidDate']?.toString() ?? json['paiddate']?.toString(),
      BankName: json['BankName']?.toString(),
      DueDate: json['DueDate']?.toString(),

      id: (json['Id'] as num?)?.toInt() ?? 0,
      ExpenceDueDate: (json['ExpenceDueDate'] as num?)?.toInt(),
      Paidstatus: int.tryParse(json['Paidstatus']?.toString() ?? json['paidstatus']?.toString() ?? json['PaidStatus']?.toString() ?? json['paidStatus']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Amount': Amount,
      'Paiddamount': Paiddamount,
      'InnerAmount': InnerAmount,
      'ExpenseName': ExpenseName,
      'SubExpenseName': SubExpenseName,
      'InnerExpense': InnerExpense,
      'BankName': BankName,
      'DueDate': DueDate,
      'Paiddate': Paiddate,
      'Id': id,
      'ExpenceDueDate': ExpenceDueDate,
      'Paidstatus': Paidstatus,
    };
  }
}