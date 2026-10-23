

import 'package:intl/intl.dart';
import 'package:maleva/core/fuel/fuel_vehicle.dart';

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

  /// A driver fills the truck on their record; an employee picks one of
  /// [vehicles] (openspec change employee-fuel-vehicles).
  final bool isDriver;
  final List<FuelVehicle> vehicles;

  /// The picked vehicle (TruckMaster id); 0 when none. Not used for a driver.
  final int truckRefId;

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
    this.isDriver = true,
    this.vehicles = const [],
    this.truckRefId = 0,
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
    bool? isDriver,
    List<FuelVehicle>? vehicles,
    int? truckRefId,
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
      isDriver: isDriver ?? this.isDriver,
      vehicles: vehicles ?? this.vehicles,
      truckRefId: truckRefId ?? this.truckRefId,
    );
  }

  static String _today() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// The name of the picked vehicle, or '' when none is picked.
  String get truckName =>
      vehicles.where((v) => v.truckRefId == truckRefId).map((v) => v.truckName).firstOrNull ?? '';

  factory FuelEntryLoaded.empty({
    String fuelNo = '',
    bool isDriver = true,
    List<FuelVehicle> vehicles = const [],
    int truckRefId = 0,
  }) =>
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
        isDriver: isDriver,
        vehicles: vehicles,
        truckRefId: truckRefId,
      );
}

class FuelEntryError extends FuelEntryState {
  final String message;
  FuelEntryError(this.message);
}

class FuelEntrySaveSuccess extends FuelEntryState {}