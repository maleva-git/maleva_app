import 'package:equatable/equatable.dart';

import 'ir_lookup.dart';
import 'ir_report.dart';

/// The fields of the IR form, used to key validation errors.
enum IrField {
  irDate,
  status,
  department,
  description,
  reason,
  vesselName,
  truck,
  driver,
  employee,
  amount,
}

/// A truck, driver or employee on the form: a row picked from the master list,
/// or a typed name for someone who is not in it (a hired lorry, an outside
/// driver).
class IrParty extends Equatable {
  const IrParty({this.selected, this.typedName = '', this.manual = false});

  static const empty = IrParty();

  final LookupOption? selected;
  final String typedName;

  /// True when the user chose to type a name instead of picking one.
  final bool manual;

  IrParty picked(LookupOption? option) => IrParty(selected: option);

  IrParty typed(String name) => IrParty(typedName: name, manual: true);

  /// Switching mode keeps only what belongs to the new mode, so a typed name
  /// never travels with a picked row or the other way round.
  IrParty withManual(bool value) =>
      value ? IrParty(typedName: typedName, manual: true) : IrParty(selected: selected);

  /// The master row id to send; 0 when typed or nothing chosen.
  int get refId => manual ? 0 : (selected?.id ?? 0);

  /// The typed name to send; empty when a row was picked.
  String get name => manual ? typedName.trim() : '';

  @override
  List<Object?> get props => [selected, typedName, manual];
}

/// What the user has entered on the IR form so far.
class IrDraft extends Equatable {
  const IrDraft({
    this.id = 0,
    this.irDate,
    this.status,
    this.department,
    this.description = '',
    this.reason = '',
    this.vesselName = '',
    this.truck = IrParty.empty,
    this.driver = IrParty.empty,
    this.employee = IrParty.empty,
    this.amountText = '',
  });

  /// A saved report in form shape.
  ///
  /// A saved truck, driver or employee that is no longer in its list (made
  /// inactive since) keeps its stored name, so opening and re-saving the
  /// report does not silently drop it.
  factory IrDraft.fromReport(IrReport report, IrLookups lookups) {
    return IrDraft(
      id: report.id,
      irDate: report.irDate,
      status: _firstWhere(lookups.statuses, (s) => s.id == report.statusId) ??
          IrStatus(
            id: report.statusId,
            code: report.statusCode ?? '',
            name: report.statusName ?? 'Status ${report.statusId}',
            colorCode: report.statusColor,
          ),
      department: _firstWhere(lookups.departments, (d) => d.id == report.departmentId) ??
          LookupOption(id: report.departmentId, name: report.departmentName),
      description: report.description,
      reason: report.reason ?? '',
      vesselName: report.vesselName ?? '',
      truck: _party(report.truckId, report.truckNo, lookups.trucks),
      driver: _party(report.driverId, report.driverName, lookups.drivers),
      employee: _party(report.employeeId, report.employeeName, lookups.employees),
      amountText: report.actualAmount?.toString() ?? '',
    );
  }

  /// IRMaster.Reason is varchar(1000); the name columns are varchar(100).
  static const maxReasonLength = 1000;
  static const maxTextLength = 100;

  /// 0 for a report that has not been saved yet.
  final int id;
  final DateTime? irDate;
  final IrStatus? status;
  final LookupOption? department;
  final String description;
  final String reason;
  final String vesselName;
  final IrParty truck;
  final IrParty driver;
  final IrParty employee;

  /// Kept as typed so a half-entered value is never lost; see [amount].
  final String amountText;

  bool get isNew => id == 0;

  /// Whole ringgit, or null when blank or not a whole number.
  int? get amount => int.tryParse(amountText.trim());

  IrDraft copyWith({
    DateTime? Function()? irDate,
    IrStatus? Function()? status,
    LookupOption? Function()? department,
    String? description,
    String? reason,
    String? vesselName,
    IrParty? truck,
    IrParty? driver,
    IrParty? employee,
    String? amountText,
  }) {
    return IrDraft(
      id: id,
      irDate: irDate != null ? irDate() : this.irDate,
      status: status != null ? status() : this.status,
      department: department != null ? department() : this.department,
      description: description ?? this.description,
      reason: reason ?? this.reason,
      vesselName: vesselName ?? this.vesselName,
      truck: truck ?? this.truck,
      driver: driver ?? this.driver,
      employee: employee ?? this.employee,
      amountText: amountText ?? this.amountText,
    );
  }

  /// Sets one of the free-text fields.
  IrDraft withText(IrField field, String value) {
    switch (field) {
      case IrField.description:
        return copyWith(description: value);
      case IrField.reason:
        return copyWith(reason: value);
      case IrField.vesselName:
        return copyWith(vesselName: value);
      case IrField.amount:
        return copyWith(amountText: value);
      default:
        throw ArgumentError.value(field, 'field', 'is not a text field');
    }
  }

  /// Sets the truck, driver or employee.
  IrDraft withParty(IrField field, IrParty party) {
    switch (field) {
      case IrField.truck:
        return copyWith(truck: party);
      case IrField.driver:
        return copyWith(driver: party);
      case IrField.employee:
        return copyWith(employee: party);
      default:
        throw ArgumentError.value(field, 'field', 'is not a truck, driver or employee field');
    }
  }

  /// Every problem that would stop the server accepting this draft, keyed by
  /// field. Mirrors the checks in IRServices.ValidateSave so the user hears
  /// about them before a round trip.
  Map<IrField, String> validate() {
    final errors = <IrField, String>{};

    if (irDate == null) errors[IrField.irDate] = 'Select when it happened';
    if (status == null) errors[IrField.status] = 'Select a status';
    if (department == null) errors[IrField.department] = 'Select a department';
    if (description.trim().isEmpty) errors[IrField.description] = 'Describe what happened';

    if (reason.length > maxReasonLength) {
      errors[IrField.reason] = 'Reason must be $maxReasonLength characters or fewer';
    }
    if (vesselName.length > maxTextLength) {
      errors[IrField.vesselName] = 'Vessel must be $maxTextLength characters or fewer';
    }
    _checkParty(errors, IrField.truck, truck, 'Truck no');
    _checkParty(errors, IrField.driver, driver, 'Driver name');
    _checkParty(errors, IrField.employee, employee, 'Employee name');

    final amountValue = amountText.trim();
    if (amountValue.isNotEmpty) {
      final parsed = int.tryParse(amountValue);
      if (parsed == null) {
        errors[IrField.amount] = 'Whole ringgit only, no decimals';
      } else if (parsed < 0) {
        errors[IrField.amount] = 'Amount must not be negative';
      }
    }
    return errors;
  }

  static void _checkParty(Map<IrField, String> errors, IrField field, IrParty party, String label) {
    if (party.manual && party.typedName.length > maxTextLength) {
      errors[field] = '$label must be $maxTextLength characters or fewer';
    }
  }

  static IrParty _party(int? id, String? storedName, List<LookupOption> options) {
    if (id != null && id != 0) {
      return IrParty(
        selected: _firstWhere(options, (o) => o.id == id) ??
            LookupOption(id: id, name: storedName ?? '#$id'),
      );
    }
    final name = storedName?.trim() ?? '';
    return name.isEmpty ? IrParty.empty : IrParty(typedName: name, manual: true);
  }

  static T? _firstWhere<T>(List<T> items, bool Function(T item) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        irDate,
        status,
        department,
        description,
        reason,
        vesselName,
        truck,
        driver,
        employee,
        amountText,
      ];
}
