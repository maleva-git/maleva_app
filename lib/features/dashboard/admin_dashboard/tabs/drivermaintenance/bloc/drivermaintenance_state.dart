

import '../../../../../../core/models/model.dart';

abstract class TruckMaintDashState {}

class TruckMaintDashInitial extends TruckMaintDashState {}

class TruckMaintDashLoading extends TruckMaintDashState {}

class TruckMaintDashLoaded extends TruckMaintDashState {
  final String expDate;
  final String expApadBonam;
  final String expServiceAlignGreece;
  final List<TruckDetailsModel> truckDetails;

   TruckMaintDashLoaded({
    required this.expDate,
    required this.expApadBonam,
    required this.expServiceAlignGreece,
    required this.truckDetails,
  });
}

class TruckMaintDashError extends TruckMaintDashState {
  final String message;
  TruckMaintDashError(this.message);
}