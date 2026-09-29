import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/session/app_session.dart';

import 'form/bloc/ir_form_bloc.dart';
import 'ir_permissions.dart';
import 'list/bloc/ir_list_bloc.dart';
import 'pages/ir_form_page.dart';
import 'pages/ir_list_page.dart';

/// The only place the IR screens are built with their blocs, so callers (the
/// menu, the list opening the form) never touch the service locator.
class IrReportRoutes {
  IrReportRoutes._();

  /// The drawer menu's IR screen. The flags come from the menu entry and can
  /// only narrow what the user's role allows.
  static Route<void> list({
    bool canAdd = true,
    bool canEdit = true,
    bool canDelete = true,
  }) {
    final permissions = IrPermissions.forSession(sl<AppSession>())
        .limitedTo(add: canAdd, edit: canEdit, delete: canDelete);
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<IrListBloc>(
        create: (_) => sl<IrListBloc>()..add(const IrListStarted()),
        child: IrListPage(permissions: permissions),
      ),
    );
  }

  /// Completes with `true` when the report was saved.
  static Route<bool> form({int? reportId, bool readOnly = false}) {
    return MaterialPageRoute<bool>(
      builder: (_) => BlocProvider<IrFormBloc>(
        create: (_) => sl<IrFormBloc>()..add(IrFormStarted(reportId: reportId)),
        child: IrFormPage(reportId: reportId, readOnly: readOnly),
      ),
    );
  }
}
