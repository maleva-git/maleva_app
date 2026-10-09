import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_api.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';

class RequestForwardingState {
  const RequestForwardingState({this.existing = const [], this.loading = true, this.saving = false, this.error});

  final List<ForwardingRequest> existing;
  final bool loading;
  final bool saving;
  final String? error;

  /// Form types already requested and still open on this job, so a repeat is deliberate.
  Set<String> get openTypes => {for (final r in existing) if (!r.cancelled) r.formType};

  RequestForwardingState copyWith({List<ForwardingRequest>? existing, bool? loading, bool? saving, String? error, bool clearError = false}) =>
      RequestForwardingState(
        existing: existing ?? this.existing,
        loading: loading ?? this.loading,
        saving: saving ?? this.saving,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Customer Service's "Request FW" on a sale order: shows what is already asked, creates one request
/// per chosen form type.
class RequestForwardingCubit extends Cubit<RequestForwardingState> {
  RequestForwardingCubit(this._api, {required this.saleOrderId}) : super(const RequestForwardingState());

  final ForwardingRequestApi _api;
  final int saleOrderId;

  Future<void> load() async {
    try {
      final rows = await _api.forSaleOrder(saleOrderId);
      if (!isClosed) emit(state.copyWith(existing: rows, loading: false, clearError: true));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(loading: false, error: '$e'));
    }
  }

  /// Throws the server's message when refused (unknown job, bad form type).
  Future<List<ForwardingRequest>> create({required List<String> formTypes, required DateTime estimate, String remarks = ''}) async {
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final created = await _api.create(saleOrderId: saleOrderId, formTypes: formTypes, estimatedDate: estimate, remarks: remarks);
      if (!isClosed) emit(state.copyWith(existing: [...created, ...state.existing], saving: false));
      return created;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(saving: false));
      rethrow;
    }
  }
}
