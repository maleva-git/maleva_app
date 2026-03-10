import 'package:maleva/core/models/model.dart';

abstract class ReviewEvent {
  const ReviewEvent();
}

// ── Entry Form Events ─────────────────────────────────────────────────────────
class LoadEmployeeEvent extends ReviewEvent {
  const LoadEmployeeEvent();
}

class SelectReviewEvent extends ReviewEvent {
  final int value;
  const SelectReviewEvent(this.value);
}

class SelectEmployeesEvent extends ReviewEvent {
  final int empId;
  const SelectEmployeesEvent(this.empId);
}

class SelectDateEvent extends ReviewEvent {
  final DateTime date;
  const SelectDateEvent(this.date);
}

class SaveReviewEvent extends ReviewEvent {
  final String shopName;
  final String mobileNo;
  final String reviewMsg;
  final int? existingId;
  const SaveReviewEvent({
    required this.shopName,
    required this.mobileNo,
    required this.reviewMsg,
    this.existingId,
  });
}

class ResetFormEvent extends ReviewEvent {
  const ResetFormEvent();
}

// ── Grid Screen Events ────────────────────────────────────────────────────────
class LoadGridEmployeesEvent extends ReviewEvent {
  const LoadGridEmployeesEvent();
}

class SelectGridEmployeeEvent extends ReviewEvent {
  final int empId;
  const SelectGridEmployeeEvent(this.empId);
}

class SelectDateRangeEvent extends ReviewEvent {
  final DateTime fromDate;
  final DateTime toDate;
  const SelectDateRangeEvent({required this.fromDate, required this.toDate});
}

class LoadReviewsEvent extends ReviewEvent {
  const LoadReviewsEvent();
}

class DeleteReviewEvent extends ReviewEvent {
  final int id;
  const DeleteReviewEvent(this.id);
}