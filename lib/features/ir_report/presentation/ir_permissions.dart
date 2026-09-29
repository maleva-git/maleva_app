import 'package:maleva/core/session/app_session.dart';

import '../domain/entities/ir_report.dart';

/// What the signed-in user may do with incident reports.
///
/// Everyone sees every report and may file a new one. A report can be changed
/// by the person who filed it or by an admin, and deleted by an admin only.
///
/// Enforced in the app only: the .NET IRApp endpoints take no login, so this
/// keeps users from mistakes, not a caller who goes around the app.
class IrPermissions {
  const IrPermissions({
    this.canAdd = true,
    this.canEditAny = false,
    this.canDeleteAny = false,
    this.employeeId = 0,
  });

  factory IrPermissions.forSession(AppSession session) {
    final isAdmin = adminRoleIds.contains(session.roleId);
    return IrPermissions(
      canEditAny: isAdmin,
      canDeleteAny: isAdmin,
      employeeId: session.employeeId,
    );
  }

  /// UserRoles SUPERADMIN (100) and ADMIN (200).
  static const adminRoleIds = {100, 200};

  final bool canAdd;
  final bool canEditAny;
  final bool canDeleteAny;

  /// EmployeeMaster.Id of the user; 0 when there is none (a driver login).
  final int employeeId;

  bool canEdit(IrReport report) =>
      canEditAny || (employeeId != 0 && report.reporterId == employeeId);

  bool canDelete(IrReport report) => canDeleteAny;

  /// Narrows these rights by a menu entry's PageAdd / PageEdit / PageDelete
  /// flags. Never widens them.
  IrPermissions limitedTo({required bool add, required bool edit, required bool delete}) {
    return IrPermissions(
      canAdd: canAdd && add,
      canEditAny: canEditAny && edit,
      canDeleteAny: canDeleteAny && delete,
      employeeId: edit ? employeeId : 0,
    );
  }
}
