abstract class FuelFillingEvent {}

class LoadFuelFillingReport extends FuelFillingEvent {
  final DateTime fromDate;
  final DateTime toDate;

  LoadFuelFillingReport({
    DateTime? fromDate,
    DateTime? toDate,
  })  : fromDate = fromDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1),
        toDate   = toDate   ?? DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
}