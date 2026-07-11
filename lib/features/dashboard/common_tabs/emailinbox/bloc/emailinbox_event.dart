import 'package:maleva/core/models/model.dart';

abstract class EmailEvent {
  const EmailEvent();
}

class LoadEmployeesEvent extends EmailEvent {
  const LoadEmployeesEvent();
}

class SelectEmployeeEvent extends EmailEvent {
  final EmployeeModel employee;
  const SelectEmployeeEvent(this.employee);
}

class LoadEmailsEvent extends EmailEvent {
  final int empId;
  const LoadEmailsEvent(this.empId);
}

class ToggleEmailActiveEvent extends EmailEvent {
  final int index;
  final bool value;
  const ToggleEmailActiveEvent({required this.index, required this.value});
}

class ToggleEmailUnreadEvent extends EmailEvent {
  final int index;
  final bool value;
  const ToggleEmailUnreadEvent({required this.index, required this.value});
}

class ToggleEmailRepliedEvent extends EmailEvent {
  final int index;
  final bool value;
  const ToggleEmailRepliedEvent({required this.index, required this.value});
}

class SaveEmailsEvent extends EmailEvent {
  const SaveEmailsEvent();
}