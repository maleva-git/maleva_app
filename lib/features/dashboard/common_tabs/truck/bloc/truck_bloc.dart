import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/dashboard/common_tabs/truck/bloc/truck_state.dart';
import '../../../../../core/models/model.dart';
import '../data/truck_repository.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';
part 'truck_event.dart';


class TruckDetailsBloc extends Bloc<TruckDetailsEvent, TruckDetailsState> {
  final TruckRepository repository;

  TruckDetailsBloc({required this.repository}) : super(const TruckInitial()) {
    on<LoadTruckDetailsEvent>(_onLoadTruck);
  }

  Future<void> _onLoadTruck(
      LoadTruckDetailsEvent event,
      Emitter<TruckDetailsState> emit,
      ) async {
    emit(const TruckLoadingState());

    try {
      final String currentDate =
      DateFormat("yyyy-MM-dd").format(DateTime.now().add(const Duration(days: 5)));

      final Map<String, dynamic> body = {
        'ExpDate':                    currentDate,
        'ExpApadBonam':               currentDate,
        'ExpServiceAligmentGreece':   currentDate,
        'Id':                         0,
        'SFromDate':                  null,
        'Comid':                      AppGlobals.Comid,
        'AccountId':                  0,
      };

      final resultData = await repository.fetchTruckDetails(body: body);

      if (resultData == null || resultData == "") {
        emit(const TruckLoadedState(truckData: []));
        return;
      }

      final value = ResponseViewModel.fromJson(resultData);
      if (value.IsSuccess == true && value.data1 != null) {
        final List<TruckDetailsModel> truckList = (value.data1 as List)
            .map((e) => TruckDetailsModel.fromJson(e))
            .toList()
            .cast<TruckDetailsModel>();

        emit(TruckLoadedState(truckData: truckList));
      } else {
        emit(const TruckLoadedState(truckData: []));
      }
    } catch (error) {

      emit(TruckErrorState(errorMessage: error.toString()));
    }
  }

  static String formatTruckDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDate);
      if (dt.year <= 1) return '-';
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  static Color expiryColor(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return Colors.grey;
    try {
      final dt = DateTime.parse(rawDate);
      if (dt.year <= 1) return Colors.grey;
      final diff = dt.difference(DateTime.now()).inDays;
      if (diff < 0)  return Colors.red;
      if (diff <= 30) return Colors.orange;
      return const Color(0xFF1555F3);
    } catch (_) {
      return Colors.grey;
    }
  }
}