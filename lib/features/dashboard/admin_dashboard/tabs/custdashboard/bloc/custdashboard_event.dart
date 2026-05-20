

import 'package:equatable/equatable.dart';

abstract class CustDashboardEvent extends Equatable {
  const CustDashboardEvent();

  @override
  List<Object?> get props => [];
}

// ─── Startup ───────────────────────────────────────────────────────────────────
class CustDashboardStarted extends CustDashboardEvent {
  const CustDashboardStarted();
}

// ─── Employee dropdown changed ─────────────────────────────────────────────────
class CustDashboardEmployeeChanged extends CustDashboardEvent {
  final String empId;
  const CustDashboardEmployeeChanged(this.empId);

  @override
  List<Object?> get props => [empId];
}

// ─── Sales Tab ─────────────────────────────────────────────────────────────────
class CustDashboardLoadSales extends CustDashboardEvent {
  const CustDashboardLoadSales();
}

// ─── Vessel Tab ────────────────────────────────────────────────────────────────
class CustDashboardLoadVessel extends CustDashboardEvent {
  /// 0 = today, 1 = tomorrow
  final int dayOffset;
  final String portFilter;
  const CustDashboardLoadVessel({this.dayOffset = 0, this.portFilter = ''});

  @override
  List<Object?> get props => [dayOffset, portFilter];
}

class CustDashboardPortFilterChanged extends CustDashboardEvent {
  final String port;
  const CustDashboardPortFilterChanged(this.port);

  @override
  List<Object?> get props => [port];
}

class CustDashboardPortAdded extends CustDashboardEvent {
  final String port;
  const CustDashboardPortAdded(this.port);

  @override
  List<Object?> get props => [port];
}

class CustDashboardPortCleared extends CustDashboardEvent {
  const CustDashboardPortCleared();
}

// ─── Transport Tab ─────────────────────────────────────────────────────────────
class CustDashboardLoadPlanning extends CustDashboardEvent {
  final int dayOffset;
  const CustDashboardLoadPlanning({this.dayOffset = 0});

  @override
  List<Object?> get props => [dayOffset];
}

// ─── Enquiry Tab ───────────────────────────────────────────────────────────────
class CustDashboardLoadEnquiry extends CustDashboardEvent {
  const CustDashboardLoadEnquiry();
}

class CustDashboardCancelEnquiry extends CustDashboardEvent {
  final int id;
  const CustDashboardCancelEnquiry(this.id);

  @override
  List<Object?> get props => [id];
}

// ─── Fuel Tab ──────────────────────────────────────────────────────────────────
class CustDashboardLoadFuel extends CustDashboardEvent {
  final String fromDate;
  final String toDate;
  const CustDashboardLoadFuel({required this.fromDate, required this.toDate});

  @override
  List<Object?> get props => [fromDate, toDate];
}

class CustDashboardFuelFromDateChanged extends CustDashboardEvent {
  final String date;
  const CustDashboardFuelFromDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class CustDashboardFuelToDateChanged extends CustDashboardEvent {
  final String date;
  const CustDashboardFuelToDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

// ─── Payment Tab ───────────────────────────────────────────────────────────────
class CustDashboardLoadPayment extends CustDashboardEvent {
  final bool isDateSearch;
  final DateTime? fromDate;
  final DateTime? toDate;
  const CustDashboardLoadPayment({
    this.isDateSearch = false,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [isDateSearch, fromDate, toDate];
}

class CustDashboardPaymentCategoryFilterChanged extends CustDashboardEvent {
  final String filter;
  final int sid;
  const CustDashboardPaymentCategoryFilterChanged(
      {required this.filter, required this.sid});

  @override
  List<Object?> get props => [filter, sid];
}

class CustDashboardPaymentPaidFilterChanged extends CustDashboardEvent {
  final String filter;
  final int pSid;
  const CustDashboardPaymentPaidFilterChanged(
      {required this.filter, required this.pSid});

  @override
  List<Object?> get props => [filter, pSid];
}

class CustDashboardPaymentFromDatePicked extends CustDashboardEvent {
  final DateTime date;
  const CustDashboardPaymentFromDatePicked(this.date);

  @override
  List<Object?> get props => [date];
}

class CustDashboardPaymentToDatePicked extends CustDashboardEvent {
  final DateTime date;
  const CustDashboardPaymentToDatePicked(this.date);

  @override
  List<Object?> get props => [date];
}

// ─── Tab switched ──────────────────────────────────────────────────────────────
class CustDashboardTabChanged extends CustDashboardEvent {
  final int index;
  const CustDashboardTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}