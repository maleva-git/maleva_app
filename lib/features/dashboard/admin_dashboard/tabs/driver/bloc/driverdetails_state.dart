import '../../../../../../core/models/model.dart';

abstract class DriverState  {
  const DriverState();

  @override
  List<Object?> get props => [];
}

class DriverInitial extends DriverState {
  const DriverInitial();
}

class DriverLoading extends DriverState {
  const DriverLoading();
}

class DriverLoaded extends DriverState {
  final List<DriverDetailsModel> driverData;

  const DriverLoaded({required this.driverData});

  @override
  List<Object?> get props => [driverData];
}

class DriverError extends DriverState {
  final String errorMessage;

  const DriverError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}