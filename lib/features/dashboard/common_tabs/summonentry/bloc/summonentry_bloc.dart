import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/summonentry_repository.dart';
import 'summonentry_event.dart';
import 'summonentry_state.dart';

class SummonBloc extends Bloc<SummonEvent, SummonState> {

  final SummonRepository repository;


  SummonBloc.form({required this.repository}) : super(const SummonEntryState()) {
    _registerHandlers();
  }


  SummonBloc.view({
    required this.repository,
    DateTime? fromDate,
    DateTime? toDate
  }) : super(SummonViewState(
    fromDate: fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
    toDate: toDate ?? DateTime.now(),
  )) {
    _registerHandlers();
    add(const LoadSummonViewEvent());
  }

  void _registerHandlers() {
    // Entry events
    on<SelectTruckEvent>(_onSelectTruck);
    on<SelectEntryDateEvent>(_onSelectEntryDate);
    on<SelectCountryEvent>(_onSelectCountry);
    on<SelectSummonTypeEvent>(_onSelectSummonType);
    on<UpdateAmountEvent>(_onUpdateAmount);
    on<UpdatePortPassEvent>(_onUpdatePortPass);
    on<UpdateTruckLcnMntEvent>(_onUpdateTruckLcnMnt);
    on<UpdateLevyEvent>(_onUpdateLevy);
    on<UpdateFuelEvent>(_onUpdateFuel);
    on<PickDocumentEvent>(_onPickDocument);
    on<SubmitSummonEvent>(_onSubmit);
    on<ResetEntryFormEvent>(_onReset);

    // View events
    on<SelectViewFromDateEvent>(_onViewFromDate);
    on<SelectViewToDateEvent>(_onViewToDate);
    on<LoadSummonViewEvent>(_onLoadView);
    _loadTrucks();
  }

  Future<void> _loadTrucks() async {
    if (AppGlobals.GetTruckList.isEmpty) {
      await repository.fetchTrucks();

      if (state is SummonEntryState) {
        emit((state as SummonEntryState).copyWith());
      }
    }
  }

  void _onSelectTruck(SelectTruckEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(selectedTruck: e.truckId));
  }

  void _onSelectEntryDate(SelectEntryDateEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(selectedDate: e.date));
  }

  void _onSelectCountry(SelectCountryEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState)
        .copyWith(selectedCountry: e.country, clearSummon: true));
  }

  void _onSelectSummonType(SelectSummonTypeEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(selectedSummon: e.summonType));
  }

  void _onUpdateAmount(UpdateAmountEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(amount: e.value));
  }

  void _onUpdatePortPass(UpdatePortPassEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(portPass: e.value));
  }

  void _onUpdateTruckLcnMnt(UpdateTruckLcnMntEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(truckLcnMnt: e.value));
  }

  void _onUpdateLevy(UpdateLevyEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(levy: e.value));
  }

  void _onUpdateFuel(UpdateFuelEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(fuel: e.value));
  }

  Future<void> _onPickDocument(PickDocumentEvent e, Emitter<SummonState> emit) async {
    if (state is! SummonEntryState) return;
    final s = state as SummonEntryState;

    if (e.image != null) {
      emit(s.copyWith(pickedImage: e.image, clearPDF: true));
    } else if (e.pdf != null) {
      emit(s.copyWith(pickedPDF: e.pdf, clearImage: true));
    }
  }

  Future<void> _onSubmit(SubmitSummonEvent e, Emitter<SummonState> emit) async {
    if (state is! SummonEntryState) return;
    final s = state as SummonEntryState;

    emit(s.copyWith(isSubmitting: true));

    try {
      final id = await repository.submitSummon(
        truckId: int.tryParse(s.selectedTruck ?? '') ?? 0,
        summon: s.selectedSummon ?? '',
        country: s.selectedCountry,
        portPass: s.portPass,
        truckLcnMnt: s.truckLcnMnt,
        levy: s.levy,
        fuel: s.fuel,
        amount: double.tryParse(s.amount.replaceAll(',', '.')) ?? 0,
        entryDate: DateFormat('yyyy-MM-dd').format(s.selectedDate ?? DateTime.now()),
        image: s.pickedImage,
        pdf: s.pickedPDF,
      );
      final isSuccess = id > 0;

      if (isSuccess) {
        emit(const SummonSubmitSuccess());
      } else {
        emit(s.copyWith(isSubmitting: false));
        emit(const SummonEntryError("Server error: Failed to submit"));
      }
    } catch (err) {
      emit(s.copyWith(isSubmitting: false));
      emit(SummonEntryError(err.toString()));
    }
  }

  void _onReset(ResetEntryFormEvent e, Emitter<SummonState> emit) {
    emit(const SummonEntryState());
  }



  void _onViewFromDate(SelectViewFromDateEvent e, Emitter<SummonState> emit) {
    if (state is! SummonViewState) return;
    emit((state as SummonViewState).copyWith(fromDate: e.date));
  }

  void _onViewToDate(SelectViewToDateEvent e, Emitter<SummonState> emit) {
    if (state is! SummonViewState) return;
    emit((state as SummonViewState).copyWith(toDate: e.date));
  }

  Future<void> _onLoadView(LoadSummonViewEvent e, Emitter<SummonState> emit) async {
    if (state is! SummonViewState) return;
    final s = state as SummonViewState;

    emit(s.copyWith(isLoading: true));

    try {
      final String from = DateFormat('yyyy-MM-dd').format(s.fromDate);
      final String to = DateFormat('yyyy-MM-dd').format(s.toDate);

      final records = await repository.fetchSummonRecords(fromDate: from, toDate: to);

      emit(s.copyWith(records: records, isLoading: false));
    } catch (err) {
      emit(SummonViewError(
        message: err.toString(),
        fromDate: s.fromDate,
        toDate: s.toDate,
      ));
    }
  }
}