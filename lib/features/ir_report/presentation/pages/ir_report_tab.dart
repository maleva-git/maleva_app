import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/session/app_session.dart';

import '../ir_permissions.dart';
import '../list/bloc/ir_list_bloc.dart';
import 'ir_list_page.dart';

/// The IR list as a dashboard tab. Drop `const IrReportTab()` into any
/// dashboard's TabBarView; it needs nothing from the dashboard.
///
/// TabBarView builds a page only when it is first shown, so the reports load
/// when the user opens the tab, not with the dashboard. The page is then kept
/// alive, so switching tabs does not reload the list or lose the filters.
class IrReportTab extends StatefulWidget {
  const IrReportTab({super.key});

  @override
  State<IrReportTab> createState() => _IrReportTabState();
}

class _IrReportTabState extends State<IrReportTab> with AutomaticKeepAliveClientMixin {
  late final IrPermissions _permissions = IrPermissions.forSession(sl<AppSession>());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<IrListBloc>(
      create: (_) => sl<IrListBloc>()..add(const IrListStarted()),
      child: IrListView(permissions: _permissions),
    );
  }
}
