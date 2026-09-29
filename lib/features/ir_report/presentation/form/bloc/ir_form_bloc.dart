import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/ir_draft.dart';
import '../../../domain/entities/ir_lookup.dart';
import '../../../domain/entities/ir_report.dart';
import '../../../domain/repositories/ir_repository.dart';
import '../../ir_view_status.dart';

part 'ir_form_event.dart';
part 'ir_form_state.dart';

class IrFormBloc extends Bloc<IrFormEvent, IrFormState> {
  IrFormBloc({required IrRepository repository, DateTime Function()? clock})
      : _repository = repository,
        _clock = clock ?? DateTime.now,
        super(const IrFormState()) {
    on<IrFormStarted>(_onStarted, transformer: restartable());
    on<IrFormDateChanged>((event, emit) => _update(emit, state.draft.copyWith(irDate: () => event.value)));
    on<IrFormStatusChanged>((event, emit) => _update(emit, state.draft.copyWith(status: () => event.value)));
    on<IrFormDepartmentChanged>((event, emit) => _update(emit, state.draft.copyWith(department: () => event.value)));
    on<IrFormTextChanged>((event, emit) => _update(emit, state.draft.withText(event.field, event.value)));
    on<IrFormPartyChanged>((event, emit) => _update(emit, state.draft.withParty(event.field, event.value)));
    // Droppable: a second tap while the first save is in flight is ignored,
    // so a double tap can never create two reports.
    on<IrFormSubmitted>(_onSubmitted, transformer: droppable());
  }

  /// The status a new report starts on.
  static const defaultStatusCode = 'OPEN';

  final IrRepository _repository;
  final DateTime Function() _clock;

  Future<void> _onStarted(IrFormStarted event, Emitter<IrFormState> emit) async {
    emit(state.copyWith(loadStatus: IrViewStatus.loading, loadError: () => null));
    try {
      final lookups = await _repository.lookups();
      final reportId = event.reportId ?? 0;
      final draft = reportId == 0
          ? IrDraft(irDate: _clock(), status: _defaultStatus(lookups.statuses))
          : IrDraft.fromReport(await _repository.getById(reportId), lookups);
      emit(IrFormState(loadStatus: IrViewStatus.success, lookups: lookups, draft: draft));
    } catch (error) {
      emit(state.copyWith(loadStatus: IrViewStatus.failure, loadError: () => describeError(error)));
    }
  }

  void _update(Emitter<IrFormState> emit, IrDraft draft) {
    if (state.loadStatus != IrViewStatus.success) return;
    if (state.submitStatus == IrSubmitStatus.submitting) return;
    emit(state.copyWith(
      draft: draft,
      errors: draft.validate(),
      submitStatus: IrSubmitStatus.idle,
    ));
  }

  Future<void> _onSubmitted(IrFormSubmitted event, Emitter<IrFormState> emit) async {
    if (state.loadStatus != IrViewStatus.success) return;

    final errors = state.draft.validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(
        errors: errors,
        showErrors: true,
        message: () => IrUiMessage('Please fill in the highlighted fields', isError: true),
      ));
      return;
    }

    emit(state.copyWith(errors: const {}, submitStatus: IrSubmitStatus.submitting));
    try {
      final saved = await _repository.save(state.draft);
      emit(state.copyWith(submitStatus: IrSubmitStatus.success, saved: () => saved));
    } catch (error) {
      emit(state.copyWith(
        submitStatus: IrSubmitStatus.failure,
        message: () => IrUiMessage(describeError(error), isError: true),
      ));
    }
  }

  static IrStatus? _defaultStatus(List<IrStatus> statuses) {
    for (final status in statuses) {
      if (status.code.toUpperCase() == defaultStatusCode) return status;
    }
    return statuses.isEmpty ? null : statuses.first;
  }
}
