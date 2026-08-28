import 'package:intl/intl.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/utils/system_helpers.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                } catch (e, st) {
          emit(PlanningError(e.toString()));
          if (!context.mounted) return;
          msgshow(e.toString(), st.toString(), Colors.white, colour.commonColorred, null, 18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
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
          if (!context.mounted) return;
          msgshow(e.toString(), st.toString(), Colors.white, colour.commonColorred, null, 18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
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
        if (!context.mounted) return;
        msgshow(e.toString(), st.toString(), Colors.white, colour.commonColorred, null, 18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
      }
    });

    on<AssignTruckDriverEvent>((event, emit) {
      if (state is PlanningLoaded) {
        final currentState = state as PlanningLoaded;
        final Map<int, List<PlanningDetailModel>> updatedMap = Map.from(currentState.detailsMap);
        
        for (var entry in updatedMap.entries) {
          final list = entry.value;
          final index = list.indexWhere((element) => element.jobNo == event.jobNo);
          if (index != -1) {
            final updatedList = List<PlanningDetailModel>.from(list);
            updatedList[index] = updatedList[index].copyWith(
              truckName: event.truckName,
              truckRefId: event.truckRefId,
              driverName: event.driverName,
              driverRefId: event.driverRefId
            );
            updatedMap[entry.key] = updatedList;
            break;
          }
        }
        
        emit(currentState.copyWith(detailsMap: updatedMap));
      }
    });

    on<UpdateDatesEvent>((event, emit) {
      if (state is PlanningLoaded) {
        final currentState = state as PlanningLoaded;
        final Map<int, List<PlanningDetailModel>> updatedMap = Map.from(currentState.detailsMap);
        
        for (var entry in updatedMap.entries) {
          final list = entry.value;
          final index = list.indexWhere((element) => element.jobNo == event.jobNo);
          if (index != -1) {
            final updatedList = List<PlanningDetailModel>.from(list);
            updatedList[index] = updatedList[index].copyWith(
              pickupDate: event.pickupDate,
              deliveryDate: event.deliveryDate,
            );
            updatedMap[entry.key] = updatedList;
            break;
          }
        }
        
        emit(currentState.copyWith(detailsMap: updatedMap));
      }
    });

    on<UpdateAddressEvent>((event, emit) {
      if (state is PlanningLoaded) {
        final currentState = state as PlanningLoaded;
        final Map<int, List<PlanningDetailModel>> updatedMap = Map.from(currentState.detailsMap);
        
        for (var entry in updatedMap.entries) {
          final list = entry.value;
          final index = list.indexWhere((element) => element.jobNo == event.jobNo);
          if (index != -1) {
            final updatedList = List<PlanningDetailModel>.from(list);
            updatedList[index] = updatedList[index].copyWith(
              pickupAddress: event.pickupAddress,
              deliveryAddress: event.deliveryAddress,
            );
            updatedMap[entry.key] = updatedList;
            break;
          }
        }
        
        emit(currentState.copyWith(detailsMap: updatedMap));
      }
    });

    on<AddPlanningRowEvent>((event, emit) {
      if (state is PlanningLoaded) {
        final currentState = state as PlanningLoaded;
        final updatedMap = Map<int, List<PlanningDetailModel>>.from(currentState.detailsMap);
        
        final newRow = PlanningDetailModel(
          id: 0,
          planingMasterRefId: 0,
          jobNo: '',
          jobDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
          truckName: '',
          driverName: '',
          pickupDate: '',
          deliveryDate: '',
          origin: '',
          destination: '',
          package: '',
          weight: '',
          remarks: '',
          truckRefId: 0,
          driverRefId: 0,
          pickupAddress: '',
          deliveryAddress: '',
        );

        if (currentState.masterList.isNotEmpty) {
          final firstMasterId = currentState.masterList.first.Id;
          final existing = updatedMap[firstMasterId] ?? [];
          updatedMap[firstMasterId] = [...existing, newRow];
          emit(currentState.copyWith(detailsMap: updatedMap));
        } else {
          final dummyMaster = PlanningMasterModel(
            0,
            0,
            'NEW',
            DateFormat("yyyy-MM-dd").format(DateTime.now()),
            '',
          );
          updatedMap[0] = [newRow];
          emit(currentState.copyWith(
            masterList: [dummyMaster],
            detailsMap: updatedMap,
          ));
        }
      }
    });

    on<SavePlanningEvent>((event, emit) async {
      if (state is PlanningLoaded) {
        final currentState = state as PlanningLoaded;
        emit(PlanningLoading());

        
        try {
          final success = await _repository.savePlanning(currentState);
          if (success) {
            // Re-fetch everything
            add(LoadPlanningEvent(
              fromDate: currentState.fromDate,
              toDate: currentState.toDate,
              employeeId: currentState.employeeId,
              employeeName: currentState.employeeName,
              planningNo: currentState.planningNo,
              checkLoggedEmp: currentState.checkLoggedEmp,
            ));
            if (context.mounted) {
              msgshow("Successfully saved planning!", "", Colors.white, colour.kSuccess, null, 18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 1);
            }
          }
        } catch (e, st) {
          if (context.mounted) {
            msgshow(e.toString(), st.toString(), Colors.white, colour.commonColorred, null, 18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
          }
          emit(currentState);
        }
      }
    });
  }
}





