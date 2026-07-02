// ════════════════════════════════════════════════════════════════════
//  planning_bloc.dart
// ════════════════════════════════════════════════════════════════════

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import 'planning_event.dart';
import 'planning_state.dart';

class PlanningBloc extends Bloc<PlanningEvent, PlanningState> {
  final BuildContext context;
  List<dynamic> _allDetails = [];

  PlanningBloc(this.context) : super(PlanningInitial()) {
    on<LoadPlanningEvent>(
          (event, emit) async {
        emit(PlanningLoading());

        try {
          await OnlineApi.SelectEmployee(context, 'Sales', '');Map<String, dynamic> master = {
            "Comid": objfun.storagenew.getInt('Comid') ?? 0,
            "Fromdate": event.fromDate,
            "Todate": event.toDate,
            "Employeeid": event.employeeId,
            "Search": event.planningNo,
          };

          Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8'};
          final resultData = await objfun.apiAllinoneSelectArray(objfun.apiSelectPlanning, master, header, context);

          if (resultData != null && resultData != "") {
            List<PlanningMasterModel> masterList = [];
            List<dynamic> detailsList = [];

            if (resultData.isNotEmpty) {
              masterList = (resultData[0]["salemaster"] as List).map((e) => PlanningMasterModel.fromJson(e)).toList();
              detailsList = resultData[0]["saledetails"].toList();
            }

            _allDetails = detailsList;
            objfun.PlanningMasterList = masterList;
            objfun.PlanningDetailsList = detailsList;

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
          objfun.msgshow(e.toString(), st.toString(), Colors.white, Colors.red, null, 18.00 - objfun.reducesize, objfun.tll, objfun.tgc, context, 2);
        }
      },
      transformer: droppable(),
    );

    on<TogglePlanningExpand>((event, emit) {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;
      final newIndex = s.expandedIndex == event.index ? -1 : event.index;
      final filteredDetails = _allDetails.where((item) => item["PLANINGMasterRefId"] == event.masterRefId).toList();
      final newMap = Map<int, List<dynamic>>.from(s.detailsMap);
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
          Map<String, dynamic> master = {'SoId': event.id, 'Comid': objfun.Comid};
          Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8'};
          final resultData = await objfun.apiAllinoneSelectArray("${objfun.apiViewPlanningPdf}${event.planningNoDisplay}", master, header, context);

          if (resultData != null && resultData != "") {
            final value = ResponseViewModel.fromJson(resultData);
            if (value.IsSuccess == true) objfun.launchInBrowser(value.data1);
          }
        } catch (e, st) {
          objfun.msgshow(e.toString(), st.toString(), Colors.white, Colors.red, null, 18.00 - objfun.reducesize, objfun.tll, objfun.tgc, context, 2);
        }
        emit(s);
      },
      transformer: droppable(),
    );

    on<VerifyEditPasswordEvent>((event, emit) async {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;

      try {
        final resultData = await objfun.apiAllinoneSelectArray("${objfun.apiEditPassword}${event.password}&type=EditPassword&Comid=${objfun.Comid}", null, null, context);
        if (resultData != null && resultData.isNotEmpty && resultData["IsSuccess"] == true) {
          await OnlineApi.EditPlanning(context, event.id, event.planningNo);emit(PlanningNavigateToEdit(id: event.id, planningNo: event.planningNo));
          emit(s); // Return to default loaded state after navigation
        } else {
          objfun.ConfirmationOK("Invalid Password !!!", context);
        }
      } catch (e, st) {
        objfun.msgshow(e.toString(), st.toString(), Colors.white, Colors.red, null, 18.00 - objfun.reducesize, objfun.tll, objfun.tgc, context, 2);
      }
    });
  }
}