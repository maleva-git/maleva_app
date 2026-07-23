import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeDashboardBloc
    extends Bloc<HomeDashboardEvent, HomeDashboardState> {
  HomeDashboardBloc() : super(const HomeDashboardState()) {
    on<HomeDashboardStartupRequested>(_onStartup);
    on<HomeDashboardExitConfirmed>(_onExitConfirmed);
  }

  // ── Startup ───────────────────────────────────────────────────────────────

  Future<void> _onStartup(
      HomeDashboardStartupRequested event,
      Emitter<HomeDashboardState> emit,
      ) async {
    emit(state.copyWith(status: HomeDashboardStatus.loading));

    try {
      final bool canUpdate = await _checkStoreVersion();
      emit(state.copyWith(
        status: HomeDashboardStatus.ready,
        canUpdate: canUpdate,
      ));
    } catch (e, st) {
      // Version check failure is non-fatal — dashboard still loads.
      _log(e, st);
      emit(state.copyWith(
        status: HomeDashboardStatus.ready,
        errorMessage: e.toString(),
        canUpdate: false,
      ));
    }
  }

  // ── Exit confirmed ────────────────────────────────────────────────────────

  Future<void> _onExitConfirmed(
      HomeDashboardExitConfirmed event,
      Emitter<HomeDashboardState> emit,
      ) async {
    // Extension point: clear session data before OS terminates the app.
  }

  // ── Store version check ───────────────────────────────────────────────────
  // Uses the same package and IDs as your existing SystemHelpers.checkVersion().
  // Context is NOT needed here — only the check, not the dialog.
  // The UI listener calls AppVersionUpdate.showAlertUpdate() with context.

  Future<bool> _checkStoreVersion() async {
    final result = await AppVersionUpdate.checkForUpdates(
      appleId: '6738003436',
      playStoreId: 'com.kassapos.maleva',
    );
    return result.canUpdate ?? false;
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  void _log(Object e, StackTrace st) {
    assert(() {
      debugPrint('HomeDashboardBloc error: $e\n$st');
      return true;
    }());
  }
}