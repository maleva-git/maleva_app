import 'package:maleva/core/models/model.dart';

abstract class PettyCashState {
  const PettyCashState();
}

class PettyCashInitial extends PettyCashState {
  final DateTime fromDate;
  final DateTime toDate;

  const PettyCashInitial({
    required this.fromDate,
    required this.toDate,
  });
}

class PettyCashLoading extends PettyCashState {
  final DateTime fromDate;
  final DateTime toDate;

  const PettyCashLoading({
    required this.fromDate,
    required this.toDate,
  });
}

class PettyCashLoaded extends PettyCashState {
  final List<PattycashMasterModel> masterRecords;
  final List<PattyCashDetailsModel> detailRecords;
  final DateTime fromDate;
  final DateTime toDate;

  const PettyCashLoaded({
    required this.masterRecords,
    required this.detailRecords,
    required this.fromDate,
    required this.toDate,
  });

  PettyCashLoaded copyWith({
    List<PattycashMasterModel>? masterRecords,
    List<PattyCashDetailsModel>? detailRecords,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return PettyCashLoaded(
      masterRecords: masterRecords ?? this.masterRecords,
      detailRecords: detailRecords ?? this.detailRecords,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  @override
  List<Object?> get props =>
      [masterRecords, detailRecords, fromDate, toDate];
}

class PettyCashError extends PettyCashState {
  final String message;
  final DateTime fromDate;
  final DateTime toDate;

  const PettyCashError({
    required this.message,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [message];
}