
class ReceiptState {
  final bool progress;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<Map<String, dynamic>> receiptMaster;
  final List<Map<String, dynamic>> receiptDetails;
  final double totalAmount;
  final double totalBalance;
  final String? errorMessage;

  const ReceiptState({
   this.progress = true,
   this.fromDate,
   this.toDate,
   this.receiptMaster = const [],
   this.receiptDetails = const [],
   this.totalAmount = 0.0,
   this.totalBalance = 0.0,
   this.errorMessage,
});

  ReceiptState copyWith ({
    bool? progress,
    DateTime? fromDate,
    DateTime? toDate,
    List<Map<String, dynamic>>? receiptMaster,
    List<Map<String, dynamic>>? receiptDetails,
    double? totalAmount,
    double? totalBalance,
    String? errorMessage,
}) {
    return ReceiptState(
      progress: progress ?? this.progress,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      receiptMaster: receiptMaster ?? this.receiptMaster,
      receiptDetails: receiptDetails ?? this.receiptDetails,
      totalAmount: totalAmount ?? this.totalAmount,
      totalBalance: totalBalance ?? this.totalBalance,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

}