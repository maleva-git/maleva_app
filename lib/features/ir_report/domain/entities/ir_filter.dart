import 'package:equatable/equatable.dart';

/// The IR list filters. Nothing set means "everything for the company".
class IrFilter extends Equatable {
  const IrFilter({
    this.fromDate,
    this.toDate,
    this.statusId = 0,
    this.openOnly = false,
    this.search = '',
  });

  /// The last [days] days up to today - what the list opens on.
  factory IrFilter.lastDays(int days, {DateTime? today}) {
    final now = today ?? DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    return IrFilter(fromDate: end.subtract(Duration(days: days)), toDate: end);
  }

  /// Inclusive date range over the incident date.
  final DateTime? fromDate;
  final DateTime? toDate;

  /// 0 means every status.
  final int statusId;

  /// Only reports whose status is not a finished one.
  final bool openOnly;

  /// Contains-match over description, reason, vessel, truck, driver, employee.
  final String search;

  IrFilter copyWith({
    DateTime? Function()? fromDate,
    DateTime? Function()? toDate,
    int? statusId,
    bool? openOnly,
    String? search,
  }) {
    return IrFilter(
      fromDate: fromDate != null ? fromDate() : this.fromDate,
      toDate: toDate != null ? toDate() : this.toDate,
      statusId: statusId ?? this.statusId,
      openOnly: openOnly ?? this.openOnly,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [fromDate, toDate, statusId, openOnly, search];
}
