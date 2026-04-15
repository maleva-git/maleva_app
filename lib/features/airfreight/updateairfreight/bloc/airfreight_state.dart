
abstract class AirFreightState {}

class AirFreightInitial extends AirFreightState {}

class AirFreightLoading extends AirFreightState {}

class AirFreightLoaded extends AirFreightState {
  // ── Job No lookup ─────────────────────────────────────────────────────────
  final String billType;
  final String jobNoText;
  final int    saleOrderId;
  final List<dynamic> jobNoSuggestions;

  // ── Loaded fields ─────────────────────────────────────────────────────────
  final String jobType;    // read-only, filled after loaddata
  final int    statusId;
  final String statusName;
  final String awbNo;

  // ── Image ─────────────────────────────────────────────────────────────────
  final bool         imageUploadEnabled;
  final List<String> images;

   AirFreightLoaded({
    required this.billType,
    required this.jobNoText,
    required this.saleOrderId,
    required this.jobNoSuggestions,
    required this.jobType,
    required this.statusId,
    required this.statusName,
    required this.awbNo,
    required this.imageUploadEnabled,
    required this.images,
  });

  AirFreightLoaded copyWith({
    String? billType,
    String? jobNoText,
    int?    saleOrderId,
    List<dynamic>? jobNoSuggestions,
    String? jobType,
    int?    statusId,
    String? statusName,
    String? awbNo,
    bool?   imageUploadEnabled,
    List<String>? images,
  }) {
    return AirFreightLoaded(
      billType:           billType           ?? this.billType,
      jobNoText:          jobNoText          ?? this.jobNoText,
      saleOrderId:        saleOrderId        ?? this.saleOrderId,
      jobNoSuggestions:   jobNoSuggestions   ?? this.jobNoSuggestions,
      jobType:            jobType            ?? this.jobType,
      statusId:           statusId           ?? this.statusId,
      statusName:         statusName         ?? this.statusName,
      awbNo:              awbNo              ?? this.awbNo,
      imageUploadEnabled: imageUploadEnabled ?? this.imageUploadEnabled,
      images:             images             ?? this.images,
    );
  }

  factory AirFreightLoaded.empty() =>  AirFreightLoaded(
    billType:           '0',
    jobNoText:          '',
    saleOrderId:        0,
    jobNoSuggestions:   [],
    jobType:            '',
    statusId:           0,
    statusName:         '',
    awbNo:              '',
    imageUploadEnabled: false,
    images:             [],
  );
}

class AirFreightError extends AirFreightState {
  final String message;
  AirFreightError(this.message);
}

class AirFreightSaveSuccess extends AirFreightState {}

class AirFreightInvalidJobType extends AirFreightState {}