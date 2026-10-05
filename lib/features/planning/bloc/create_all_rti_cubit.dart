import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/data/planning_repository.dart';
import 'package:maleva/features/planning/data/planning_rti_batch.dart';
import 'package:maleva/features/planning/models/rti_batch.dart';

enum CreateAllStage { loading, review, failed, creating, done }

class CreateAllRtiState {
  const CreateAllRtiState({
    this.stage = CreateAllStage.loading,
    this.preview,
    this.choices = const {},
    this.includeExisting = true,
    this.error = '',
    this.result,
    this.resultMessage = '',
    this.infoMessage,
    this.errorSeq = 0,
  });

  final CreateAllStage stage;
  final RtiBatchPreview? preview;
  final GroupChoices choices;

  /// On by default: a job carried again on a later plan needs its own RTI (`useCreateAllRti.ts:31-38`).
  final bool includeExisting;
  final String error;
  final RtiBatchResult? result;
  final String resultMessage;
  final String? infoMessage;

  /// Bumped with every new [error], so the sheet shows each one.
  final int errorSeq;

  BatchTally get tally => RtiBatchRules.tally(preview, choices);
  int get duplicates => RtiBatchRules.duplicateCount(preview, choices);
  bool get canConfirm => stage == CreateAllStage.review && tally.trucks > 0;

  CreateAllRtiState copyWith({
    CreateAllStage? stage,
    RtiBatchPreview? preview,
    GroupChoices? choices,
    bool? includeExisting,
    String? error,
    RtiBatchResult? result,
    String? resultMessage,
    String? Function()? infoMessage,
    int? errorSeq,
  }) =>
      CreateAllRtiState(
        stage: stage ?? this.stage,
        preview: preview ?? this.preview,
        choices: choices ?? this.choices,
        includeExisting: includeExisting ?? this.includeExisting,
        error: error ?? this.error,
        result: result ?? this.result,
        resultMessage: resultMessage ?? this.resultMessage,
        infoMessage: infoMessage != null ? infoMessage() : this.infoMessage,
        errorSeq: errorSeq ?? this.errorSeq,
      );
}

/// "Create All RTI" (the web's `useCreateAllRti`): a preview that writes nothing, the
/// planner's corrections, then one batch create.
class CreateAllRtiCubit extends Cubit<CreateAllRtiState> {
  CreateAllRtiCubit({required this.repo, required this.planningId}) : super(const CreateAllRtiState());

  final PlanningRepository repo;
  final int planningId;

  /// Opens with the jobs that already have an RTI included.
  Future<void> open() async {
    emit(const CreateAllRtiState());
    await _load(true, firstOpen: true);
  }

  Future<void> _load(bool withExisting, {bool firstOpen = false}) async {
    emit(state.copyWith(stage: CreateAllStage.loading, includeExisting: withExisting));
    try {
      final preview = await repo.batchPreview(planningId, includeExisting: withExisting);
      if (isClosed) return;
      emit(CreateAllRtiState(
          stage: CreateAllStage.review, preview: preview, choices: RtiBatchRules.initialChoices(preview), includeExisting: withExisting));
    } catch (e) {
      if (isClosed) return;
      if (firstOpen) {
        emit(state.copyWith(stage: CreateAllStage.failed, error: errorText(e, 'Could not read the plan.'), errorSeq: state.errorSeq + 1));
      } else {
        // the switch goes back; the preview on screen stays
        emit(state.copyWith(
            stage: CreateAllStage.review,
            includeExisting: !withExisting,
            error: errorText(e, 'Could not read the plan.'),
            errorSeq: state.errorSeq + 1));
      }
    }
  }

  /// "Skip jobs that already have an RTI": either way the plan is read again.
  Future<void> setSkipExisting(bool skip) => _load(!skip);

  void tick(String groupKey, bool selected) => _change(groupKey, (c) => c.copyWith(selected: selected));

  /// A driver from the list clears any outside-driver text; no driver unticks the group.
  void pickDriver(String groupKey, int driverId, String driverName) => _change(
      groupKey, (c) => c.copyWith(driverRefId: driverId, driverName: driverName, outsideDriver: '', selected: driverId > 0 ? c.selected : false));

  void _change(String groupKey, GroupChoice Function(GroupChoice) change) {
    final group = state.preview?.groups.where((g) => g.groupKey == groupKey).firstOrNull;
    if (group == null) return;
    final current = RtiBatchRules.choiceFor(group, state.choices);
    emit(state.copyWith(choices: {...state.choices, groupKey: change(current)}));
  }

  /// Creates the ticked groups' RTIs. Answers the result for the plan's rows, or null.
  Future<RtiBatchResult?> confirm({required int companyId, required int employeeId}) async {
    if (state.stage == CreateAllStage.creating) return null;
    final counts = state.tally;
    if (counts.trucks == 0) {
      emit(state.copyWith(error: 'Tick at least one truck to create.', errorSeq: state.errorSeq + 1));
      return null;
    }
    emit(state.copyWith(stage: CreateAllStage.creating));
    try {
      final request = RtiBatchRules.buildRequest(state.preview, state.choices,
          companyId: companyId, employeeRefId: employeeId, allowDuplicates: state.includeExisting);
      final result = await repo.batchCreate(planningId, request);
      if (isClosed) return result;
      emit(state.copyWith(
        stage: CreateAllStage.done,
        result: result,
        resultMessage: RtiBatchRules.resultMessage(result),
        infoMessage: () => RtiBatchRules.leftAloneMessage(result, includeExisting: state.includeExisting, tallyJobs: counts.jobs),
      ));
      return result;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
            stage: CreateAllStage.review, error: errorText(e, 'Could not create the RTI for this plan.'), errorSeq: state.errorSeq + 1));
      }
      return null;
    }
  }
}
