class TroubleshootState {
  final String note;
  final bool sending;
  final bool success;
  final String? errorMessage;

  TroubleshootState({
    this.note = "",
    this.sending = false,
    this.success = false,
    this.errorMessage,
  });

  TroubleshootState copyWith({
    String? note,
    bool? sending,
    bool? success,
    String? errorMessage,
  }) {
    return TroubleshootState(
      note: note ?? this.note,
      sending: sending ?? this.sending,
      success: success ?? this.success,
      errorMessage: errorMessage,
    );
  }
}
