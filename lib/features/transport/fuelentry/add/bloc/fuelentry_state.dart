

import 'package:intl/intl.dart';

abstract class FuelEntryState {}

class FuelEntryInitial extends FuelEntryState {}

class FuelEntryLoading extends FuelEntryState {}

class FuelEntryLoaded extends FuelEntryState {
  final String fuelNo;   // auto-generated, read-only
  final String date;     // yyyy-MM-dd
  final String liter;
  final String amount;
  final String remarks;
  final String pLiter;
  final String pRate;
  final String pAmount;
  final String gLiter;
  final String gAmount;
  final String dpLiter;
  final String dpAmount;
  final String dgLiter;
  final String dgAmount;

   FuelEntryLoaded({
    required this.fuelNo,
    required this.date,
    required this.liter,
    required this.amount,
    required this.remarks,
    required this.pLiter,
    required this.pRate,
    required this.pAmount,
    required this.gLiter,
    required this.gAmount,
    required this.dpLiter,
    required this.dpAmount,
    required this.dgLiter,
    required this.dgAmount,
  });

  FuelEntryLoaded copyWith({
    String? fuelNo,
    String? date,
    String? liter,
    String? amount,
    String? remarks,
    String? pLiter,
    String? pRate,
    String? pAmount,
    String? gLiter,
    String? gAmount,
    String? dpLiter,
    String? dpAmount,
    String? dgLiter,
    String? dgAmount,
  }) {
    return FuelEntryLoaded(
      fuelNo: fuelNo ?? this.fuelNo,
      date:   date   ?? this.date,
      liter:  liter  ?? this.liter,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
      pLiter: pLiter ?? this.pLiter,
      pRate: pRate ?? this.pRate,
      pAmount: pAmount ?? this.pAmount,
      gLiter: gLiter ?? this.gLiter,
      gAmount: gAmount ?? this.gAmount,
      dpLiter: dpLiter ?? this.dpLiter,
      dpAmount: dpAmount ?? this.dpAmount,
      dgLiter: dgLiter ?? this.dgLiter,
      dgAmount: dgAmount ?? this.dgAmount,
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
        remarks: '',
        pLiter: '',
        pRate: '',
        pAmount: '',
        gLiter: '',
        gAmount: '',
        dpLiter: '',
        dpAmount: '',
        dgLiter: '',
        dgAmount: '',
      );
}

class FuelEntryError extends FuelEntryState {
  final String message;
  FuelEntryError(this.message);
}

class FuelEntrySaveSuccess extends FuelEntryState {}