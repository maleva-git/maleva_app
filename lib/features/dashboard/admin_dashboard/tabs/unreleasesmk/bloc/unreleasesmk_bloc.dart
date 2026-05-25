import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/unreleasesmk_repository.dart';
import 'unreleasesmk_event.dart';
import 'unreleasesmk_state.dart';

class UnReleaseSMKBloc extends Bloc<UnReleaseSMKEvent, UnReleaseSMKState> {
  final UnReleaseSMKRepository repository;

  UnReleaseSMKBloc({required this.repository}) : super(const UnReleaseSMKState()) {
    on<UnReleaseSMKDataRequested>(_onDataRequested);
    on<UnReleaseSMKRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onDataRequested(
      UnReleaseSMKDataRequested event,
      Emitter<UnReleaseSMKState> emit,
      ) async {
    emit(state.copyWith(status: UnReleaseSMKStatus.loading));
    await _fetchData(emit);
  }

  Future<void> _onRefreshRequested(
      UnReleaseSMKRefreshRequested event,
      Emitter<UnReleaseSMKState> emit,
      ) async {
    emit(state.copyWith(status: UnReleaseSMKStatus.loading));
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<UnReleaseSMKState> emit) async {
    try {
      // Delegate data fetching to the repository
      final list = await repository.fetchUnReleaseSMKData();

      emit(state.copyWith(
        status: UnReleaseSMKStatus.success,
        unReleaseList: list,
      ));
    } catch (e, stackTrace) {
      emit(state.copyWith(
        status: UnReleaseSMKStatus.failure,
        errorMessage: e.toString(),
      ));

      assert(() {
        debugPrint('UnReleaseSMKBloc error: $e\n$stackTrace');
        return true;
      }());
    }
  }
}