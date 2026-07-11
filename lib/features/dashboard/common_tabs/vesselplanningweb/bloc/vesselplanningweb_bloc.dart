import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/vesselplanningweb_repository.dart';
import 'vesselplanningweb_event.dart';
import 'vesselplanningweb_state.dart';

class VesselPlanningWebBloc extends Bloc<VesselPlanningWebEvent, VesselPlanningWebState> {
  final VesselPlanningWebRepository repository;

  VesselPlanningWebBloc({required this.repository}) : super(VesselPlanningWebInitial()) {
    on<FetchVesselPlanningSearch>((event, emit) async {
      emit(VesselPlanningWebLoading());
      try {
        final dataList = await repository.getVesselPlanningSearch(
          fromDate: event.fromDate,
          toDate: event.toDate,
          etaType: event.etaType,
          searchPorts: event.searchPorts,
          deliveryDone: event.deliveryDone,
          employeeId: event.employeeId,
        );
        emit(VesselPlanningWebLoaded(dataList: dataList));
      } catch (e) {
        emit(VesselPlanningWebError(message: e.toString()));
      }
    });

    on<UpdateSpecificJobEvent>((event, emit) async {
      final currentState = state;
      emit(VesselPlanningWebActionLoading());
      try {
        final message = await repository.updateSpecificJob(event.updateList);
        emit(VesselPlanningWebActionSuccess(message));
        event.onSuccess();
        if (currentState is VesselPlanningWebLoaded) {
          emit(VesselPlanningWebLoaded(dataList: currentState.dataList));
        }
      } catch (e) {
        emit(VesselPlanningWebError(message: e.toString()));
        if (currentState is VesselPlanningWebLoaded) {
          emit(VesselPlanningWebLoaded(dataList: currentState.dataList, planningNo: currentState.planningNo));
        }
      }
    });

    on<SaveVesselPlanningEvent>((event, emit) async {
      final currentState = state;
      emit(VesselPlanningWebActionLoading());
      try {
        final message = await repository.saveVesselPlanning(event.planningList);
        emit(VesselPlanningWebActionSuccess(message));
        if (currentState is VesselPlanningWebLoaded) {
          emit(VesselPlanningWebLoaded(dataList: currentState.dataList, planningNo: currentState.planningNo));
        }
      } catch (e) {
        emit(VesselPlanningWebError(message: e.toString()));
        if (currentState is VesselPlanningWebLoaded) {
          emit(VesselPlanningWebLoaded(dataList: currentState.dataList, planningNo: currentState.planningNo));
        }
      }
    });

    on<LoadPlanningForEditEvent>((event, emit) async {
      emit(VesselPlanningWebLoading());
      try {
        final dataList = await repository.getPlanningById(event.planningMaster['Id']);
        emit(VesselPlanningWebLoaded(dataList: dataList, planningNo: event.planningMaster['CNumberDisplay'], masterData: event.planningMaster));
      } catch (e) {
        emit(VesselPlanningWebError(message: e.toString()));
      }
    });
  }
}
