
abstract class ReceiptEvent {}

//initial Load
class LoadReceiptEvent extends ReceiptEvent {
  final bool isDateSearch;
  LoadReceiptEvent({this.isDateSearch = false});
}

//Date Select
class SelectFromDateEvent extends ReceiptEvent {
  final DateTime date;
  SelectFromDateEvent(this.date);
}

//To Date Select
class SelectToDateEvent extends ReceiptEvent {
  final DateTime date;
  SelectToDateEvent(this.date);
}