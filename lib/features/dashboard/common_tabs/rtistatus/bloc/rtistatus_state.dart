

import 'package:equatable/equatable.dart';

enum RTIStatusStatus { initial, loading, success, failure }

class RTIStatusState extends Equatable {
  final RTIStatusStatus status;
  final String? errorMessage;
  final String? successMessage;

  // ─── Core IDs / display fields ────────────────────────────────────────────
  final int saleOrderId;
  final int rtiId;
  final String jobNo;
  final String rtiNo;

  // ─── Driver status dropdown ───────────────────────────────────────────────
  final String driverStatus; // 'PickUp' | 'Delivery'
  final String driverFolder; // 'DriverPickup' | 'DriverDelivery'

  // ─── Image state ─────────────────────────────────────────────────────────
  final List<String> imageNetwork;
  final bool checkBoxImageUpload;

  // ─── Preview index (non-null triggers dialog) ────────────────────────────
  final int? previewImageIndex;

  const RTIStatusState({
    this.status = RTIStatusStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.saleOrderId = 0,
    this.rtiId = 0,
    this.jobNo = '',
    this.rtiNo = '',
    this.driverStatus = 'PickUp',
    this.driverFolder = 'DriverPickup',
    this.imageNetwork = const [],
    this.checkBoxImageUpload = false,
    this.previewImageIndex,
  });

  factory RTIStatusState.initial() => const RTIStatusState();

  RTIStatusState copyWith({
    RTIStatusStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    int? saleOrderId,
    int? rtiId,
    String? jobNo,
    String? rtiNo,
    String? driverStatus,
    String? driverFolder,
    List<String>? imageNetwork,
    bool? checkBoxImageUpload,
    int? previewImageIndex,
    bool clearPreview = false,
  }) {
    return RTIStatusState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
      clearSuccess ? null : (successMessage ?? this.successMessage),
      saleOrderId: saleOrderId ?? this.saleOrderId,
      rtiId: rtiId ?? this.rtiId,
      jobNo: jobNo ?? this.jobNo,
      rtiNo: rtiNo ?? this.rtiNo,
      driverStatus: driverStatus ?? this.driverStatus,
      driverFolder: driverFolder ?? this.driverFolder,
      imageNetwork: imageNetwork ?? this.imageNetwork,
      checkBoxImageUpload: checkBoxImageUpload ?? this.checkBoxImageUpload,
      previewImageIndex:
      clearPreview ? null : (previewImageIndex ?? this.previewImageIndex),
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    successMessage,
    saleOrderId,
    rtiId,
    jobNo,
    rtiNo,
    driverStatus,
    driverFolder,
    imageNetwork,
    checkBoxImageUpload,
    previewImageIndex,
  ];
}