import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/ir_filter.dart';
import '../../../domain/entities/ir_lookup.dart';
import '../../../domain/entities/ir_report.dart';
import '../../../domain/repositories/ir_repository.dart';
import '../../ir_view_status.dart';

part 'ir_list_event.dart';
part 'ir_list_state.dart';

class IrListBloc extends Bloc<IrListEvent, IrListState> {
  IrListBloc({
    required IrRepository repository,
    IrFilter? initialFilter,
    Duration searchDebounce = const Duration(milliseconds: 400),
  })  : _repository = repository,
        super(IrListState(filter: initialFilter ?? IrFilter.lastDays(30))) {
    on<IrListStarted>(_onStarted, transformer: droppable());
    on<IrListRefreshed>((_, __) => add(const _IrListFetchRequested()));
    on<IrListFilterChanged>(_onFilterChanged);
    on<IrListSearchChanged>(_onSearchChanged, transformer: _debounce(searchDebounce));
    on<IrListDeleteRequested>(_onDeleteRequested, transformer: sequential());
    on<_IrListFetchRequested>(_onFetch, transformer: restartable());
  }

  final IrRepository _repository;

  static EventTransformer<E> _debounce<E>(Duration duration) =>
      (events, mapper) => events.debounceTime(duration).switchMap(mapper);

  Future<void> _onStarted(IrListStarted event, Emitter<IrListState> emit) async {
    add(const _IrListFetchRequested());
    try {
      emit(state.copyWith(statuses: await _repository.statuses()));
    } catch (_) {
      // The status chips are optional; the list works without them.
    }
  }

  void _onFilterChanged(IrListFilterChanged event, Emitter<IrListState> emit) {
    if (event.filter == state.filter) return;
    emit(state.copyWith(filter: event.filter));
    add(const _IrListFetchRequested());
  }

  void _onSearchChanged(IrListSearchChanged event, Emitter<IrListState> emit) {
    final text = event.text.trim();
    if (text == state.filter.search) return;
    emit(state.copyWith(filter: state.filter.copyWith(search: text)));
    add(const _IrListFetchRequested());
  }

  Future<void> _onFetch(_IrListFetchRequested event, Emitter<IrListState> emit) async {
    final filter = state.filter;
    final from = filter.fromDate;
    final to = filter.toDate;
    if (from != null && to != null && from.isAfter(to)) {
      emit(state.copyWith(
        status: IrViewStatus.failure,
        errorMessage: () => 'From date must not be after To date',
      ));
      return;
    }

    emit(state.copyWith(status: IrViewStatus.loading, errorMessage: () => null));
    try {
      final result = await _repository.search(filter);
      emit(state.copyWith(
        status: IrViewStatus.success,
        items: result.items,
        totalAmount: result.totalAmount,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: IrViewStatus.failure,
        errorMessage: () => describeError(error),
      ));
    }
  }

  Future<void> _onDeleteRequested(IrListDeleteRequested event, Emitter<IrListState> emit) async {
    final report = event.report;
    emit(state.copyWith(deletingId: () => report.id));
    try {
      await _repository.delete(report.id);
      emit(state.copyWith(
        items: state.items.where((item) => item.id != report.id).toList(),
        totalAmount: state.totalAmount - (report.actualAmount ?? 0),
        deletingId: () => null,
        message: () => IrUiMessage('Incident report deleted'),
      ));
    } catch (error) {
      emit(state.copyWith(
        deletingId: () => null,
        message: () => IrUiMessage(describeError(error), isError: true),
      ));
    }
  }
}
