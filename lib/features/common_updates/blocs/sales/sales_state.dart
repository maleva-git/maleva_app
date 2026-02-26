abstract class SalesState {}
class SalesInitial extends SalesState {}
class SalesLoaded extends SalesState {
  final List salesData;
  SalesLoaded(this.salesData);
}
