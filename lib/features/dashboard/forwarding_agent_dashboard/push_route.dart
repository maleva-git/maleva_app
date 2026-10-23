import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/rti_activities/rti_activities_bloc.dart';
import 'view/rti_route_activities_tab.dart';

/// The 06:00 morning notice to a forwarding agent (backend `rti-morning-briefing`, type `RTI_STOPS_TODAY`):
/// the trucks coming to their stops today. Tapping it opens [rtiActivitiesPath].
/// It is the only notice that rings as an alarm (30-second tone, see LocalNotificationService.rtiAlarmChannel).
const String rtiStopsTodayType = 'RTI_STOPS_TODAY';

/// A normal notice (no alarm) when an RTI edit or revise adds, moves or removes one of the agent's stops due today
/// (backend `RtiStopChangeNotices`). It opens RTI Activities too.
const String rtiStopsChangedType = 'RTI_STOPS_CHANGED';

/// RTI Activities on its own page (the same tab as on the forwarding agent dashboard).
const String rtiActivitiesPath = '/rti_activities';

/// Where a push or notice of [type] opens; null when it is not one of the RTI stop notices.
String? rtiActivitiesRouteForType(String? type) =>
    type == rtiStopsTodayType || type == rtiStopsChangedType ? rtiActivitiesPath : null;

/// The page behind [rtiActivitiesPath]; it loads today's stops on open.
class RtiActivitiesPage extends StatelessWidget {
  const RtiActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RTI Activities')),
      body: BlocProvider<RtiActivitiesBloc>(
        create: (_) => RtiActivitiesBloc(),
        child: const RtiRouteActivitiesTab(),
      ),
    );
  }
}
