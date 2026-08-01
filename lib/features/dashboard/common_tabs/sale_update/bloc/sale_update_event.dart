abstract class SaleUpdateEvent {}

class SearchSaleOrdersEvent extends SaleUpdateEvent {
  final DateTime fromDate;
  final DateTime toDate;
  final int customerId;

  SearchSaleOrdersEvent({
    required this.fromDate,
    required this.toDate,
    required this.customerId,
  });
}

class SubmitSaleOrderUpdateEvent extends SaleUpdateEvent {
  final int id;
  final String remarks1;
  final String origin;
  final String destination;

  SubmitSaleOrderUpdateEvent({
    required this.id,
    required this.remarks1,
    required this.origin,
    required this.destination,
  });
}
