

import 'package:intl/intl.dart';

abstract class FuelEntryState {}

class FuelEntryInitial extends FuelEntryState {}

class FuelEntryLoading extends FuelEntryState {}

class FuelEntryLoaded extends FuelEntryState {
  final String fuelNo;   // auto-generated, read-only
  final String date;     // yyyy-MM-dd
  final String liter;
  final String amount;

   FuelEntryLoaded({
    required this.fuelNo,
    required this.date,
    required this.liter,
    required this.amount,
  });

  FuelEntryLoaded copyWith({
    String? fuelNo,
    String? date,
    String? liter,
    String? amount,
  }) {
    return FuelEntryLoaded(
      fuelNo: fuelNo ?? this.fuelNo,
      date:   date   ?? this.date,
      liter:  liter  ?? this.liter,
      amount: amount ?? this.amount,
    );
  }

  static String _today() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  factory FuelEntryLoaded.empty({String fuelNo = ''}) =>
      FuelEntryLoaded(
        fuelNo: fuelNo,
        date:   _today(),
        liter:  '',
        amount: '',
      );
}

class FuelEntryError extends FuelEntryState {
  final String message;
  FuelEntryError(this.message);
}

class FuelEntrySaveSuccess extends FuelEntryState {}