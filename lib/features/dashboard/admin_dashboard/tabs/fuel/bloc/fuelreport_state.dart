import 'package:maleva/core/models/model.dart';

abstract class FuelDiffState {
  const FuelDiffState();
}

class FuelDiffInitial extends FuelDiffState {
  const FuelDiffInitial();
}

class FuelDiffLoading extends FuelDiffState {
  const FuelDiffLoading();
}

class FuelDiffLoaded extends FuelDiffState {
  final List<FuelselectModel> records;
  final String fromDate;
  final String toDate;
  final FuelselectModel? selectedRecord;
  const FuelDiffLoaded({
    required this.records,
    required this.fromDate,
    required this.toDate,
    this.selectedRecord,
  });

  FuelDiffLoaded copyWith({
    List<FuelselectModel>? records,
    String? fromDate,
    String? toDate,
    FuelselectModel? selectedRecord,
    bool clearSelected = false,
  }) {
    return FuelDiffLoaded(
      records: records ?? this.records,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedRecord: clearSelected ? null : (selectedRecord ?? this.selectedRecord),

    );
  }

  @override
  List<Object?> get props => [records, fromDate, toDate, selectedRecord];
}

class FuelDiffError extends FuelDiffState {
  final String message;
  const FuelDiffError(this.message);

  @override
  List<Object?> get props => [message];
}