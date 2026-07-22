


import 'package:equatable/equatable.dart';

import '../../../../../core/models/model.dart';

abstract class TransportDashboardEvent extends Equatable {
  const TransportDashboardEvent();

  @override
  List<Object?> get props => [];
}

// ─── Initialization ──────────────────────────────────────────────────────────

class TransportDashboardInitialized extends TransportDashboardEvent {
  final int initialTabIndex;
  final Review? existingReview;

  const TransportDashboardInitialized({
    this.initialTabIndex = 0,
    this.existingReview,
  });

  @override
  List<Object?> get props => [initialTabIndex, existingReview];
}

// ─── Sales Tab ───────────────────────────────────────────────────────────────

class LoadSalesDataRequested extends TransportDashboardEvent {
  final int empId;
  const LoadSalesDataRequested({required this.empId});

  @override
  List<Object?> get props => [empId];
}

class EmployeeFilterChanged extends TransportDashboardEvent {
  final String? dropdownValueEmp;
  final int empId;
  const EmployeeFilterChanged({required this.dropdownValueEmp, required this.empId});

  @override
  List<Object?> get props => [dropdownValueEmp, empId];
}

class LoadRulesTypeRequested extends TransportDashboardEvent {
  const LoadRulesTypeRequested();
}

// ─── Transport Tab ───────────────────────────────────────────────────────────

class LoadPlanningDataRequested extends TransportDashboardEvent {
  /// 0 = Today, 1 = Tomorrow
  final int type;
  const LoadPlanningDataRequested({required this.type});

  @override
  List<Object?> get props => [type];
}

// ─── Enquiry Tab ─────────────────────────────────────────────────────────────

class LoadEnquiryDataRequested extends TransportDashboardEvent {
  const LoadEnquiryDataRequested();
}

class CancelEnquiryRequested extends TransportDashboardEvent {
  final int id;
  const CancelEnquiryRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

// ─── Email Inbox Tab ─────────────────────────────────────────────────────────

class LoadEmployeesRequested extends TransportDashboardEvent {
  const LoadEmployeesRequested();
}

class EmployeeSelectedForEmail extends TransportDashboardEvent {
  final EmployeeModel employee;
  const EmployeeSelectedForEmail({required this.employee});

  @override
  List<Object?> get props => [employee];
}

class EmailActiveToggled extends TransportDashboardEvent {
  final int index;
  final bool value;
  const EmailActiveToggled({required this.index, required this.value});

  @override
  List<Object?> get props => [index, value];
}

class EmailUnreadToggled extends TransportDashboardEvent {
  final int index;
  final bool value;
  const EmailUnreadToggled({required this.index, required this.value});

  @override
  List<Object?> get props => [index, value];
}

class EmailRepliedToggled extends TransportDashboardEvent {
  final int index;
  final bool value;
  const EmailRepliedToggled({required this.index, required this.value});

  @override
  List<Object?> get props => [index, value];
}

class SaveEmailsRequested extends TransportDashboardEvent {
  const SaveEmailsRequested();
}

// ─── Google Review Tab ───────────────────────────────────────────────────────

class ReviewFormInitialized extends TransportDashboardEvent {
  final Review? existingReview;
  const ReviewFormInitialized({this.existingReview});

  @override
  List<Object?> get props => [existingReview];
}

class ReviewStarChanged extends TransportDashboardEvent {
  final int star;
  const ReviewStarChanged({required this.star});

  @override
  List<Object?> get props => [star];
}

class ReviewEmployeeChanged extends TransportDashboardEvent {
  final int? empId;
  const ReviewEmployeeChanged({required this.empId});

  @override
  List<Object?> get props => [empId];
}

class ReviewDateChanged extends TransportDashboardEvent {
  final DateTime date;
  const ReviewDateChanged({required this.date});

  @override
  List<Object?> get props => [date];
}

class SaveReviewRequested extends TransportDashboardEvent {
  final String shopName;
  final String mobileNo;
  final String reviewMsg;
  const SaveReviewRequested({
    required this.shopName,
    required this.mobileNo,
    required this.reviewMsg,
  });

  @override
  List<Object?> get props => [shopName, mobileNo, reviewMsg];
}

// ─── RTI / PDO Tab ───────────────────────────────────────────────────────────

class LoadRTIDataRequested extends TransportDashboardEvent {
  final String fromDate;
  final String toDate;
  final int driverId;
  final int truckId;
  final String search;

  const LoadRTIDataRequested({
    required this.fromDate,
    required this.toDate,
    required this.driverId,
    required this.truckId,
    required this.search,
  });

  @override
  List<Object?> get props => [fromDate, toDate, driverId, truckId, search];
}

class RTISearchQueryChanged extends TransportDashboardEvent {
  final String query;
  const RTISearchQueryChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

class RTIDetailCheckToggled extends TransportDashboardEvent {
  final int detailId;
  final bool isChecked;
  const RTIDetailCheckToggled({required this.detailId, required this.isChecked});

  @override
  List<Object?> get props => [detailId, isChecked];
}

class RTIImagePicked extends TransportDashboardEvent {
  final int detailId;
  final bool fromCamera;
  const RTIImagePicked({required this.detailId, required this.fromCamera});

  @override
  List<Object?> get props => [detailId, fromCamera];
}

class SaveRTIDataRequested extends TransportDashboardEvent {
  final int masterId;
  const SaveRTIDataRequested({required this.masterId});

  @override
  List<Object?> get props => [masterId];
}