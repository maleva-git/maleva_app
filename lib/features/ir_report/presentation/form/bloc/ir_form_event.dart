part of 'ir_form_bloc.dart';

sealed class IrFormEvent extends Equatable {
  const IrFormEvent();

  @override
  List<Object?> get props => [];
}

/// Opens the form: blank for a new report, loaded when [reportId] is set.
final class IrFormStarted extends IrFormEvent {
  const IrFormStarted({this.reportId});

  final int? reportId;

  @override
  List<Object?> get props => [reportId];
}

final class IrFormDateChanged extends IrFormEvent {
  const IrFormDateChanged(this.value);

  final DateTime value;

  @override
  List<Object?> get props => [value];
}

final class IrFormStatusChanged extends IrFormEvent {
  const IrFormStatusChanged(this.value);

  final IrStatus? value;

  @override
  List<Object?> get props => [value];
}

final class IrFormDepartmentChanged extends IrFormEvent {
  const IrFormDepartmentChanged(this.value);

  final LookupOption? value;

  @override
  List<Object?> get props => [value];
}

/// Description, reason, vessel or amount.
final class IrFormTextChanged extends IrFormEvent {
  const IrFormTextChanged(this.field, this.value);

  final IrField field;
  final String value;

  @override
  List<Object?> get props => [field, value];
}

/// Truck, driver or employee.
final class IrFormPartyChanged extends IrFormEvent {
  const IrFormPartyChanged(this.field, this.value);

  final IrField field;
  final IrParty value;

  @override
  List<Object?> get props => [field, value];
}

final class IrFormSubmitted extends IrFormEvent {
  const IrFormSubmitted();
}
