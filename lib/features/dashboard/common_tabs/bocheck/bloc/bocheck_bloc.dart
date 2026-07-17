import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../../../../../core/models/model.dart';
import '../data/bocheck_repository.dart';
import 'bocheck_event.dart';
import 'bocheck_state.dart';
import 'package:maleva/core/models/shared/bo_detail_response.dart';

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
      final resultData = await repository.fetchBocData(body: requestBody);

      if (resultData != null && resultData.isNotEmpty) {
        final data1 = resultData['Data1'] as List?;

        if (data1 != null && data1.isNotEmpty) {
          final List<BoDetailResponse> records = data1
              .map((e) => BoDetailResponse.fromJson(e))
              .toList()
              .cast<BoDetailResponse>();
          emit(BocLoaded(records));
        } else {
          emit(BocEmpty());
        }
      } else {
        emit(BocEmpty());
      }
    } catch (error) {
      emit(BocError(error.toString()));
    }
  }
}