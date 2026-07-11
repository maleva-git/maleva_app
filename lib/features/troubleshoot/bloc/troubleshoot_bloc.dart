import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/logging/app_logger.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';
import '../data/applog_api.dart';
import 'troubleshoot_event.dart';
import 'troubleshoot_state.dart';

class TroubleshootBloc extends Bloc<TroubleshootEvent, TroubleshootState> {
  TroubleshootBloc() : super(TroubleshootState()) {
    on<TroubleshootNoteChanged>((event, emit) {
      emit(state.copyWith(note: event.note));
    });

    on<TroubleshootReset>((event, emit) {
      emit(TroubleshootState());
    });

    on<TroubleshootSubmitted>((event, emit) async {
      emit(state.copyWith(sending: true, errorMessage: ""));

      try {
        final screenHistory = AppLogger.instance
            .exportAsText(); // includes SCREEN + ACTION + ERROR entries together,
        // already in chronological order — simplest payload for a first version.

        await AppLogApi.insertAppLog(
          empRefId: AppGlobals.EmpRefId,
          empName: AppPreferences.getUserId(),
          comid: AppGlobals.Comid,
          appVersion: AppGlobals.appversion,
          screenHistory: screenHistory,
          errorLog: "", // kept separate for a future version if you want to
          // split screens vs errors server-side; for now everything
          // is interleaved in screenHistory so nothing is lost.
          userNote: state.note,
        );

        emit(state.copyWith(sending: false, success: true));
      } catch (e) {
        emit(state.copyWith(
          sending: false,
          success: false,
          errorMessage: "Couldn't send report: $e",
        ));
      }
    });
  }
}
