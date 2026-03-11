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