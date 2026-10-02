import '../entities/truck_location_week.dart';

/// What the Truck Location screens need from the backend. Failures surface as
/// ApiFailure with the server's own message.
abstract interface class TruckLocationRepository {
  /// The week containing [date] (yyyy-MM-dd); the server moves it to Sunday.
  Future<TruckLocationWeek> week(String date);

  /// Save All: only the changed cells and changed Done ticks, never the whole
  /// grid. Returns the week as it now stands.
  Future<TruckLocationWeek> saveWeek({
    required String weekStart,
    required List<TruckLocationCellChange> cells,
    required List<TruckLocationDoneTick> doneTicks,
  });

  /// The shared row order: every truck id on the board, top row first,
  /// hidden ones included. Saved apart from Save All.
  Future<void> saveOrder(List<int> truckRefIds);
}
