import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/bocheck_repository.dart';
import 'bocheck_event.dart';
import 'bocheck_state.dart';

class BocBloc extends Bloc<BocEvent, BocState> {
  // ❌ REMOVED: final BuildContext context;
  final BoCheckRepository repository; // ✅ Injected Repository

  BocBloc({required this.repository}) : super(BocInitial()) {
    on<LoadBocReport>(_onLoadBocReport);
  }

  Future<void> _onLoadBocReport(
      LoadBocReport event,
      Emitter<BocState> emit,
      ) async {
    emit(BocLoading());

    try {
      final Map<String, dynamic> requestBody = {
        "Comid": AppGlobals.Comid,
        "Fromdate": "",
        "Todate": "",
        "Id": 0,
        "Employeeid": 0,
        "Search": event.searchValue,
        "Remarks": 0,
        "status": "",
        "TId": 0,
        "DId": 0,
        "Offvesselname": "",
      };

      // ✅ REFACTORED: Using the injected repository without context
      final result = await repository.fetchBocData(body: requestBody);
      if (result.masters.isNotEmpty) {
        emit(BocLoaded([result]));
      } else {
        emit(BocEmpty());
      }
    } catch (error) {
      emit(BocError(error.toString()));
    }
  }
}