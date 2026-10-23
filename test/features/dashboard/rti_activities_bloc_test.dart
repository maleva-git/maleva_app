import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/bloc/rti_activities/rti_activities_bloc.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/bloc/rti_activities/rti_activities_event.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/bloc/rti_activities/rti_activities_state.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/models/rti_route_activity.dart';

class _MockRtiApi extends Mock implements RtiApi {}

void main() {
  late _MockRtiApi api;
  final stop = RtiRouteActivity.fromJava({'id': 7, 'rtiMasterRefId': 3, 'status': 0});
  final loaded = RtiActivitiesLoaded([stop]);

  setUp(() => api = _MockRtiApi());

  blocTest<RtiActivitiesBloc, RtiActivitiesState>(
    'a saved change shows success with the new status',
    build: () {
      when(() => api.setRouteActivityStatus(7, 1)).thenAnswer((_) async {});
      return RtiActivitiesBloc(api: api);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(const UpdateRtiStatus(7, 1)),
    expect: () => [
      isA<RtiActivitiesActionSuccess>().having((s) => s.activities.single.status, 'status', 1),
    ],
  );

  blocTest<RtiActivitiesBloc, RtiActivitiesState>(
    'a failed change keeps the old status and says why',
    build: () {
      when(() => api.setRouteActivityStatus(7, 1))
          .thenThrow(const ApiFailure('No internet connection. Check your network.'));
      return RtiActivitiesBloc(api: api);
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(const UpdateRtiStatus(7, 1)),
    expect: () => [
      isA<RtiActivitiesActionFailure>()
          .having((s) => s.activities.single.status, 'status', 0)
          .having((s) => s.errorMessage, 'message',
              'Status not changed to COMPLETED. No internet connection. Check your network. Please try again.'),
    ],
  );

  blocTest<RtiActivitiesBloc, RtiActivitiesState>(
    'the same failure twice shows the message twice',
    build: () {
      when(() => api.setRouteActivityStatus(7, 1)).thenThrow(const ApiFailure('Route activity 7 was not found'));
      return RtiActivitiesBloc(api: api);
    },
    seed: () => loaded,
    act: (bloc) => bloc
      ..add(const UpdateRtiStatus(7, 1))
      ..add(const UpdateRtiStatus(7, 1)),
    expect: () => [
      isA<RtiActivitiesActionFailure>().having((s) => s.errorMessage, 'message',
          'Status not changed to COMPLETED. Route activity 7 was not found. Please try again.'),
      isA<RtiActivitiesActionFailure>(),
    ],
  );
}
