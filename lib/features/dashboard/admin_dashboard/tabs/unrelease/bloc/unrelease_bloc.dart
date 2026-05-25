import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/unrelease/bloc/unrelease_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/unrelease/bloc/unrelease_state.dart';
import '../data/unrelease_repository.dart';

class UnReleaseBloc extends Bloc<UnReleaseEvent, UnReleaseState> {
  final UnReleaseRepository repository;

  UnReleaseBloc({required this.repository}) : super(const UnReleaseState()) {
    on<UnReleaseDataRequested>(_onDataRequested);
    on<UnReleaseRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onDataRequested(
      UnReleaseDataRequested event,
      Emitter<UnReleaseState> emit,
      ) async {
    emit(state.copyWith(status: UnReleaseStatus.loading, type: event.type));
    await _fetchData(event.type, emit);
  }

  Future<void> _onRefreshRequested(
      UnReleaseRefreshRequested event,
      Emitter<UnReleaseState> emit,
      ) async {
    emit(state.copyWith(status: UnReleaseStatus.loading, type: event.type));
    await _fetchData(event.type, emit);
  }

  Future<void> _fetchData(int type, Emitter<UnReleaseState> emit) async {
    try {
      final list = await repository.fetchUnReleaseData(type);

      emit(state.copyWith(
        status: UnReleaseStatus.success,
        unReleaseList: list,
      ));
    } catch (e, stackTrace) {
      emit(state.copyWith(
        status: UnReleaseStatus.failure,
        errorMessage: e.toString(),
      ));
      assert(() {
        debugPrint('UnReleaseBloc error: $e\n$stackTrace');
        return true;
      }());
    }
  }
}