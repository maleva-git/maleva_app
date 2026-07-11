abstract class BillOrderEvent {}

class LoadBillOrderEvent extends BillOrderEvent {
  final String fromDate;
  final String toDate;

  LoadBillOrderEvent({
    required this.fromDate,
    required this.toDate,
  });
}