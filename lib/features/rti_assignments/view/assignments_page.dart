import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti_assignments/bloc/assignments_bloc.dart';
import 'package:maleva/features/rti_assignments/view/phone/assignments_phone_view.dart';
import 'package:maleva/features/rti_assignments/view/tablet/assignments_tablet_view.dart';

/// Employee Assignments on phone and tablet (change `planning-rti-phone-tablet`, rows EA1–EA3).
/// Nothing loads until Search. Register the feature with `registerAssignmentsFeature` first.
class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) => MalevaThemeScope(
        child: BlocProvider<AssignmentsBloc>(
          create: (_) => GetIt.I<AssignmentsBloc>()..add(const AssignmentsStarted()),
          child: BlocListener<AssignmentsBloc, AssignmentsState>(
            listenWhen: (a, b) => b.notice != null && a.notice != b.notice,
            listener: (context, s) => showSnack(context, s.notice!.message, kind: SnackKind.error),
            child: ResponsiveLayout(
              phone: (_) => const AssignmentsPhoneView(),
              tabletPortrait: (_) => const AssignmentsTabletPortraitView(),
              tabletLandscape: (_) => const AssignmentsTabletLandscapeView(),
            ),
          ),
        ),
      );
}
