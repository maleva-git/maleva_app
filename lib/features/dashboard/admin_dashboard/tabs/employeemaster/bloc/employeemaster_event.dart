import '../../../../../../core/models/model.dart';

abstract class EmployeeMasterEvent {
  const EmployeeMasterEvent();
}

// ── List Page Events ──────────────────────────────────────────────────────────
class LoadEmployeesmasterEvent extends EmployeeMasterEvent {
  const LoadEmployeesmasterEvent();
}

class SearchEmployeeMasterEvent extends EmployeeMasterEvent {
  final String query;
  const SearchEmployeeMasterEvent(this.query);
}

class DeleteEmployeeMasterEvent extends EmployeeMasterEvent {
  final int id;
  const DeleteEmployeeMasterEvent(this.id);
}

class SelectEmployeeRecordEvent extends EmployeeMasterEvent {
  final EmployeeDetailsModel record;
  const SelectEmployeeRecordEvent(this.record);
}
// ── Add/Edit Page Events ──────────────────────────────────────────────────────
class InitAddEmployeeMasterEvent extends EmployeeMasterEvent {
  const InitAddEmployeeMasterEvent();
}

class UpdateFieldEvent extends EmployeeMasterEvent {
  final String field;
  final String value;
  const UpdateFieldEvent(this.field, this.value);
}

class SelectCurrencyEvent extends EmployeeMasterEvent {
  final String? currency;
  const SelectCurrencyEvent(this.currency);
}

class SelectEmployeeTypeEvent extends EmployeeMasterEvent {
  final String? employeeType;
  const SelectEmployeeTypeEvent(this.employeeType);
}

class SelectRulesTypeEvent extends EmployeeMasterEvent {
  final String? rulesType;
  const SelectRulesTypeEvent(this.rulesType);
}

class SelectJoiningDateEvent extends EmployeeMasterEvent {
  final String date;
  const SelectJoiningDateEvent(this.date);
}

class SelectLeavingDateEvent extends EmployeeMasterEvent {
  final String date;
  const SelectLeavingDateEvent(this.date);
}

class NextStepEvent extends EmployeeMasterEvent {
  const NextStepEvent();
}

class PreviousStepEvent extends EmployeeMasterEvent {
  const PreviousStepEvent();
}

class SaveEmployeeMasterEvent extends EmployeeMasterEvent {
  const SaveEmployeeMasterEvent();
}