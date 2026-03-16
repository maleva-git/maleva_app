import '../../../../../../core/models/model.dart';

abstract class FuelDiffEvent {
  const FuelDiffEvent();
}

class SelectFromDateEvent extends FuelDiffEvent {
  final String date;
  const SelectFromDateEvent(this.date);
}

class SelectToDateEvent extends FuelDiffEvent {
  final String date;
  const SelectToDateEvent(this.date);
}

class LoadFuelDiffEvent extends FuelDiffEvent {
  const LoadFuelDiffEvent();
}
class SelectFuelRecordEvent extends FuelDiffEvent {
  final FuelselectModel record;
  const SelectFuelRecordEvent(this.record);
}