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

  // ── All raw detail rows — kept in bloc, not in global ──
  List<dynamic> _allDetails = [];

  // ── Default dates ──
  static String get _today => DateFormat("yyyy-MM-dd").format(DateTime.now());

  PlanningBloc(this.context) : super(PlanningInitial()) {

    // ────────────────────────────────────────────────────
    // LOAD PLANNING DATA
    // droppable() → rapid filter taps only fire once
    // ────────────────────────────────────────────────────
    on<LoadPlanningEvent>(
          (event, emit) async {
        // Keep filter values during reload
        final prevLoaded = state is PlanningLoaded
            ? state as PlanningLoaded
            : null;

        emit(PlanningLoading());

        try {
          // Load employee list first (same as original startup)
          await OnlineApi.SelectEmployee(context, 'Sales', '');

          final empId = event.employeeId;

          Map<String, dynamic> master = {
            "Comid": objfun.storagenew.getInt('Comid') ?? 0,
            "Fromdate": event.fromDate,
            "Todate": event.toDate,
            "Employeeid": empId,
            "Search": event.planningNo,
          };

          Map<String, String> header = {
            'Content-Type': 'application/json; charset=UTF-8',
          };

          final resultData = await objfun.apiAllinoneSelectArray(
            objfun.apiSelectPlanning, master, header, context,
          );

          if (resultData != null && resultData != "") {
            List<PlanningMasterModel> masterList = [];
            List<dynamic> detailsList = [];

            if (resultData.isNotEmpty) {
              masterList = (resultData[0]["salemaster"] as List)
                  .map((e) => PlanningMasterModel.fromJson(e))
                  .toList();
              detailsList = resultData[0]["saledetails"].toList();
            }

            // Save all details in bloc
            _allDetails = detailsList;

            // Also sync globals (other parts of the app may still read these)
            objfun.PlanningMasterList = masterList;
            objfun.PlanningDetailsList = detailsList;

            emit(PlanningLoaded(
              masterList: masterList,
              detailsMap: const {},
              expandedIndex: -1,
              fromDate: event.fromDate,
              toDate: event.toDate,
              employeeId: event.employeeId,
              employeeName: prevLoaded?.employeeName ?? '',
              planningNo: event.planningNo,
              checkLoggedEmp: prevLoaded?.checkLoggedEmp ?? true,
            ));
          } else {
            emit(PlanningError("No data returned"));
          }
        } catch (e, st) {
          emit(PlanningError(e.toString()));
          objfun.msgshow(
            e.toString(), st.toString(),
            Colors.white, Colors.red, null,
            18.00 - objfun.reducesize,
            objfun.tll, objfun.tgc, context, 2,
          );
        }
      },
      transformer: droppable(),
    );

    // ────────────────────────────────────────────────────
    // EXPAND / COLLAPSE CARD
    // ────────────────────────────────────────────────────
    on<TogglePlanningExpand>((event, emit) {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;

      final newIndex =
      s.expandedIndex == event.index ? -1 : event.index;

      // Filter details for this master
      final filteredDetails = _allDetails
          .where((item) =>
      item["PLANINGMasterRefId"] == event.masterRefId)
          .toList();

      final newMap = Map<int, List<dynamic>>.from(s.detailsMap);
      newMap[event.index] = filteredDetails;

      emit(s.copyWith(
        expandedIndex: newIndex,
        detailsMap: newMap,
      ));
    });

    // ────────────────────────────────────────────────────
    // SHARE PDF
    // ────────────────────────────────────────────────────
    on<SharePlanningPdfEvent>(
          (event, emit) async {
        if (state is! PlanningLoaded) return;
        final s = state as PlanningLoaded;

        // Show subtle loading (keep UI visible)
        emit(PlanningPdfLoading(
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
          Map<String, dynamic> master = {
            'SoId': event.id,
            'Comid': objfun.Comid,
          };
          Map<String, String> header = {
            'Content-Type': 'application/json; charset=UTF-8',
          };

          final resultData = await objfun.apiAllinoneSelectArray(
            "${objfun.apiViewPlanningPdf}${event.planningNoDisplay}",
            master, header, context,
          );

          if (resultData != null && resultData != "") {
            final value = ResponseViewModel.fromJson(resultData);
            if (value.IsSuccess == true) {
              objfun.launchInBrowser(value.data1);
            }
          }
        } catch (e, st) {
          objfun.msgshow(
            e.toString(), st.toString(),
            Colors.white, Colors.red, null,
            18.00 - objfun.reducesize,
            objfun.tll, objfun.tgc, context, 2,
          );
        }

        // Restore normal loaded state
        emit(s);
      },
      transformer: droppable(),
    );

    // ────────────────────────────────────────────────────
    // EDIT PLANNING (after password verified)
    // ────────────────────────────────────────────────────
    on<EditPlanningEvent>((event, emit) async {
      try {
        await OnlineApi.EditPlanning(context, event.id, event.planningNo);
        emit(PlanningNavigateToEdit(
            id: event.id, planningNo: event.planningNo));
        // Restore previous state so listener fires only once
        if (state is PlanningLoaded) {
          emit(state as PlanningLoaded);
        }
      } catch (e, st) {
        objfun.msgshow(
          e.toString(), st.toString(),
          Colors.white, Colors.red, null,
          18.00 - objfun.reducesize,
          objfun.tll, objfun.tgc, context, 2,
        );
      }
    });

    // ────────────────────────────────────────────────────
    // EMPLOYEE SELECTED
    // ────────────────────────────────────────────────────
    on<SelectEmployeeEvent>((event, emit) {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;
      emit(s.copyWith(
        employeeId: event.empId,
        employeeName: event.empName,
      ));
    });

    // ────────────────────────────────────────────────────
    // CLEAR EMPLOYEE
    // ────────────────────────────────────────────────────
    on<ClearEmployeeEvent>((event, emit) {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;
      emit(s.copyWith(employeeId: 0, employeeName: ''));
    });

    // ────────────────────────────────────────────────────
    // TOGGLE LOGGED-IN EMPLOYEE CHECKBOX
    // ────────────────────────────────────────────────────
    on<ToggleLoggedEmpEvent>((event, emit) {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;
      emit(s.copyWith(checkLoggedEmp: event.value));
    });

    // ────────────────────────────────────────────────────
    // UPDATE FILTER DATES
    // ────────────────────────────────────────────────────
    on<UpdateFilterDatesEvent>((event, emit) {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;
      emit(s.copyWith(
        fromDate: event.fromDate ?? s.fromDate,
        toDate: event.toDate ?? s.toDate,
      ));
    });

    // ────────────────────────────────────────────────────
    // UPDATE PLANNING NO TEXT
    // ────────────────────────────────────────────────────
    on<UpdatePlanningNoEvent>((event, emit) {
      if (state is! PlanningLoaded) return;
      final s = state as PlanningLoaded;
      emit(s.copyWith(planningNo: event.value));
    });
  }
}