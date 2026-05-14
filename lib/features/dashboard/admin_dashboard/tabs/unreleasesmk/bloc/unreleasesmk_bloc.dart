import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/unreleasesmk/bloc/unreleasesmk_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/unreleasesmk/bloc/unreleasesmk_state.dart';

import '../../../../../../core/theme/palette.dart';
import '../../../../../../core/theme/tokens.dart';
import '../../../../../../core/utils/clsfunction.dart' as objfun;



class UnReleaseSMKBloc
    extends Bloc<UnReleaseSMKEvent, UnReleaseSMKState> {
  UnReleaseSMKBloc() : super(const UnReleaseSMKState()) {
    on<UnReleaseSMKDataRequested>(_onDataRequested);
    on<UnReleaseSMKRefreshRequested>(_onRefreshRequested);
  }
// replace with your singleton / locator

  // ── Handlers ───────────────────────────────────────────────

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

  // ── Core fetch ─────────────────────────────────────────────

  Future<void> _fetchData(Emitter<UnReleaseSMKState> emit) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      // K8 SMK always uses the K8 endpoint
      final String url = objfun.LoadK8UnReleaseNo;

      final Map<String, dynamic> body = {
        'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        url,
        body,
        headers,
        null, // context is not passed into the BLoC layer
      );

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final list = List<Map<String, dynamic>>.from(
          resultData.map((e) => Map<String, dynamic>.from(e as Map)),
        );
        emit(state.copyWith(
          status: UnReleaseSMKStatus.success,
          unReleaseList: list,
        ));
      } else {
        emit(state.copyWith(
          status: UnReleaseSMKStatus.success,
          unReleaseList: const [],
        ));
      }
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