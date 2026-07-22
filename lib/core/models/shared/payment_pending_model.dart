
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