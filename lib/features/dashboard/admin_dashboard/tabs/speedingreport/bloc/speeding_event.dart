abstract class SpeedingEvent {}

class LoadSpeedingReport extends SpeedingEvent {
  final DateTime fromDate;
  final DateTime toDate;

  LoadSpeedingReport({
    DateTime? fromDate,
    DateTime? toDate,
  })  : fromDate = fromDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1),
        toDate   = toDate   ?? DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
}