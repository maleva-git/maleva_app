import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class TransportSalesEvent extends Equatable {
  const TransportSalesEvent();

  @override
  List<Object?> get props => [];
}

class InitTransportSalesEvent extends TransportSalesEvent {
  final BuildContext context;
  const InitTransportSalesEvent(this.context);

  @override
  List<Object?> get props => [context];
}

class ChangeEmployeeEvent extends TransportSalesEvent {
  final BuildContext context;
  final String empId;
  const ChangeEmployeeEvent(this.context, this.empId);

  @override
  List<Object?> get props => [context, empId];
}

class LoadSalesDataEvent extends TransportSalesEvent {
  final BuildContext context;
  const LoadSalesDataEvent(this.context);

  @override
  List<Object?> get props => [context];
}