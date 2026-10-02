
import 'package:equatable/equatable.dart';


abstract class SaleOrderDetailsEvent extends Equatable {
  const SaleOrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

// ── Startup ───────────────────────────────────────────────────────────────────

/// Fired once: loads the lookups (agents, employees, ...), then the order
/// [saleOrderId] or job number [saleOrderNo] when one is given.
class SaleOrderStartupEvent extends SaleOrderDetailsEvent {
  final String billType;
  final int saleOrderId;
  final int saleOrderNo;
  const SaleOrderStartupEvent({required this.billType, this.saleOrderId = 0, this.saleOrderNo = 0});

  @override
  List<Object?> get props => [billType, saleOrderId, saleOrderNo];
}

// ── Bill-type changed (MY / TR) ───────────────────────────────────────────────

class SaleOrderBillTypeChangedEvent extends SaleOrderDetailsEvent {
  final String billType;
  const SaleOrderBillTypeChangedEvent({required this.billType});

  @override
  List<Object?> get props => [billType];
}

// ── Pick-Up address dialog ────────────────────────────────────────────────────

class SaleOrderSelectPickUpAddressEvent extends SaleOrderDetailsEvent {
  final String address;
  const SaleOrderSelectPickUpAddressEvent({required this.address});

  @override
  List<Object?> get props => [address];
}

class SaleOrderDeletePickUpAddressEvent extends SaleOrderDetailsEvent {
  final int index;
  const SaleOrderDeletePickUpAddressEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

// ── Delivery address dialog ───────────────────────────────────────────────────

class SaleOrderSelectDeliveryAddressEvent extends SaleOrderDetailsEvent {
  final String address;
  const SaleOrderSelectDeliveryAddressEvent({required this.address});

  @override
  List<Object?> get props => [address];
}

class SaleOrderDeleteDeliveryAddressEvent extends SaleOrderDetailsEvent {
  final int index;
  const SaleOrderDeleteDeliveryAddressEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

// ── Forwarding expand/collapse ────────────────────────────────────────────────

class SaleOrderToggleFW1Event extends SaleOrderDetailsEvent {
  const SaleOrderToggleFW1Event();
}

class SaleOrderToggleFW2Event extends SaleOrderDetailsEvent {
  const SaleOrderToggleFW2Event();
}

class SaleOrderToggleFW3Event extends SaleOrderDetailsEvent {
  const SaleOrderToggleFW3Event();
}

// ── Tab change ────────────────────────────────────────────────────────────────

class SaleOrderTabChangedEvent extends SaleOrderDetailsEvent {
  final int index;
  const SaleOrderTabChangedEvent({required this.index});

  @override
  List<Object?> get props => [index];
}