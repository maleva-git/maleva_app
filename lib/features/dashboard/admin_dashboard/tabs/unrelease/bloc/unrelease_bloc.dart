import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/tokens.dart';
import '../../../../../../core/utils/clsfunction.dart' as objfun;


part 'unrelease_event.dart';
part 'unrelease_state.dart';

class UnReleaseBloc extends Bloc<UnReleaseEvent, UnReleaseState> {
  UnReleaseBloc() : super(const UnReleaseState()) {
    on<UnReleaseDataRequested>(_onDataRequested);
    on<UnReleaseRefreshRequested>(_onRefreshRequested);
  }

  // ── Shared reference (same pattern as your existing code) ──// replace with your singleton / locator

  // ── Handlers ───────────────────────────────────────────────

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
    // Keep current list visible while refreshing
    emit(state.copyWith(status: UnReleaseStatus.loading, type: event.type));
    await _fetchData(event.type, emit);
  }

  // ── Core fetch ─────────────────────────────────────────────

  Future<void> _fetchData(int type, Emitter<UnReleaseState> emit) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final String url =
      type == 1 ? objfun.LoadK8UnReleaseNo : objfun.LoadUnReleaseNo;

      final Map<String, dynamic> body = {
        'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        url,
        body,
        headers,
        null, // context not needed in BLoC layer
      );

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final list = List<Map<String, dynamic>>.from(
          resultData.map((e) => Map<String, dynamic>.from(e as Map)),
        );
        emit(state.copyWith(
          status: UnReleaseStatus.success,
          unReleaseList: list,
        ));
      } else {
        emit(state.copyWith(
          status: UnReleaseStatus.success,
          unReleaseList: const [],
        ));
      }
    } catch (e, stackTrace) {
      emit(state.copyWith(
        status: UnReleaseStatus.failure,
        errorMessage: e.toString(),
      ));
      // Log stack trace in debug
      assert(() {
        debugPrint('UnReleaseBloc error: $e\n$stackTrace');
        return true;
      }());
    }
  }
}