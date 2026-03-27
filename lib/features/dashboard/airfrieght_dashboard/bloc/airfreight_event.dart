
abstract class SalesDashboardEvent {}

class TabChanged extends SalesDashboardEvent{
  final int index;
  TabChanged(this.index);
}