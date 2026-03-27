
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/truck/bloc/truck_state.dart';
import '../../../../../../core/models/model.dart';
part 'truck_event.dart';


class TruckDetailsBloc extends Bloc<TruckDetailsEvent, TruckDetailsState> {
  final BuildContext context;

  TruckDetailsBloc({required this.context}) : super(const TruckInitial()) {
    on<TruckDetailsEvent>(_onLoadTruck);
  }

  // ── Load Truck Data ──────────────────────────────────────────────────────────
  Future<void> _onLoadTruck(
      TruckDetailsEvent event,
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
        'Comid':                      objfun.Comid,
        'AccountId':                  0,
      };

      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final resultData = await objfun.apiAllinoneSelectArray(
          objfun.apiSelectTruckDetails, body, header, context);

      // No data
      if (resultData == null ||
          resultData == "" ||
          (resultData is List && resultData.isEmpty)) {
        emit(const TruckLoadedState(truckData: []));
        return;
      }

      // Has data → map to model
      final List<TruckDetailsModel> truckList = (resultData as List)
          .map((e) => TruckDetailsModel.fromJson(e))
          .toList()
          .cast<TruckDetailsModel>();

      emit(TruckLoadedState(truckData: truckList));
    } catch (error, stackTrace) {
      emit(TruckErrorState(errorMessage: '$error\n$stackTrace'));
    }
  }

  // ── Helper: format date ──────────────────────────────────────────────────────
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

  // ── Helper: expiry row color logic ───────────────────────────────────────────
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