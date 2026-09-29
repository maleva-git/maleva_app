part of 'ir_list_bloc.dart';

class IrListState extends Equatable {
  const IrListState({
    required this.filter,
    this.status = IrViewStatus.initial,
    this.items = const [],
    this.totalAmount = 0,
    this.statuses = const [],
    this.errorMessage,
    this.message,
    this.deletingId,
  });

  final IrViewStatus status;
  final IrFilter filter;

  /// Kept while a reload runs, so the list does not blank out on refresh.
  final List<IrReport> items;
  final int totalAmount;

  /// For the status filter chips.
  final List<IrStatus> statuses;

  /// Why the last load failed.
  final String? errorMessage;
  final IrUiMessage? message;

  /// The report whose delete is in flight.
  final int? deletingId;

  IrListState copyWith({
    IrViewStatus? status,
    IrFilter? filter,
    List<IrReport>? items,
    int? totalAmount,
    List<IrStatus>? statuses,
    String? Function()? errorMessage,
    IrUiMessage? Function()? message,
    int? Function()? deletingId,
  }) {
    return IrListState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      statuses: statuses ?? this.statuses,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      message: message != null ? message() : this.message,
      deletingId: deletingId != null ? deletingId() : this.deletingId,
    );
  }

  @override
  List<Object?> get props =>
      [status, filter, items, totalAmount, statuses, errorMessage, message, deletingId];
}
