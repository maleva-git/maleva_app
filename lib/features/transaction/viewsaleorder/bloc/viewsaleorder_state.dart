

abstract class GetJobNoState {}

class GetJobNoInitial extends GetJobNoState {}

class GetJobNoLoading extends GetJobNoState {}

class GetJobNoLoaded extends GetJobNoState {
  final String billType;       // "0" = MY, "1" = TR
  final String jobNoText;      // current text field value
  final int saleOrderId;       // selected from autocomplete
  final List<dynamic> suggestions; // filtered autocomplete list
  final List<dynamic> cachedJobList; // list fetched from API

   GetJobNoLoaded({
    required this.billType,
    required this.jobNoText,
    required this.saleOrderId,
    required this.suggestions,
    required this.cachedJobList,
  });

  GetJobNoLoaded copyWith({
    String? billType,
    String? jobNoText,
    int? saleOrderId,
    List<dynamic>? suggestions,
    List<dynamic>? cachedJobList,
  }) {
    return GetJobNoLoaded(
      billType:      billType      ?? this.billType,
      jobNoText:     jobNoText     ?? this.jobNoText,
      saleOrderId:   saleOrderId   ?? this.saleOrderId,
      suggestions:   suggestions   ?? this.suggestions,
      cachedJobList: cachedJobList ?? this.cachedJobList,
    );
  }
}

class GetJobNoError extends GetJobNoState {
  final String message;
  GetJobNoError(this.message);
}

// Navigate to SaleOrderDetails
class GetJobNoNavigateToDetails extends GetJobNoState {
  final int saleOrderId;
  final int jobNo;
  GetJobNoNavigateToDetails({required this.saleOrderId, required this.jobNo});
}