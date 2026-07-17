import 'package:maleva/core/utils/system_helpers.dart';
// ════════════════════════════════════════════════════════════════════
//  planning_bloc.dart
// ════════════════════════════════════════════════════════════════════

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

import 'planning_event.dart';
import 'planning_state.dart';
import 'package:maleva/features/transaction/planning/data/planning_repository.dart';
import 'package:maleva/core/models/shared/planning_detail_model.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';
import 'package:maleva/core/models/shared/planning_master_model.dart';

class PlanningBloc extends Bloc<PlanningEvent, PlanningState> {
  final BuildContext context;
  final PlanningRepository _repository;
  List<PlanningDetailModel> _allDetails = [];

  PlanningBloc(this.context, this._repository) : super(PlanningInitial()) {
    on<LoadPlanningEvent>(
          (event, emit) async {
        emit(PlanningLoading());

        try {
          await _repository.selectEmployee(context, 'Sales', '');
          
          final resultData = await _repository.getPlanning(
              event.fromDate, event.toDate, event.planningNo, event.employeeId);

          if (resultData != null) {
            List<PlanningMasterModel> masterList = [];
            List<PlanningDetailModel> detailsList = [];

            if (resultData.isNotEmpty) {
              masterList = (resultData[0]["salemaster"] as List).map((e) => PlanningMasterModel.fromJson(e)).toList();
              detailsList = (resultData[0]["saledetails"] as List).map((e) => PlanningDetailModel.fromJson(e)).toList();
            }

            _allDetails = detailsList;
            AppGlobals.PlanningMasterList = masterList;
            AppGlobals.PlanningDetailsList = detailsList;

            // Proper data mapping to state with updated user filter inputs
            emit(PlanningLoaded(
              masterList: masterList,
              detailsMap: const {},
              expandedIndex: -1,
              fromDate: event.fromDate,
              toDate: event.toDate,
              employeeId: event.employeeId,
              employeeName: event.employeeName,
              planningNo: event.planningNo,
              checkLoggedEmp: event.checkLoggedEmp,
            ));
          } else {
            emit(PlanningError("No data returned"));
          }
        } catch (e, st) {
          emit(PlanningError(e.toString()));
          msgshow(e.toString(), st.toString(), Colors.white, Colors.red, null, 18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        }
      },
      transformer: droppable(),
    );

    on<TogglePlanningExpand>((event, emit) {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;
      final newIndex = s.expandedIndex == event.index ? -1 : event.index;
      final filteredDetails = _allDetails.where((item) => item.planingMasterRefId == event.masterRefId).toList();
      final newMap = Map<int, List<PlanningDetailModel>>.from(s.detailsMap);
      newMap[event.index] = filteredDetails;

      emit(s.copyWith(expandedIndex: newIndex, detailsMap: newMap));
    });

    on<SharePlanningPdfEvent>(
          (event, emit) async {
        if (state is! PlanningLoaded) return;
        final s = state as PlanningLoaded;

        emit(PlanningPdfLoading(
          loadingId: event.id,
          masterList: s.masterList,
          detailsMap: s.detailsMap,
          expandedIndex: s.expandedIndex,
          fromDate: s.fromDate,
          toDate: s.toDate,
          employeeId: s.employeeId,
          employeeName: s.employeeName,
          planningNo: s.planningNo,
          checkLoggedEmp: s.checkLoggedEmp,
        ));

        try {
          final resultData = await _repository.getSharePdfUrl(context, event.id, event.planningNoDisplay);

          if (resultData != null) {
            final value = ResponseViewModel.fromJson(resultData);
            if (value.IsSuccess == true) SystemHelpers.launchInBrowser(value.data1);
          }
        } catch (e, st) {
          msgshow(e.toString(), st.toString(), Colors.white, Colors.red, null, 18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
        }
        emit(s);
      },
      transformer: droppable(),
    );

    on<PlanningEditRequestedEvent>((event, emit) async {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;

      try {
        await _repository.editPlanning(context, event.id, event.planningNo);
        emit(PlanningNavigateToEdit(id: event.id, planningNo: event.planningNo));
        emit(s); // Return to default loaded state after navigation
      } catch (e, st) {
        msgshow(e.toString(), st.toString(), Colors.white, Colors.red, null, 18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
      }
    });
  }
}