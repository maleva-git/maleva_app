import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../../../core/utils/clsfunction.dart' as objfun;
import 'enquiry_event.dart';
import 'enquiry_state.dart';


class EnquiryBloc extends Bloc<EnquiryEvent, EnquiryState> {
  EnquiryBloc() : super(const EnquiryState()) {
    on<LoadEnquiryEvent>(_onLoadEnquiry);
    on<CancelEnquiryEvent>(_onCancelEnquiry);
  }

  Future<void> _onLoadEnquiry(
      LoadEnquiryEvent event,
      Emitter<EnquiryState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final Map<String, dynamic> master = {
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Fromdate': null,
      'Todate': null,
      'Employeeid': objfun.EmpRefId,
      'Invoice': false,
      'Id': 0,
      'JId': 0,
      'DashboardStatus': 2,
    };

    try {
      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectEnquiryMaster,
        master,
        header,
        null,
      );

      if (resultData != '' && resultData.length != 0) {
        final List<dynamic> list = List<dynamic>.from(resultData);

        // Date format பண்ணுறோம்
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

    final int comId = objfun.storagenew.getInt('Comid') ?? 0;
    const String status = 'CANCEL';

    final Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final resultData = await objfun.apiAllinoneSelectArray(
        '${objfun.apiUpdateEnquiryMaster}${event.id}&Comid=$comId&StatusName=$status',
        null,   // ← original la null தான்
        header,
        null,
      );

      if (resultData != '') {
        add(LoadEnquiryEvent()); // reload
      }
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ));
    }
  }
}