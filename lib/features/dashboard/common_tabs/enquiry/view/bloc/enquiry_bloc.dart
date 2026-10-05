import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';
import '../data/enquiry_repository.dart';
import 'enquiry_event.dart';
import 'enquiry_state.dart';

class EnquiryBloc extends Bloc<EnquiryEvent, EnquiryState> {
  final EnquiryRepository repository;

  EnquiryBloc({required this.repository}) : super(const EnquiryState()) {
    on<LoadEnquiryEvent>(_onLoadEnquiry);
    on<CancelEnquiryEvent>(_onCancelEnquiry);


    add(LoadEnquiryEvent());
  }

  Future<void> _onLoadEnquiry(
      LoadEnquiryEvent event,
      Emitter<EnquiryState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final list = await repository.fetchEnquiries(employeeId: AppGlobals.EmpRefId);
      emit(state.copyWith(isLoading: false, enquiryList: list));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onCancelEnquiry(
      CancelEnquiryEvent event,
      Emitter<EnquiryState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await repository.cancelEnquiry(event.id);
      add(LoadEnquiryEvent()); // reload on success
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ));
    }
  }
}