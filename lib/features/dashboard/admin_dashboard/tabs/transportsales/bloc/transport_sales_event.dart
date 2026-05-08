import 'package:equatable/equatable.dart';

abstract class TransportSalesEvent extends Equatable {
  const TransportSalesEvent();

  @override
  List<Object?> get props => [];
}

class InitTransportSalesEvent extends TransportSalesEvent {
  const InitTransportSalesEvent();
}

class ChangeEmployeeEvent extends TransportSalesEvent {
  final String empId;
  const ChangeEmployeeEvent(this.empId);

  @override
  List<Object?> get props => [empId];
}

class LoadSalesDataEvent extends TransportSalesEvent {
  const LoadSalesDataEvent();
}