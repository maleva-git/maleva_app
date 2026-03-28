

class EnquiryState {
  final bool isLoading;
  final List<dynamic> enquiryList;
  final String? errorMessage;

  const EnquiryState({
    this.isLoading = false,
    this.enquiryList = const [],
    this.errorMessage,
  });

  EnquiryState copyWith({
    bool? isLoading,
    List<dynamic>? enquiryList,
    String? errorMessage,
  }) {
    return EnquiryState(
      isLoading: isLoading ?? this.isLoading,
      enquiryList: enquiryList ?? this.enquiryList,
      errorMessage: errorMessage,
    );
  }
}