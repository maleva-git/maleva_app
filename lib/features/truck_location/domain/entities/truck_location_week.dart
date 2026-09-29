import 'package:equatable/equatable.dart';

/// One truck's row on the board: the seven cells, the grey-hint fallback and
/// the Done tick, as the server sent them.
class TruckLocationRow extends Equatable {
  const TruckLocationRow({
    required this.truckRefId,
    required this.truckName,
    required this.truckNumber,
    required this.truckType,
    required this.truckStatus,
    required this.locations,
    required this.lastKnownLocation,
    required this.done,
  });

  final int truckRefId;
  final String truckName;
  final String truckNumber;
  final String truckType;

  /// ACTIVE, WORKSHOP or SOLD, as TruckMaster holds it.
  final String truckStatus;

  /// Seven entries, Sunday first. Empty string where nothing is typed.
  final List<String> locations;

  /// The newest location typed in the fortnight before this week, or empty.
  final String lastKnownLocation;

  /// Ticked Done for this week, so the board hides the row.
  final bool done;

  TruckLocationRow copyWith({List<String>? locations, bool? done}) =>
      TruckLocationRow(
        truckRefId: truckRefId,
        truckName: truckName,
        truckNumber: truckNumber,
        truckType: truckType,
        truckStatus: truckStatus,
        locations: locations ?? this.locations,
        lastKnownLocation: lastKnownLocation,
        done: done ?? this.done,
      );

  @override
  List<Object?> get props => [
        truckRefId, truckName, truckNumber, truckType, truckStatus,
        locations, lastKnownLocation, done,
      ];
}

/// One week of the board, rows already in the shared order.
class TruckLocationWeek extends Equatable {
  const TruckLocationWeek({
    required this.weekStart,
    required this.days,
    required this.rows,
  });

  /// The Sunday the week starts on (yyyy-MM-dd), whatever day was asked for.
  final String weekStart;

  /// The seven dates, Sunday first. [TruckLocationRow.locations] lines up.
  final List<String> days;

  final List<TruckLocationRow> rows;

  TruckLocationWeek copyWith({List<TruckLocationRow>? rows}) =>
      TruckLocationWeek(weekStart: weekStart, days: days, rows: rows ?? this.rows);

  @override
  List<Object?> get props => [weekStart, days, rows];
}

/// One changed cell of Save All.
class TruckLocationCellChange extends Equatable {
  const TruckLocationCellChange({
    required this.truckRefId,
    required this.planDate,
    required this.location,
  });

  final int truckRefId;
  final String planDate;
  final String location;

  @override
  List<Object?> get props => [truckRefId, planDate, location];
}

/// One changed Done tick of Save All.
class TruckLocationDoneTick extends Equatable {
  const TruckLocationDoneTick({required this.truckRefId, required this.done});

  final int truckRefId;
  final bool done;

  @override
  List<Object?> get props => [truckRefId, done];
}
