import 'package:equatable/equatable.dart';

/// One row of a master dropdown: a truck, driver, employee or department.
class LookupOption extends Equatable {
  const LookupOption({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// One IRStatusMaster row.
class IrStatus extends Equatable {
  const IrStatus({
    required this.id,
    required this.code,
    required this.name,
    this.colorCode,
    this.finished = false,
  });

  final int id;

  /// OPEN, UNDER_REVIEW, APPROVED, REJECTED, CLOSED ...
  final String code;
  final String name;

  /// "#RRGGBB", for the badge.
  final String? colorCode;

  /// True when this status ends the workflow (CLOSED, REJECTED).
  final bool finished;

  @override
  List<Object?> get props => [id, code, name, colorCode, finished];
}

/// Everything the form's dropdowns need, loaded together.
class IrLookups extends Equatable {
  const IrLookups({
    this.statuses = const [],
    this.departments = const [],
    this.trucks = const [],
    this.drivers = const [],
    this.employees = const [],
  });

  static const empty = IrLookups();

  final List<IrStatus> statuses;
  final List<LookupOption> departments;
  final List<LookupOption> trucks;
  final List<LookupOption> drivers;
  final List<LookupOption> employees;

  @override
  List<Object?> get props => [statuses, departments, trucks, drivers, employees];
}
