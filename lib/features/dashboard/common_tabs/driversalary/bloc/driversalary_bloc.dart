import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../data/driversalary_repository.dart';
import 'driversalary_event.dart';
import 'driversalary_state.dart';

class DriverSalaryBloc extends Bloc<DriverSalaryEvent, DriverSalaryState> {
  final DriverSalaryRepository repository;

  DriverSalaryBloc({required this.repository}) : super(DriverSalaryInitial()) {
    on<DriverSalaryStarted>(_onStarted);
    on<DriverSalaryFromDateChanged>(_onFromDateChanged);
    on<DriverSalaryToDateChanged>(_onToDateChanged);
    on<DriverSalaryDetailRequested>(_onDetailRequested);
  }

  Future<void> _onStarted(DriverSalaryStarted event, Emitter<DriverSalaryState> emit) async {
    emit(DriverSalaryLoading());
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _loadSalary(emit, fromDate: today, toDate: today);
  }

  Future<void> _onFromDateChanged(DriverSalaryFromDateChanged event, Emitter<DriverSalaryState> emit) async {
    if (state is DriverSalaryLoaded) {
      final s = state as DriverSalaryLoaded;
      emit(DriverSalaryLoading());
      await _loadSalary(emit, fromDate: event.date, toDate: s.toDate);
    }
  }

  Future<void> _onToDateChanged(DriverSalaryToDateChanged event, Emitter<DriverSalaryState> emit) async {
    if (state is DriverSalaryLoaded) {
      final s = state as DriverSalaryLoaded;
      emit(DriverSalaryLoading());
      await _loadSalary(emit, fromDate: s.fromDate, toDate: event.date);
    }
  }

  Future<void> _loadSalary(Emitter<DriverSalaryState> emit, {required String fromDate, required String toDate}) async {
    try {
      final data = await repository.fetchSalaryData(fromDate: fromDate, toDate: toDate);
      emit(DriverSalaryLoaded(
        fromDate: fromDate,
        toDate: toDate,
        salaryList: data['salaryList'],
        salaryAmount: data['salaryAmount'],
      ));
    } catch (e) {
      emit(DriverSalaryError(e.toString()));
    }
  }

  void _onDetailRequested(DriverSalaryDetailRequested event, Emitter<DriverSalaryState> emit) {
    emit(DriverSalaryShowDetail(event.item));
    // Re-emit last known loaded state to keep the view active
    if (state is DriverSalaryLoaded) emit(state);
  }
}