abstract class SalesEvent {}
class LoadSales extends SalesEvent {
  final int page;
  LoadSales(this.page);
}
