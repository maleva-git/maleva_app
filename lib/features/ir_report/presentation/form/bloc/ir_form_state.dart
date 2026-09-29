part of 'ir_form_bloc.dart';

enum IrSubmitStatus { idle, submitting, success, failure }

class IrFormState extends Equatable {
  const IrFormState({
    this.loadStatus = IrViewStatus.initial,
    this.loadError,
    this.lookups = IrLookups.empty,
    this.draft = const IrDraft(),
    this.errors = const {},
    this.showErrors = false,
    this.submitStatus = IrSubmitStatus.idle,
    this.saved,
    this.message,
  });

  final IrViewStatus loadStatus;
  final String? loadError;
  final IrLookups lookups;
  final IrDraft draft;

  /// Always current; only shown once the user has tried to save.
  final Map<IrField, String> errors;
  final bool showErrors;

  final IrSubmitStatus submitStatus;

  /// The row the server returned after a successful save.
  final IrReport? saved;
  final IrUiMessage? message;

  bool get isNew => draft.isNew;

  String? errorFor(IrField field) => showErrors ? errors[field] : null;

  IrFormState copyWith({
    IrViewStatus? loadStatus,
    String? Function()? loadError,
    IrLookups? lookups,
    IrDraft? draft,
    Map<IrField, String>? errors,
    bool? showErrors,
    IrSubmitStatus? submitStatus,
    IrReport? Function()? saved,
    IrUiMessage? Function()? message,
  }) {
    return IrFormState(
      loadStatus: loadStatus ?? this.loadStatus,
      loadError: loadError != null ? loadError() : this.loadError,
      lookups: lookups ?? this.lookups,
      draft: draft ?? this.draft,
      errors: errors ?? this.errors,
      showErrors: showErrors ?? this.showErrors,
      submitStatus: submitStatus ?? this.submitStatus,
      saved: saved != null ? saved() : this.saved,
      message: message != null ? message() : this.message,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        loadError,
        lookups,
        draft,
        errors,
        showErrors,
        submitStatus,
        saved,
        message,
      ];
}
