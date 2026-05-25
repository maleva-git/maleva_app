import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../data/salary_repository.dart'; // Update path based on your folder structure

part 'salary_event.dart';
part 'salary_state.dart';

class SalaryBloc extends Bloc<SalaryEvent, SalaryState> {
  final SalaryRepository repository;

  // Context removed, repository injected
  SalaryBloc({required this.repository}) : super(SalaryState(
    fromDate: DateFormat("yyyy-MM-dd").format(DateTime(DateTime.now().year, DateTime.now().month, 1)),
    toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
  )) {
    on<SalaryInitialLoad>(_onInitialLoad);
    on<LoadSalaryData>(_onLoadSalaryData);
    on<UpdateFromDate>(_onUpdateFromDate);
    on<UpdateToDate>(_onUpdateToDate);
  }

  Future<void> _onInitialLoad(SalaryInitialLoad event, Emitter<SalaryState> emit) async {
    add(LoadSalaryData(fromDate: state.fromDate, toDate: state.toDate));
  }

  Future<void> _onLoadSalaryData(LoadSalaryData event, Emitter<SalaryState> emit) async {
    emit(state.copyWith(
      status: SalaryStatus.loading,
      fromDate: event.fromDate,
      toDate: event.toDate,
    ));

    try {
      final data = await repository.fetchSalaryData(event.fromDate, event.toDate);

      emit(state.copyWith(
        status: SalaryStatus.success,
        salaryList: data['salaryList'],
        salaryAmount: data['salaryAmount'],
      ));
    } catch (e) {
      // Replaced _handleError (which used BuildContext) with state emission
      emit(state.copyWith(
        status: SalaryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateFromDate(UpdateFromDate event, Emitter<SalaryState> emit) async {
    emit(state.copyWith(fromDate: event.fromDate));
    add(LoadSalaryData(fromDate: event.fromDate, toDate: state.toDate));
  }

  Future<void> _onUpdateToDate(UpdateToDate event, Emitter<SalaryState> emit) async {
    emit(state.copyWith(toDate: event.toDate));
    add(LoadSalaryData(fromDate: state.fromDate, toDate: event.toDate));
  }
}