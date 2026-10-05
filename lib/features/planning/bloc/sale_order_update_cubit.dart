import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/data/planning_repository.dart';
import 'package:maleva/features/planning/data/sale_order_update.dart';

enum UpdateStage { loading, ready, failed, saving, saved }

class SaleOrderUpdateState {
  const SaleOrderUpdateState({this.stage = UpdateStage.loading, this.draft, this.error = '', this.message = '', this.saved, this.messageSeq = 0});

  final UpdateStage stage;
  final SaleOrderDraft? draft;

  /// The load failure ("Unable to load the selected sale order." + this + Retry).
  final String error;

  /// The save's message (success or refusal), shown once per [messageSeq].
  final String message;
  final Map<String, dynamic>? saved;
  final int messageSeq;

  SaleOrderUpdateState copyWith(
          {UpdateStage? stage, SaleOrderDraft? draft, String? error, String? message, Map<String, dynamic>? saved, int? messageSeq}) =>
      SaleOrderUpdateState(
        stage: stage ?? this.stage,
        draft: draft ?? this.draft,
        error: error ?? this.error,
        message: message ?? this.message,
        saved: saved ?? this.saved,
        messageSeq: messageSeq ?? this.messageSeq,
      );
}

/// The Planning "Update" window (`FE/components/modals/UpdateSaleOrderModal.tsx`): one job's
/// dates, route, cargo, warehouse and stops, saved with `POST /api/planing/update-dates`.
class SaleOrderUpdateCubit extends Cubit<SaleOrderUpdateState> {
  SaleOrderUpdateCubit({required this.repo, required this.saleOrderId}) : super(const SaleOrderUpdateState());

  final PlanningRepository repo;
  final int saleOrderId;
  int _stopSeq = 0;

  Future<void> load() async {
    emit(const SaleOrderUpdateState());
    if (saleOrderId <= 0 || repo.companyId <= 0) return;
    try {
      final draft = await repo.saleOrderDraft(saleOrderId);
      if (isClosed) return;
      if (draft == null) throw StateError('Unable to prepare the sale order update form.');
      emit(SaleOrderUpdateState(stage: UpdateStage.ready, draft: draft));
    } catch (e) {
      if (isClosed) return;
      emit(SaleOrderUpdateState(stage: UpdateStage.failed, error: errorText(e, 'Failed to load sale order details.')));
    }
  }

  void edit(SaleOrderDraft Function(SaleOrderDraft) change) {
    final d = state.draft;
    if (d == null) return;
    emit(state.copyWith(draft: change(d)));
  }

  void addStop({required bool pickup}) => edit((d) {
        final row = StopRow(key: 'new-${++_stopSeq}');
        return pickup ? d.copyWith(pickups: [...d.pickups, row]) : d.copyWith(deliveries: [...d.deliveries, row]);
      });

  void removeStop(String key, {required bool pickup}) => edit((d) => pickup
      ? d.copyWith(pickups: [
          for (final s in d.pickups)
            if (s.key != key) s
        ])
      : d.copyWith(deliveries: [
          for (final s in d.deliveries)
            if (s.key != key) s
        ]));

  void editStop(String key, StopRow Function(StopRow) change, {required bool pickup}) => edit((d) => pickup
      ? d.copyWith(pickups: [for (final s in d.pickups) s.key == key ? change(s) : s])
      : d.copyWith(deliveries: [for (final s in d.deliveries) s.key == key ? change(s) : s]));

  /// The checks before the confirm "Sale Order Update": the refusal, or null.
  String? saveRefusal() {
    if (saleOrderId <= 0 || repo.companyId <= 0) return 'Sale order details are missing.';
    if (state.draft?.saleOrderId != saleOrderId) return 'This job did not finish loading. Close and reopen it before saving.';
    return null;
  }

  /// The payload sent for this job (the job id comes from the row, never from the form).
  Map<String, dynamic> payload() =>
      SaleOrderUpdateRules.payload(state.draft!, saleOrderId: saleOrderId, companyId: repo.companyId, employeeId: repo.employeeId);

  /// Saves after the confirm; answers the server's saved values for the plan's rows, or null.
  Future<Map<String, dynamic>?> save() async {
    if (state.stage == UpdateStage.saving) return null;
    final refusal = saveRefusal();
    if (refusal != null) {
      emit(state.copyWith(message: refusal, messageSeq: state.messageSeq + 1));
      return null;
    }
    emit(state.copyWith(stage: UpdateStage.saving));
    try {
      final saved = await repo.updateSaleOrder(payload());
      if (isClosed) return saved;
      final m = Js.text(saved['message']).trim();
      emit(state.copyWith(
          stage: UpdateStage.saved, saved: saved, message: m.isNotEmpty ? m : 'Sale order updated successfully', messageSeq: state.messageSeq + 1));
      return saved;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(stage: UpdateStage.ready, message: errorText(e, 'Update Failed'), messageSeq: state.messageSeq + 1));
      return null;
    }
  }
}
