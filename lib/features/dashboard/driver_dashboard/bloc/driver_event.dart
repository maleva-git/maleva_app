
abstract class DriverDashboardEvent {}

class TabChanged extends DriverDashboardEvent{
  final int index;
  TabChanged(this.index);
}