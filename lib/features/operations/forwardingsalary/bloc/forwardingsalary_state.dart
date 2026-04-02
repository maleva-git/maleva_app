

abstract class ForwardingSalaryState {}

class ForwardingSalaryInitial extends ForwardingSalaryState {}

class ForwardingSalaryLoading extends ForwardingSalaryState {}

class ForwardingSalaryLoaded extends ForwardingSalaryState {
  // ── RTI / Job lookup ───────────────────────────────────────────────────────
  final String billType;
  final String rtiText;
  final int saleOrderId;
  final int editId;
  final List<dynamic> rtiSuggestions;

  // ── Employee fields ────────────────────────────────────────────────────────
  final int sealEmpId;
  final String sealEmpName;
  final int breakEmpId;
  final String breakEmpName;

  // ── Salary fields ──────────────────────────────────────────────────────────
  final String salary1;
  final String salary2;

   ForwardingSalaryLoaded({
    required this.billType,
    required this.rtiText,
    required this.saleOrderId,
    required this.editId,
    required this.rtiSuggestions,
    required this.sealEmpId,
    required this.sealEmpName,
    required this.breakEmpId,
    required this.breakEmpName,
    required this.salary1,
    required this.salary2,
  });

  ForwardingSalaryLoaded copyWith({
    String? billType,
    String? rtiText,
    int? saleOrderId,
    int? editId,
    List<dynamic>? rtiSuggestions,
    int? sealEmpId,
    String? sealEmpName,
    int? breakEmpId,
    String? breakEmpName,
    String? salary1,
    String? salary2,
  }) {
    return ForwardingSalaryLoaded(
      billType:       billType       ?? this.billType,
      rtiText:        rtiText        ?? this.rtiText,
      saleOrderId:    saleOrderId    ?? this.saleOrderId,
      editId:         editId         ?? this.editId,
      rtiSuggestions: rtiSuggestions ?? this.rtiSuggestions,
      sealEmpId:      sealEmpId      ?? this.sealEmpId,
      sealEmpName:    sealEmpName    ?? this.sealEmpName,
      breakEmpId:     breakEmpId     ?? this.breakEmpId,
      breakEmpName:   breakEmpName   ?? this.breakEmpName,
      salary1:        salary1        ?? this.salary1,
      salary2:        salary2        ?? this.salary2,
    );
  }

  // ── Empty / reset factory ──────────────────────────────────────────────────
  factory ForwardingSalaryLoaded.empty() =>  ForwardingSalaryLoaded(
    billType:       '0',
    rtiText:        '',
    saleOrderId:    0,
    editId:         0,
    rtiSuggestions: [],
    sealEmpId:      0,
    sealEmpName:    '',
    breakEmpId:     0,
    breakEmpName:   '',
    salary1:        '',
    salary2:        '',
  );
}

class ForwardingSalaryError extends ForwardingSalaryState {
  final String message;
  ForwardingSalaryError(this.message);
}

class ForwardingSalarySaveSuccess extends ForwardingSalaryState {}