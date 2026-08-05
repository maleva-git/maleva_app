import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'rti_activities_event.dart';
import 'rti_activities_state.dart';
import '../../models/rti_route_activity.dart';
import '../../../../../core/utils/app_preferences.dart';
import '../../../../../core/config/app_config.dart';

class RtiActivitiesBloc extends Bloc<RtiActivitiesEvent, RtiActivitiesState> {
  RtiActivitiesBloc() : super(RtiActivitiesInitial()) {

    on<FetchRtiActivities>(_onFetchRtiActivities);
  }

  Future<void> _onFetchRtiActivities(FetchRtiActivities event, Emitter<RtiActivitiesState> emit) async {
    emit(RtiActivitiesLoading());
    try {
      final comid = AppPreferences.getComid();
      final fromDateStr = DateFormat('yyyy-MM-dd').format(event.fromDate);
      final toDateStr = DateFormat('yyyy-MM-dd').format(event.toDate);
      
      // We will post to the RTIAppController
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/RTIApp/SelectRTIRouteActivities?Comid=$comid&Fromdate=$fromDateStr&Todate=$toDateStr'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {


        final decoded = json.decode(response.body);
        if (decoded != null && decoded is List) {
          final activities = decoded.map((e) => RtiRouteActivity.fromJson(e)).toList();
          emit(RtiActivitiesLoaded(activities));
        } else {
          emit(const RtiActivitiesLoaded([]));
        }
      } else if (response.statusCode == 404) {
        emit(const RtiActivitiesLoaded([]));
      } else {
        print('RTI Fetch Failed: ${response.statusCode} - ${response.body}');
        emit(RtiActivitiesError('Failed to fetch data: ${response.statusCode}'));
      }
    } catch (e) {
      print('RTI Fetch Exception: $e');
      emit(RtiActivitiesError(e.toString()));
    }
  }
}
