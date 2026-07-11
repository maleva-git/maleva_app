

import 'package:equatable/equatable.dart';

abstract class RTIStatusEvent extends Equatable {
  const RTIStatusEvent();

  @override
  List<Object?> get props => [];
}

// ─── Initialization ───────────────────────────────────────────────────────────

class RTIStatusInitialized extends RTIStatusEvent {
  final List<dynamic> rtiDetails;
  const RTIStatusInitialized({required this.rtiDetails});

  @override
  List<Object?> get props => [rtiDetails];
}

// ─── Driver Status Dropdown ───────────────────────────────────────────────────

class RTIStatusDriverStatusChanged extends RTIStatusEvent {
  final String status; // 'PickUp' or 'Delivery'
  const RTIStatusDriverStatusChanged({required this.status});

  @override
  List<Object?> get props => [status];
}

// ─── Image Upload Checkbox ────────────────────────────────────────────────────

class RTIStatusImageUploadToggled extends RTIStatusEvent {
  final bool value;
  const RTIStatusImageUploadToggled({required this.value});

  @override
  List<Object?> get props => [value];
}

// ─── Image Pick ───────────────────────────────────────────────────────────────

class RTIStatusImagePickRequested extends RTIStatusEvent {
  final bool fromCamera;
  const RTIStatusImagePickRequested({required this.fromCamera});

  @override
  List<Object?> get props => [fromCamera];
}

// ─── Image Delete ─────────────────────────────────────────────────────────────

class RTIStatusImageDeleteRequested extends RTIStatusEvent {
  final int index;
  const RTIStatusImageDeleteRequested({required this.index});

  @override
  List<Object?> get props => [index];
}

// ─── Image Preview ────────────────────────────────────────────────────────────

class RTIStatusImagePreviewRequested extends RTIStatusEvent {
  final int index;
  const RTIStatusImagePreviewRequested({required this.index});

  @override
  List<Object?> get props => [index];
}

// ─── Update / Send Mail ───────────────────────────────────────────────────────

class RTIStatusUpdateRequested extends RTIStatusEvent {
  const RTIStatusUpdateRequested();
}

// ─── Clear / Reset ────────────────────────────────────────────────────────────

class RTIStatusClearRequested extends RTIStatusEvent {
  const RTIStatusClearRequested();
}