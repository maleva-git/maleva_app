

abstract class EnquiryAddState {}

class EnquiryAddInitial extends EnquiryAddState {}

class EnquiryAddLoading extends EnquiryAddState {}

class EnquiryAddLoaded extends EnquiryAddState {
  final int editId;

  // Master search fields
  final int custId;
  final String custName;
  final int jobTypeId;
  final String jobTypeName;
  final int originId;
  final String originName;
  final int destinationId;
  final String destinationName;

  // Text fields
  final String quantity;
  final String weight;
  final String lPort;
  final String oPort;

  // Date fields
  final String notifyDate;
  final String collectionDate;
  final String deliveryDate;
  final String oetaDate;

  // Checkboxes
  final bool checkCollection;
  final bool checkDelivery;
  final bool checkOeta;

   EnquiryAddLoaded({
    required this.editId,
    required this.custId,
    required this.custName,
    required this.jobTypeId,
    required this.jobTypeName,
    required this.originId,
    required this.originName,
    required this.destinationId,
    required this.destinationName,
    required this.quantity,
    required this.weight,
    required this.lPort,
    required this.oPort,
    required this.notifyDate,
    required this.collectionDate,
    required this.deliveryDate,
    required this.oetaDate,
    required this.checkCollection,
    required this.checkDelivery,
    required this.checkOeta,
  });

  EnquiryAddLoaded copyWith({
    int? editId,
    int? custId,
    String? custName,
    int? jobTypeId,
    String? jobTypeName,
    int? originId,
    String? originName,
    int? destinationId,
    String? destinationName,
    String? quantity,
    String? weight,
    String? lPort,
    String? oPort,
    String? notifyDate,
    String? collectionDate,
    String? deliveryDate,
    String? oetaDate,
    bool? checkCollection,
    bool? checkDelivery,
    bool? checkOeta,
  }) {
    return EnquiryAddLoaded(
      editId:          editId          ?? this.editId,
      custId:          custId          ?? this.custId,
      custName:        custName        ?? this.custName,
      jobTypeId:       jobTypeId       ?? this.jobTypeId,
      jobTypeName:     jobTypeName     ?? this.jobTypeName,
      originId:        originId        ?? this.originId,
      originName:      originName      ?? this.originName,
      destinationId:   destinationId   ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      quantity:        quantity        ?? this.quantity,
      weight:          weight          ?? this.weight,
      lPort:           lPort           ?? this.lPort,
      oPort:           oPort           ?? this.oPort,
      notifyDate:      notifyDate      ?? this.notifyDate,
      collectionDate:  collectionDate  ?? this.collectionDate,
      deliveryDate:    deliveryDate    ?? this.deliveryDate,
      oetaDate:        oetaDate        ?? this.oetaDate,
      checkCollection: checkCollection ?? this.checkCollection,
      checkDelivery:   checkDelivery   ?? this.checkDelivery,
      checkOeta:       checkOeta       ?? this.checkOeta,
    );
  }
}

class EnquiryAddError extends EnquiryAddState {
  final String message;
  EnquiryAddError(this.message);
}

class EnquiryAddSaveSuccess extends EnquiryAddState {}