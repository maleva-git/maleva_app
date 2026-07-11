import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/enquiry_repository.dart';
import 'enquiry_event.dart';
import 'enquiry_state.dart';

class EnquiryBloc extends Bloc<EnquiryEvent, EnquiryState> {
  final EnquiryRepository repository; // ✅ Injected Repository

  EnquiryBloc({required this.repository}) : super(const EnquiryState()) {
    on<LoadEnquiryEvent>(_onLoadEnquiry);
    on<CancelEnquiryEvent>(_onCancelEnquiry);

    // ✅ Auto-load data when the BLoC is created!
    add(LoadEnquiryEvent());
  }

  Future<void> _onLoadEnquiry(
      LoadEnquiryEvent event,
      Emitter<EnquiryState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> master = {
      'Comid': AppGlobals.storagenew.getInt('Comid') ?? 0,
      'Fromdate': null,
      'Todate': null,
      'Employeeid': AppGlobals.EmpRefId,
      'Invoice': false,
      'Id': 0,
      'JId': 0,
      'DashboardStatus': 2,
    };

    try {
      // ✅ Call the repository
      final resultData = await repository.fetchEnquiries(master);

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<dynamic> list = List<dynamic>.from(resultData);

        // Date Format
        for (var i = 0; i < list.length; i++) {
          if (list[i]['ForwardingDate'] == null) {
            list[i]['SForwardingDate'] = '';
          } else {
            list[i]['SForwardingDate'] = DateFormat('dd-MM-yyyy HH:mm')
                .format(DateTime.parse(list[i]['ForwardingDate']));
          }
        }

        emit(state.copyWith(
          isLoading: false,
          enquiryList: list,
        ));
      } else {
        emit(state.copyWith(isLoading: false, enquiryList: []));
      }
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

    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
    const String status = 'CANCEL';

    try {
      // ✅ Call the repository
      final resultData = await repository.cancelEnquiry(event.id, comId, status);

      if (resultData != null && resultData.toString().isNotEmpty) {
        add(LoadEnquiryEvent()); // reload on success
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: "Failed to cancel."));
      }
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ));
    }
  }
}