abstract class EngineHoursEvent {}

class LoadEngineHoursReport extends EngineHoursEvent {
  final DateTime fromDate;
  final DateTime toDate;

  LoadEngineHoursReport({
    DateTime? fromDate,
    DateTime? toDate,
  })  : fromDate = fromDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1),
        toDate   = toDate   ?? DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
}