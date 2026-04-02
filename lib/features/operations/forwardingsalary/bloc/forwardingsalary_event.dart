

abstract class ForwardingSalaryEvent {}

// ── Startup ───────────────────────────────────────────────────────────────────
class ForwardingSalaryStarted extends ForwardingSalaryEvent {}

// ── BillType radio (MY=0, TR=1) ───────────────────────────────────────────────
class ForwardingSalaryBillTypeChanged extends ForwardingSalaryEvent {
  final String billType;
  ForwardingSalaryBillTypeChanged(this.billType);
}

// ── RTI No autocomplete ───────────────────────────────────────────────────────
class ForwardingSalaryRtiTextChanged extends ForwardingSalaryEvent {
  final String text;
  ForwardingSalaryRtiTextChanged(this.text);
}

class ForwardingSalaryRtiSelected extends ForwardingSalaryEvent {
  final int saleOrderId;
  final String rtiNo;
  ForwardingSalaryRtiSelected({required this.saleOrderId, required this.rtiNo});
}

class ForwardingSalaryOverlayDismissed extends ForwardingSalaryEvent {}

// ── Employee fields ───────────────────────────────────────────────────────────
class ForwardingSalarySealEmpChanged extends ForwardingSalaryEvent {
  final int empId;
  final String empName;
  ForwardingSalarySealEmpChanged({required this.empId, required this.empName});
}

class ForwardingSalarySealEmpCleared extends ForwardingSalaryEvent {}

class ForwardingSalaryBreakEmpChanged extends ForwardingSalaryEvent {
  final int empId;
  final String empName;
  ForwardingSalaryBreakEmpChanged({required this.empId, required this.empName});
}

class ForwardingSalaryBreakEmpCleared extends ForwardingSalaryEvent {}

// ── Salary text fields ────────────────────────────────────────────────────────
class ForwardingSalarySalary1Changed extends ForwardingSalaryEvent {
  final String value;
  ForwardingSalarySalary1Changed(this.value);
}

class ForwardingSalarySalary2Changed extends ForwardingSalaryEvent {
  final String value;
  ForwardingSalarySalary2Changed(this.value);
}

// ── Save ──────────────────────────────────────────────────────────────────────
class ForwardingSalarySaveRequested extends ForwardingSalaryEvent {}

// ── Reset form ────────────────────────────────────────────────────────────────
class ForwardingSalaryResetRequested extends ForwardingSalaryEvent {}