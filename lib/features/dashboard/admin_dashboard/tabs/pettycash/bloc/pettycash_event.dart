import '../../../../../../core/models/model.dart';

abstract class PettyCashEvent {
  const PettyCashEvent();
}

class SelectFromDateEvent extends PettyCashEvent {
  final DateTime date;
  const SelectFromDateEvent(this.date);
}

class SelectToDateEvent extends PettyCashEvent {
  final DateTime date;
  const SelectToDateEvent(this.date);
}

class LoadPettyCashEvent extends PettyCashEvent {
  const LoadPettyCashEvent();
}

class SelectPettyCashMasterEvent extends PettyCashEvent {
  final PattycashMasterModel master;
  const SelectPettyCashMasterEvent(this.master);
}